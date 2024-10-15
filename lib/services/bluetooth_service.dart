import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/file_service.dart';

class TemperatureData {
  final DateTime time;
  final double nozzleTemp;
  final double bedTemp;

  TemperatureData(this.time, this.nozzleTemp, this.bedTemp);
}

class BluetoothService extends ChangeNotifier {
  static const double maxSafeTemperature = 260.0; // 안전 최대 온도 설정

  BluetoothConnection? _connection;
  String _connectionStatus = '연결 안됨';
  double? _currentNozzleTemperature;
  double? _currentBedTemperature;
  final String _printerStatus = '대기 중';
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
      print('프린터 연결 시도: $address');
      _connection = await BluetoothConnection.toAddress(address).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('연결 시간 초과'),
      );
      print('블루투스 연결 성공');
      _connectionStatus = '연결됨';
      
      _connection!.input!.listen(_handlePrinterResponse);
      _startPeriodicTemperatureCheck();
      notifyListeners();
      return true;
    } catch (e) {
      print('프린터 연결 실패: $e');
      _connectionStatus = '연결 실패';
      notifyListeners();
      return false;
    }
  }

  void _startPeriodicTemperatureCheck() {
    _temperatureCheckTimer?.cancel(); // 기존 타이머가 있다면 취소
    _temperatureCheckTimer = Timer.periodic(Duration(seconds: 5), (_) => checkTemperature());
  }

  Future<void> sendGCode(String gcode) async {
    if (_connection == null || _connection!.isConnected == false) {
      throw Exception("프린터가 연결되어 있지 않습니다");
    }
    try {
      _connection!.output.add(Uint8List.fromList(gcode.codeUnits));
      await _connection!.output.allSent;
      print('G-code 전송됨: $gcode');
    } catch (e) {
      print('G-code 전송 실패: $e');
      throw Exception("G-code 전송 실패: $e");
    }
  }

  Future<void> checkTemperature() async {
    await sendGCode('M105\n');
    _checkTemperatureSafety(); // 여기에서 온도 안전 검사 함수를 호출합니다.
  }

  void _checkTemperatureSafety() {
    if (currentTemperature > BluetoothService.maxSafeTemperature) {
      // 온도가 안전 범위를 초과한 경우
      _sendEmergencyStop();
      notifyListeners();
    }
  }

  void _sendEmergencyStop() {
    sendGCode('M112\n'); // 긴급 정지 명령
    _connectionStatus = '긴급 정지: 온도 초과';
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

  void _handlePrinterResponse(Uint8List data) {
    String response = String.fromCharCodes(data);
    print('프린터 응답: $response');
    // 여기에 응답에 ���른 추가 로직 구현
  }

  void _updateTemperatureHistory() {
    final now = DateTime.now();
    final newData = TemperatureData(now, currentNozzleTemperature, currentBedTemperature);
    _temperatureHistory.add(newData);

    _temperatureHistory.removeWhere((data) => now.difference(data.time).inSeconds > _maxHistorySize);
  }

  @override
  void notifyListeners() {
    _updateTemperatureHistory();
    super.notifyListeners();
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _connectionStatus = '연결 안됨';
    notifyListeners();
  }

  @override
  void dispose() {
    _temperatureCheckTimer?.cancel();
    disconnect(); // _device?.disconnect() 대신 disconnect() 메서드 호출
    super.dispose();
  }

  bool isConnected() {
    return _connection != null && _connection!.isConnected;
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
}
