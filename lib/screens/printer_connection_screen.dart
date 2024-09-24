import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';
import 'package:flutter/foundation.dart';

class PrinterConnectionScreen extends StatefulWidget {
  const PrinterConnectionScreen({super.key});

  @override
  State<PrinterConnectionScreen> createState() => _PrinterConnectionScreenState();
}

class _PrinterConnectionScreenState extends State<PrinterConnectionScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _initializeDevices();
  }

  Future<void> _initializeDevices() async {
    await _getPairedDevices();
  }

  Future<void> _getPairedDevices() async {
    if (kDebugMode) {
      // 테스트 모드: 더미 데이터 사용
      setState(() {
        _devicesList = [
          BluetoothDevice(name: "테스트 프린터 1", address: "00:11:22:33:44:55"),
          BluetoothDevice(name: "테스트 프린터 2", address: "AA:BB:CC:DD:EE:FF"),
        ];
      });
    } else {
      // 실제 환경: 페어링된 기기 가져오기
      try {
        List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
        setState(() {
          _devicesList = devices;
        });
      } catch (error) {
        print('페어링된 기기를 가져오는 중 오류 발생: $error');
      }
    }
  }

  Future<void> _scanForDevices() async {
    // 주변 기기 찾기 로직 구현
    // 이 부분은 실제 블루투스 스캔 기능을 구현할 때 작성하면 됩니다.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('주변 기기 스캔 중...')),
    );
  }

  Future<void> _connectToDevice() async {
    if (_selectedDevice != null) {
      bool connected = await _bluetoothService.connectToPrinter(_selectedDevice!.address);
      if (!mounted) return;
      if (connected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프린터에 연결되었습니다: ${_selectedDevice!.name}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프린터에 연결할 수 없습니다: ${_selectedDevice!.name}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프린터 연결'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _devicesList.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: Text('페어링된 기기가 없습니다.')),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _devicesList.length,
                      itemBuilder: (context, index) {
                        final device = _devicesList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(device.name ?? '알 수 없는 기기', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(device.address),
                            trailing: IconButton(
                              icon: const Icon(Icons.bluetooth, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  _selectedDevice = device;
                                });
                                _connectToDevice();
                              },
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _scanForDevices,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('주변 기기 찾기'),
              ),
              const SizedBox(height: 16), // 버튼 아래에 여백 추가
            ],
          ),
        ),
      ),
    );
  }
}
