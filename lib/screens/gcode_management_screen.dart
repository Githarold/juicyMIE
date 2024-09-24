import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/bluetooth_service.dart';
import '../services/file_service.dart';
import 'package:file_picker/file_picker.dart';

class GCodeManagementScreen extends StatefulWidget {
  const GCodeManagementScreen({super.key});

  @override
  State<GCodeManagementScreen> createState() => GCodeManagementScreenState();
}

class GCodeManagementScreenState extends State<GCodeManagementScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  late final FileService _fileService;
  List<Map<String, String>> gcodeFiles = [];

  @override
  void initState() {
    super.initState();
    _fileService = getFileService();
    _connectToPrinter();
    _loadFiles();
  }

  Future<void> _connectToPrinter() async {
    if (kIsWeb) return; // 웹에서는 블루투스 연결 건너뛰기
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

  Future<void> _loadFiles() async {
    try {
      List<String> files = await _fileService.getGCodeFiles();
      setState(() {
        gcodeFiles = files.map((file) {
          return {
            'name': file,
            'size': '1.0 MB', // 실제 파일 크기를 가져오는 로직 필요
            'date': DateTime.now().toString().split(' ')[0], // 실제 파일 생성 날짜를 가져오는 로직 필요
          };
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 로드 중 오류 발생: $e')),
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
    if (kIsWeb) {
      // 웹 환경에서의 출력 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('웹에서 ${file['name']} 파일 출력을 시뮬레이션합니다.')),
      );
      // 여기에 웹에서의 출력 로직을 추가할 수 있습니다.
    } else {
      // 네이티브 환경에서의 출력 처리
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

  Future<void> _deleteFile(int index) async {
    try {
      final fileName = gcodeFiles[index]['name'];
      if (fileName != null) {
        await _fileService.deleteGCodeFile(fileName);
        setState(() {
          gcodeFiles.removeAt(index);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileName 파일이 삭제되었습니다.')),
        );
      } else {
        throw Exception('파일 이름이 없습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 삭제 중 오류 발생: $e')),
      );
    }
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

  Future<void> _addFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowedExtensions: null,
      );

      if (result != null) {
        String fileName = result.files.single.name;
        if (kIsWeb) {
          await _fileService.uploadGCodeFileWeb(result.files.single.bytes!, fileName);
        } else {
          await _fileService.uploadGCodeFile(result.files.single.path!, fileName);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileName 업로드됨')),
        );
        await _loadFiles();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 업로드 중 오류 발생: $e')),
      );
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _bluetoothService.disconnect();
    }
    super.dispose();
  }
}
