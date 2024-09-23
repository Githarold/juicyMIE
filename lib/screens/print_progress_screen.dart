import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart'; // BluetoothService를 가져오기 위해 추가

class PrintProgressScreen extends StatefulWidget {
  final bool isTestMode; // 테스트 모드를 위한 플래그 추가

  const PrintProgressScreen({super.key, this.isTestMode = true});

  @override
  State<PrintProgressScreen> createState() => PrintProgressScreenState();
}

class PrintProgressScreenState extends State<PrintProgressScreen> {
  double progress = 0.65; // Example progress
  String status = '출력 중';
  int currentLayer = 42;
  int totalLayers = 100;
  double nozzleTemp = 200.5;
  double bedTemp = 60.0;
  bool isConnected = true; // 프린터 연결 상태를 나타내는 변수
  final BluetoothService _bluetoothService = BluetoothService(); // BluetoothService 인스턴스 추가

  @override
  void initState() {
    super.initState();
    if (!widget.isTestMode) {
      _checkPrinterConnection();
    }
  }

  Future<void> _checkPrinterConnection() async {
    // 여기에 프린터의 블루투스 주소를 입력하세요
    const String printerAddress = '00:00:00:00:00:00';
    bool connected = await _bluetoothService.connectToPrinter(printerAddress);
    setState(() {
      isConnected = connected;
    });
  }

  Color getProgressColor(double progress) {
    return ColorTween(
      begin: Colors.red,
      end: Colors.green,
    ).lerp(progress)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('진행 상황'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isConnected) // 연결 상태에 따른 에러 메시지 표시
              Center(
                child: Text(
                  '프린터가 연결되지 않았습니다.',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              )
            else ...[
              Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 30,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(getProgressColor(progress)),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'Complete',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Status: $status', style: Theme.of(context).textTheme.titleLarge),
              Text('Estimated time remaining: 2h 15m'),
              Text('Layer: $currentLayer / $totalLayers'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nozzle: ${nozzleTemp.toStringAsFixed(1)}°C'),
                  Text('Bed: ${bedTemp.toStringAsFixed(1)}°C'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add pause/resume logic here
                    },
                    child: const Text('Pause/Resume'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      // Add stop logic here
                    },
                    child: const Text('Stop'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
