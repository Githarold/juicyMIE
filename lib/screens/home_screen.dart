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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프린터 상태',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('상태:'),
                        Text('연결됨', style: TextStyle(color: Colors.green[700])),
                      ],
    
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('노즐 온도:'),
                        Text('200°C'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('베드 온도:'),
                        Text('60°C'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '빠른 작업',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildQuickActionCard(
                  context,
                  '새 프린트 시작',
                  Icons.play_arrow,
                  Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GCodeManagementScreen())),
                ),
                _buildQuickActionCard(
                  context,
                  '진행 중인 프린트',
                  Icons.assessment,
                  Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrintProgressScreen())),
                ),
                _buildQuickActionCard(
                  context,
                  '설정',
                  Icons.settings,
                  Colors.grey,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                ),
                _buildQuickActionCard(
                  context,
                  '프린터 연결',
                  Icons.bluetooth,
                  Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrinterConnectionScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
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
