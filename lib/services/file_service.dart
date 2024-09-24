import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

abstract class FileService {
  Future<List<String>> getGCodeFiles();
  Future<void> uploadGCodeFile(String filePath, String fileName);
  Future<void> deleteGCodeFile(String fileName);
  Future<void> uploadGCodeFileWeb(List<int> fileBytes, String fileName);
}

FileService getFileService() {
  if (kIsWeb) {
    return WebFileService();
  } else {
    return NativeFileService();
  }
}

class WebFileService implements FileService {
  final List<String> _webFiles = [
    'example1.gcode',
    'example2.gcode',
    'example3.gcode',
  ];

  @override
  Future<List<String>> getGCodeFiles() async {
    return _webFiles;
  }

  @override
  Future<void> uploadGCodeFile(String filePath, String fileName) async {
    throw UnimplementedError('웹에서는 uploadGCodeFile을 사용할 수 없습니다.');
  }

  @override
  Future<void> uploadGCodeFileWeb(List<int> fileBytes, String fileName) async {
    _webFiles.add(fileName);
  }

  @override
  Future<void> deleteGCodeFile(String fileName) async {
    _webFiles.remove(fileName);
  }
}

class NativeFileService implements FileService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Future<List<String>> getGCodeFiles() async {
    final path = await _localPath;
    final dir = Directory(path);
    List<String> files = dir
        .listSync()
        .where((item) => item.path.toLowerCase().endsWith('.gcode'))
        .map((item) => item.path.split('/').last)
        .toList();
    
    // 테스트를 위한 더미 데이터 추가
    if (files.isEmpty) {
      files = ['example1.gcode', 'example2.gcode', 'example3.gcode'];
    }
    
    return files;
  }

  @override
  Future<void> uploadGCodeFile(String filePath, String fileName) async {
    final path = await _localPath;
    final file = File('$path/$fileName');
    await file.writeAsBytes(await File(filePath).readAsBytes());
  }

  @override
  Future<void> uploadGCodeFileWeb(List<int> fileBytes, String fileName) async {
    // 네이티브 플랫폼에서는 사용되지 않음
    throw UnimplementedError('네이티브 플랫폼에서는 uploadGCodeFileWeb을 사용할 수 없습니다.');
  }

  @override
  Future<void> deleteGCodeFile(String fileName) async {
    final path = await _localPath;
    final file = File('$path/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
