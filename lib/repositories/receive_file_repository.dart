import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class ReceiveFileRepository {
  Future<File?> copySharedFile(SharedFile sharedFile) async {
    try {
      final file = File(sharedFile.value!);
      if (await file.exists()) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(file.path);
        final newFile = await file.copy('${appDir.path}/$fileName');
        return newFile;
      }
      return null;
    } catch (e) {
      debugPrint('Error accessing shared file: $e');
      return null;
    }
  }

  Future<String?> saveSharedText(String text) async {
    try {
      if (text.isNotEmpty) {
        final appDir = await getApplicationDocumentsDirectory();
        final file = File(
            '${appDir.path}/shared_text_${DateTime.now().millisecondsSinceEpoch}.txt');
        await file.writeAsString(text);
        return text;
      }
      return null;
    } catch (e) {
      debugPrint('Error saving shared text: $e');
      return null;
    }
  }
}

final receiveFileRepositoryProvider = Provider<ReceiveFileRepository>((ref) => ReceiveFileRepository());
