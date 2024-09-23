import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class GCodeManagementScreen extends StatefulWidget {
  const GCodeManagementScreen({super.key});

  @override
  State<GCodeManagementScreen> createState() => GCodeManagementScreenState();
}

class GCodeManagementScreenState extends State<GCodeManagementScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  List<Map<String, String>> gcodeFiles = [
    {'name': 'File1.gcode', 'size': '1.2 MB', 'date': '2023-05-01'},
    {'name': 'File2.gcode', 'size': '0.8 MB', 'date': '2023-05-02'},
  ];

  @override
  void initState() {
    super.initState();
    _connectToPrinter();
  }

  Future<void> _connectToPrinter() async {
    // 여기에 프린터의 블루투스 주소를 입력하세요
    const String printerAddress = '00:00:00:00:00:00';
    bool connected = await _bluetoothService.connectToPrinter(printerAddress);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(connected ? '프린터에 연결되었습니다.' : '프린터 연결에 실패했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('파일 목록'),
      ),
      body: ListView.builder(
        itemCount: gcodeFiles.length,
        itemBuilder: (context, index) {
          final file = gcodeFiles[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(file['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Size: ${file['size']} | Created: ${file['date']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.print, color: Colors.blue),
                    onPressed: () => _startPrinting(file),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteFile(index),
                  ),
                ],
              ),
              onTap: () => _showFileDetails(file),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        tooltip: '파일 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _startPrinting(Map<String, String> file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('출력 시작'),
          content: Text('${file['name']} 파일의 출력을 시작하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('시작'),
              onPressed: () {
                Navigator.of(context).pop();
                _startPrintingProcess(file);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _startPrintingProcess(Map<String, String> file) async {
    if (_bluetoothService.connection != null && _bluetoothService.connection!.isConnected) {
      await _bluetoothService.startPrinting(file['name']!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${file['name']} 출력이 시작되었습니다.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프린터에 연결되지 않았습니다.')),
        );
      }
    }
  }

  void _confirmDeleteFile(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('파일 삭제 확인'),
          content: const Text('파일을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFile(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFile(int index) {
    setState(() {
      gcodeFiles.removeAt(index);
    });
  }

  void _showFileDetails(Map<String, String> file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(file['name'] ?? ''),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('크기: ${file['size']}'),
              Text('생성일: ${file['date']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addFile() {
    print('파일 추가 기능');
  }

  @override
  void dispose() {
    _bluetoothService.disconnect();
    super.dispose();
  }
}

