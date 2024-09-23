import 'package:flutter/material.dart';

class PrintProgressScreen extends StatefulWidget {
  const PrintProgressScreen({Key? key}) : super(key: key);

  @override
  _PrintProgressScreenState createState() => _PrintProgressScreenState();
}

class _PrintProgressScreenState extends State<PrintProgressScreen> {
  double progress = 0.65; // Example progress
  String status = 'Printing';
  int currentLayer = 42;
  int totalLayers = 100;
  double nozzleTemp = 200.5;
  double bedTemp = 60.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Progress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  onPressed: () {
                    // Add stop logic here
                  },
                  child: const Text('Stop'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
