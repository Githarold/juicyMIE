import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';

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
    _addDummyDevices(); // 더미 데이터 추가
  }

  Future<void> _getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (error) {
      print('Error getting bonded devices: $error');
    }
    if (mounted) {
      setState(() {
        _devicesList = devices;
      });
    }
  }

  void _addDummyDevices() {
    setState(() {
      _devicesList.addAll([
        BluetoothDevice(name: 'Dummy Device 1', address: '00:11:22:33:44:55'),
        BluetoothDevice(name: 'Dummy Device 2', address: '66:77:88:99:AA:BB'),
        BluetoothDevice(name: 'Dummy Device 3', address: 'CC:DD:EE:FF:00:11'),
      ]);
    });
  }

  Future<void> _scanForDevices() async {
    // 주변 기기 찾기 로직 구현
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (context, index) {
                  final device = _devicesList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(device.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scanForDevices,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // 버튼 크기 조정
                textStyle: const TextStyle(fontSize: 18), // 텍스트 크기 조정
              ),
              child: const Text('주변 기기 찾기'),
            ),
          ],
        ),
      ),
    );
  }
}
