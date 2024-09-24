import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  BluetoothConnection? connection;

  Future<bool> connectToPrinter(String address) async {
    try {
      connection = await BluetoothConnection.toAddress(address);
      print('Connected to the printer');
      return true;
    } catch (error) {
      print('Cannot connect, exception occurred');
      print(error);
      return false;
    }
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
      print('Not connected to printer');
    }
  }

  Future<double> getNozzleTemperature() async {
    if (connection != null && connection!.isConnected) {
      await sendGCode('M105'); // 온도 정보 요청 G-code
      // 여기에 프린터로부터 응답을 받아 파싱하는 로직을 구현해야 합니다.
      // 임시로 더미 데이터를 반환합니다.
      return 200.0;
    } else {
      throw Exception('프린터에 연결되어 있지 않습니다.');
    }
  }

  Future<double> getBedTemperature() async {
    if (connection != null && connection!.isConnected) {
      await sendGCode('M105'); // 온도 정보 요청 G-code
      // 여기에 프린터로부터 응답을 받아 파싱하는 로직을 구현해야 합니다.
      // 임시로 더미 데이터를 반환합니다.
      return 60.0;
    } else {
      throw Exception('프린터에 연결되어 있지 않습니다.');
    }
  }

  Future<void> startPrinting(String fileName) async {
    if (connection != null && connection!.isConnected) {
      try {
        // 여기에 실제 G-code 파일을 읽고 전송하는 로직을 구현합니다.
        // 예를 들어:
        // 1. 파일 시스템에서 G-code 파일을 읽습니다.
        // 2. 파일의 각 라인을 sendGCode 메서드를 사용하여 전송합니다.
        await sendGCode('M23 $fileName'); // 파일 선택
        await sendGCode('M24'); // 출력 시작
        print('Started printing $fileName');
      } catch (error) {
        print('Error starting print: $error');
      }
    } else {
      print('Not connected to printer');
    }
  }

  void disconnect() {
    if (connection != null) {
      connection!.dispose();
      connection = null;
    }
  }
}
