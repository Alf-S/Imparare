import 'dart:convert';
import 'dart:io';
import 'package:app_italien/models/list.model.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  // getApplicationDocumentsDirectory() = /data/user/0/com.example.app_italien/app_flutter
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getLocalFile() async {
    final repositoryPath = await _localPath;
    final filePath = '$repositoryPath/lists.json';
    return File(filePath).create(recursive: true);
  }

  Future<File> writeFile(List<ListModel> list) async {
    final file = await _getLocalFile();

    return file.writeAsString(jsonEncode(list));
  }

  Future<List> readFile() async {
    try {
      final file = await _getLocalFile();
      final contents = await file.readAsString();
      final contentArray = await jsonDecode(contents);
      return contentArray;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
