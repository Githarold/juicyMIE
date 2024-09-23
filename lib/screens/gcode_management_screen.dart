import 'package:flutter/material.dart';

class GCodeManagementScreen extends StatefulWidget {
  const GCodeManagementScreen({Key? key}) : super(key: key);

  @override
  _GCodeManagementScreenState createState() => _GCodeManagementScreenState();
}

class _GCodeManagementScreenState extends State<GCodeManagementScreen> {
  List<Map<String, String>> gcodeFiles = [
    {'name': 'File1.gcode', 'size': '1.2 MB', 'date': '2023-05-01'},
    {'name': 'File2.gcode', 'size': '0.8 MB', 'date': '2023-05-02'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('G-code Files'),
      ),
      body: ListView.builder(
        itemCount: gcodeFiles.length,
        itemBuilder: (context, index) {
          final file = gcodeFiles[index];
          return ListTile(
            title: Text(file['name'] ?? ''),
            subtitle: Text('Size: ${file['size']} | Created: ${file['date']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Add file deletion logic here
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add file addition logic here
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
