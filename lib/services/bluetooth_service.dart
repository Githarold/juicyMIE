import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../services/file_service.dart';

class TemperatureData {
  final DateTime time;
  final double nozzleTemp;
  final double bedTemp;

  TemperatureData(this.time, this.nozzleTemp, this.bedTemp);
}

class BluetoothService extends ChangeNotifier {
  static const String uartServiceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String rxCharUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String txCharUuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

  fbp.BluetoothDevice? _device;
  fbp.BluetoothCharacteristic? _rxCharacteristic;
  fbp.BluetoothCharacteristic? _txCharacteristic;

  String _connectionStatus = '연결 안됨';
  double? _currentNozzleTemperature;
  double? _currentBedTemperature;
  String _printerStatus = '대기 중';
  Timer? _temperatureCheckTimer;

  String get connectionStatus => _connectionStatus;
  double get currentNozzleTemperature => isConnected() ? _currentNozzleTemperature ?? 0 : 0;
  double get currentBedTemperature => isConnected() ? _currentBedTemperature ?? 0 : 0;
  double get currentTemperature => currentNozzleTemperature;
  String get printerStatus => _printerStatus;

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
      var uartService = services.firstWhere((service) => service.uuid.toString() == uartServiceUuid);

      _rxCharacteristic = uartService.characteristics.firstWhere(
        (char) => char.uuid.toString() == rxCharUuid,
      );

      _txCharacteristic = uartService.characteristics.firstWhere(
        (char) => char.uuid.toString() == txCharUuid,
      );

      await _txCharacteristic!.setNotifyValue(true);
      _txCharacteristic!.onValueReceived.listen(_handlePrinterResponse);

      _startPeriodicTemperatureCheck();

      notifyListeners();
      return true;
    } catch (e) {
      _connectionStatus = '연결 실패';
      print('프린터 연결 실패: $e');
      rethrow;
    } finally {
      await fbp.FlutterBluePlus.stopScan();
    }
  }

  void _startPeriodicTemperatureCheck() {
    _temperatureCheckTimer = Timer.periodic(Duration(seconds: 5), (_) => checkTemperature());
  }

  Future<void> sendGCode(String gcode) async {
    if (_rxCharacteristic == null) {
      throw Exception("RX 특성을 찾을 수 없습니다");
    }
    try {
      await _rxCharacteristic!.write(gcode.codeUnits);
      print('G-code 전송됨: $gcode');
    } catch (e) {
      print('G-code 전송 실패: $e');
      throw Exception("G-code 전송 실패: $e");
    }
  }

  Future<void> checkTemperature() async {
    await sendGCode('M105\n');
  }

  Future<void> setNozzleTemperature(double temperature) async {
    await sendGCode('M104 S${temperature.round()}\n');
  }

  Future<void> setBedTemperature(double temperature) async {
    await sendGCode('M140 S${temperature.round()}\n');
  }

  Future<void> sendGCodeFile(String fileName) async {
    final FileService fileService = getFileService();
    final String gcode = await fileService.readGCodeFile(fileName);
    final List<String> lines = gcode.split('\n');

    for (String line in lines) {
      line = line.trim();
      if (line.isNotEmpty && !line.startsWith(';')) {
        await sendGCode('$line\n');
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  void _handlePrinterResponse(List<int> value) {
    String response = String.fromCharCodes(value);
    print('프린터 응답: $response');

    RegExp tempExp = RegExp(r'T:(\d+\.\d+) /\d+\.\d+ B:(\d+\.\d+) /\d+\.\d+');
    Match? tempMatch = tempExp.firstMatch(response);
    if (tempMatch != null) {
      _currentNozzleTemperature = double.parse(tempMatch.group(1)!);
      _currentBedTemperature = double.parse(tempMatch.group(2)!);
      _checkTemperatureSafety();
      notifyListeners();
    }

    RegExp statusExp = RegExp(r'SD printing byte (\d+)/(\d+)');
    Match? statusMatch = statusExp.firstMatch(response);
    if (statusMatch != null) {
      int printed = int.parse(statusMatch.group(1)!);
      int total = int.parse(statusMatch.group(2)!);
      double progress = printed / total * 100;
      _printerStatus = '인쇄 중: ${progress.toStringAsFixed(2)}%';
      notifyListeners();
    }
  }

  void _checkTemperatureSafety() {
    if (_currentNozzleTemperature! > 250 || _currentBedTemperature! > 110) {
      _printerStatus = '경고: 온도가 너무 높습니다!';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _temperatureCheckTimer?.cancel();
    await _device?.disconnect();
    _device = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    _connectionStatus = '연결 안됨';
    _currentNozzleTemperature = null;
    _currentBedTemperature = null;
    _printerStatus = '대기 중';
    notifyListeners();
  }

  bool isConnected() {
    return _device != null && _connectionStatus == '연결됨';
  }

  // 호환성을 위해 updateTemperatures 메서드 추가
  void updateTemperatures(double nozzle, double bed) {
    _currentNozzleTemperature = nozzle;
    _currentBedTemperature = bed;
    notifyListeners();
  }

  Future<double> getTemperature(String type) async {
    if (!isConnected()) return 0;
    
    if (type == 'nozzle') {
      return _currentNozzleTemperature ?? 0;
    } else if (type == 'bed') {
      return _currentBedTemperature ?? 0;
    } else {
      throw ArgumentError('잘못된 온도 유형');
    }
  }

  void _updateTemperatureHistory() {
    final now = DateTime.now();
    final newData = TemperatureData(now, currentNozzleTemperature, currentBedTemperature);
    _temperatureHistory.add(newData);

    _temperatureHistory.removeWhere((data) => now.difference(data.time).inSeconds > _maxHistorySize);

    notifyListeners();
  }

  @override
  void notifyListeners() {
    _updateTemperatureHistory();
    super.notifyListeners();
  }
}
