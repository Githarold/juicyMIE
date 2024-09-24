import 'package:flutter/material.dart';
import 'gcode_management_screen.dart';
import 'print_progress_screen.dart';
import 'settings_screen.dart';
import 'printer_connection_screen.dart';
import 'info_screen.dart';
import '../services/bluetooth_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const HomeScreen({super.key, required this.bluetoothService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  double? nozzleTemp;
  double? bedTemp;
  Timer? _updateTimer;
  static const Duration updateInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _checkPrinterConnection();
    _startPeriodicUpdate();
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(updateInterval, (timer) {
      _updatePrinterStatus();
    });
  }

  Future<void> _checkPrinterConnection() async {
    const String printerAddress = '00:00:00:00:00:00'; // 실제 프린터 주소로 변경해야 합니다
    bool connected = await widget.bluetoothService.connectToPrinter(printerAddress);
    setState(() {
      isConnected = connected;
    });
    if (connected) {
      _updatePrinterStatus();
    } else {
      setState(() {
        nozzleTemp = null;
        bedTemp = null;
      });
    }
  }

  Future<void> _updatePrinterStatus() async {
    if (isConnected) {
      try {
        double nozzle = await widget.bluetoothService.getTemperature('nozzle');
        double bed = await widget.bluetoothService.getTemperature('bed');
        setState(() {
          nozzleTemp = nozzle;
          bedTemp = bed;
        });
      } catch (e) {
        print('온도 업데이트 중 오류 발생: $e');
        setState(() {
          nozzleTemp = null;
          bedTemp = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('과즙 MIE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPrinterStatusCard(context),
            const SizedBox(height: 24),
            _buildQuickActionsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('프린터 상태', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildStatusChip(isConnected ? '연결됨' : '연결 안됨', isConnected ? Colors.green : Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            _buildTemperatureRow('노즐 온도', nozzleTemp, 250),
            const SizedBox(height: 8),
            _buildTemperatureRow('베드 온도', bedTemp, 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildTemperatureRow(String label, double? temperature, double maxTemp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          temperature != null ? '${temperature.toStringAsFixed(1)}°C' : '-- °C',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildQuickActionCard(
                context,
                '새 프린트 시작',
                Icons.play_arrow,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GCodeManagementScreen()),
                ),
              );
            case 1:
              return _buildQuickActionCard(
                context,
                '진행 중인 프린트',
                Icons.assessment,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrintProgressScreen()),
                ),
              );
            case 2:
              return _buildQuickActionCard(
                context,
                '설정',
                Icons.settings,
                Colors.grey,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
              );
            case 3:
              return _buildQuickActionCard(
                context,
                '프린터 연결',
                Icons.bluetooth,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrinterConnectionScreen()),
                ),
              );
            default:
              return Container();
          }
        },
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    widget.bluetoothService.disconnect();
    super.dispose();
  }
}
