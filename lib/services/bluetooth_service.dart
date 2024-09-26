import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService extends ChangeNotifier {
  BluetoothConnection? connection;
  StreamSubscription<Uint8List>? _dataSubscription;
  String _connectionStatus = '연결 안됨';
  double _currentTemperature = 0.0;
  double _currentBedTemperature = 0.0;

  String get connectionStatus => _connectionStatus;
  double get currentTemperature => _currentTemperature;
  double get currentBedTemperature => _currentBedTemperature;

  Future<bool> connectToPrinter(String address) async {
    int retries = 3;
    while (retries > 0) {
      try {
        connection = await BluetoothConnection.toAddress(address).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('연결 시간 초과'),
        );
        if (connection != null && connection!.isConnected) {
          _connectionStatus = '연결됨';
          _dataSubscription = connection!.input!.listen(_onDataReceived);
          notifyListeners();
          return true;
        }
      } on TimeoutException catch (e) {
        print('블루투스 연결 타임아웃: $e');
      } catch (e) {
        print('블루투스 연결 오류: $e');
      }
      retries--;
      if (retries > 0) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    _connectionStatus = '연결 실패';
    notifyListeners();
    return false;
  }

  void _onDataReceived(Uint8List data) {
    String message = utf8.decode(data);
    _parseMessage(message);
  }

  void _parseMessage(String message) {
    if (message.startsWith('T:')) {
      // 온도 정보 파싱
      // 예: T:200.0 /200.0 B:60.0 /60.0
      List<String> parts = message.split(' ');
      _currentTemperature = double.parse(parts[0].split(':')[1]);
      _currentBedTemperature = double.parse(parts[2].split(':')[1]);
    } else if (message.startsWith('X:')) {
      // 위치 정보 파싱
    } else if (message.startsWith('SD printing byte')) {
      // 출력 진행 상황 파싱
    }
    notifyListeners();
  }

  Future<void> requestTemperature() async {
    await sendCommand('M105');
  }

  Future<void> requestPosition() async {
    await sendCommand('M114');
  }

  Future<void> requestPrintStatus() async {
    await sendCommand('M27');
  }

  Future<void> sendCommand(String command) async {
    connection?.output.add(utf8.encode('$command\n'));
    await connection?.output.allSent;
  }

  Future<void> sendGCode(String gcode) async {
    if (connection != null && connection!.isConnected) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode('$gcode\n')));
        await connection!.output.allSent;
        print('Sent G-code: $gcode');
      } catch (error) {
        print('Error sending G-code: $error');
      }
    } else {
      throw Exception('프린터에 연결되어 있지 않습니다.');
    }
  }

  Future<void> startPrinting(String fileName) async {
    if (connection != null && connection!.isConnected) {
      try {
        await sendGCode('M23 $fileName'); // 파일 선택
        await sendGCode('M24'); // 출력 시작
        print('Started printing $fileName');
      } catch (error) {
        print('Error starting print: $error');
      }
    } else {
      throw Exception('프린터에 연결되어 있지 않습니다.');
    }
  }

  Future<double> getTemperature(String type) async {
    if (connection != null && connection!.isConnected) {
      await sendGCode('M105'); // 온도 정보 요청 G-code
      // 여기에 프린터로부터 응답을 받아 파싱하는 로직을 구현해야 합니다.
      // 임시로 더미 데이터를 반환합니다.
      return type == 'nozzle' ? 200.0 : 60.0;
    } else {
      throw Exception('프린터에 연결되어 있지 않습니다.');
    }
  }

  void disconnect() {
    _dataSubscription?.cancel();
    connection?.close();
    connection = null;
    _connectionStatus = '연결 안됨';
    notifyListeners();
  }

  void updateTemperatures(double nozzle, double bed) {
    _currentTemperature = nozzle;
    _currentBedTemperature = bed;
    notifyListeners();
  }

  bool isConnected() {
    return connection != null && connection!.isConnected;
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }
}
