import 'dart:convert';
import 'dart:io';
import 'package:app_italien/models/list.model.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class FileService {
  // getApplicationDocumentsDirectory() = /data/user/0/com.example.app_italien/app_flutter
  // /Users/sgio/Library/Developer/CoreSimulator/Devices/8C6C1696-5E84-4722-9CFE-525F8081365E/data/Containers/Data/Application/F14684D8-F43D-4FC8-9659-8CC43D16AFA6/Documents

  Future<String> get _filePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/lists.json';
  }

  Future<File> _getLocalFile() async {
    final filePath = await _filePath;
    return File(filePath).create(recursive: true);
  }

  Future<File> writeFile(List<ListModel> list) async {
    final file = await _getLocalFile();

    return file.writeAsString(jsonEncode(list));
  }

  Future<List> readFile() async {
    //flutter: FormatException: Unexpected end of input (at character 1)
    try {
      final File file = await _getLocalFile();
      String contents = await file.readAsString();

      if (contents == '') {
        contents = await rootBundle.loadString('assets/datas/stock.json');
      }

      final contentArray = await jsonDecode(contents);

      return contentArray;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<File?> moveFile(File sourceFile) async {
    final filePath = await _filePath;
    try {
      return await sourceFile.rename(filePath);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
