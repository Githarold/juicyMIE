import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class TemperatureData {
  final DateTime time;
  final double nozzleTemp;
  final double bedTemp;

  TemperatureData(this.time, this.nozzleTemp, this.bedTemp);
}

class BluetoothService extends ChangeNotifier {
  static const String printerServiceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String gcodeCharacteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String nozzleTempCharacteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a9";
  static const String bedTempCharacteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26aa";
  static const String printerStatusCharacteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26ab";

  fbp.BluetoothDevice? _device;
  fbp.BluetoothCharacteristic? _gcodeCharacteristic;
  fbp.BluetoothCharacteristic? _nozzleTempCharacteristic;
  fbp.BluetoothCharacteristic? _bedTempCharacteristic;
  fbp.BluetoothCharacteristic? _printerStatusCharacteristic;

  String _connectionStatus = '연결 안됨';
  double? _currentTemperature;
  double? _currentBedTemperature;

  String get connectionStatus => _connectionStatus;
  double get currentTemperature => isConnected() ? _currentTemperature ?? 0 : 0;
  double get currentBedTemperature => isConnected() ? _currentBedTemperature ?? 0 : 0;

  final List<TemperatureData> _temperatureHistory = [];
  final int _maxHistorySize = 3600; // 1시간 (3600초)

  List<TemperatureData> get temperatureHistory => List.unmodifiable(_temperatureHistory);

  Future<bool> connectToPrinter(String address) async {
    try {
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      final List<fbp.ScanResult> scanResults = await fbp.FlutterBluePlus.scanResults.first;
      final fbp.ScanResult scanResult = scanResults.firstWhere(
        (result) => result.device.remoteId.toString() == address,
        orElse: () => throw Exception('프린터를 찾을 수 없습니다.'),
      );
      _device = scanResult.device;
      await _device!.connect();
      _connectionStatus = '연결됨';

      List<fbp.BluetoothService> services = await _device!.discoverServices();
      var printerService = services.firstWhere((service) => service.uuid.toString() == printerServiceUuid);

      _gcodeCharacteristic = printerService.characteristics.firstWhere(
        (char) => char.uuid.toString() == gcodeCharacteristicUuid,
      );

      _nozzleTempCharacteristic = printerService.characteristics.firstWhere(
        (char) => char.uuid.toString() == nozzleTempCharacteristicUuid,
      );

      _bedTempCharacteristic = printerService.characteristics.firstWhere(
        (char) => char.uuid.toString() == bedTempCharacteristicUuid,
      );

      _printerStatusCharacteristic = printerService.characteristics.firstWhere(
        (char) => char.uuid.toString() == printerStatusCharacteristicUuid,
      );

      // 온도와 상태 알림 설정
      await _nozzleTempCharacteristic!.setNotifyValue(true);
      await _bedTempCharacteristic!.setNotifyValue(true);
      await _printerStatusCharacteristic!.setNotifyValue(true);

      _nozzleTempCharacteristic!.onValueReceived.listen((value) {
        if (value.isNotEmpty) {
          _currentTemperature = value.first.toDouble();
          notifyListeners();
        }
      });

      _bedTempCharacteristic!.onValueReceived.listen((value) {
        if (value.isNotEmpty) {
          _currentBedTemperature = value.first.toDouble();
          notifyListeners();
        }
      });

      _printerStatusCharacteristic!.onValueReceived.listen((value) {
        if (value.isNotEmpty) {
          _connectionStatus = String.fromCharCodes(value);
          notifyListeners();
        }
      });

      notifyListeners();
      return true;
    } catch (e) {
      _connectionStatus = '연결 실패';
      print('프린터 연결 실패: $e');
      rethrow; // 호출자에게 예외를 전파
    } finally {
      await fbp.FlutterBluePlus.stopScan();
    }
  }

  Future<void> sendGCode(String gcode) async {
    if (_gcodeCharacteristic == null) {
      throw Exception("G-code characteristic not found");
    }
    await _gcodeCharacteristic!.write(gcode.codeUnits);
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    _device = null;
    _gcodeCharacteristic = null;
    _nozzleTempCharacteristic = null;
    _bedTempCharacteristic = null;
    _printerStatusCharacteristic = null;
    _connectionStatus = '연결 안됨';
    _currentTemperature = null;
    _currentBedTemperature = null;
    notifyListeners();
  }

  bool isConnected() {
    return _device != null && _connectionStatus == '연결됨';
  }

  void updateTemperatures(double nozzle, double bed) {
    _currentTemperature = nozzle;
    _currentBedTemperature = bed;
    notifyListeners();
  }

  Future<double> getTemperature(String type) async {
    if (!isConnected()) return 0;
    
    if (type == 'nozzle') {
      return _currentTemperature ?? 0;
    } else if (type == 'bed') {
      return _currentBedTemperature ?? 0;
    } else {
      throw ArgumentError('Invalid temperature type');
    }
  }

  void _updateTemperatureHistory() {
    final now = DateTime.now();
    final newData = TemperatureData(now, currentTemperature, currentBedTemperature);
    _temperatureHistory.add(newData);

    // 1시간이 지난 데이터 제거
    _temperatureHistory.removeWhere((data) => now.difference(data.time).inSeconds > _maxHistorySize);

    notifyListeners();
  }

  @override
  void notifyListeners() {
    _updateTemperatureHistory();
    super.notifyListeners();
  }
}
