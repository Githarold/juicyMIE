import 'package:flutter/material.dart';
import 'gcode_management_screen.dart';
import 'print_progress_screen.dart';
import 'settings_screen.dart';
import 'printer_connection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D 프린터'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // 정보 화면 이동
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('상태:', style: TextStyle(fontSize: 16)),
                Text('연결됨', style: TextStyle(color: Colors.green[700], fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('노즐 온도:', style: TextStyle(fontSize: 16)),
                Text('200°C', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('베드 온도:', style: TextStyle(fontSize: 16)),
                Text('60°C', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
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
}
