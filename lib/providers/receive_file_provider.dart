import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class ReceiveFileProvider extends ChangeNotifier {
  /// Remove a shared file by index and notify listeners
  void removeSharedFile(int index) {
    if (index >= 0 && index < _sharedFiles.length) {
      _sharedFiles.removeAt(index);
      notifyListeners();
    }
  }
  StreamSubscription? _intentSub;
  StreamSubscription? get intentSub => _intentSub;

  File? _file;                          // For shared files
  String? _sharedText;                  // For shared text
  File? get file => _file;
  String? get sharedText => _sharedText;

  final List<SharedFile> _sharedFiles = [];
  List<SharedFile> get sharedFiles => _sharedFiles;

  // Handle shared files
  Future<File?> getSharedFile(SharedFile sharedFile) async {
  
    try {
      final file = File(sharedFile.value!);
      if (await file.exists()) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(file.path);
        _file = await file.copy('${appDir.path}/$fileName');
        debugPrint('File saved to: ${_file?.path}');
        notifyListeners();
        return _file;
      } else {
        debugPrint('Shared file does not exist: ${sharedFile.value}');
        return null;
      }
    } catch (e) {
      debugPrint('Error accessing shared file: $e');
      return null;
    }
  }

  // Handle shared text
  Future<String?> saveSharedText(String text) async {
    try {
      if (text.isNotEmpty) {
        _sharedText = text;
        // Optionally save text to a file
        final appDir = await getApplicationDocumentsDirectory();
        final file = File('${appDir.path}/shared_text_${DateTime.now().millisecondsSinceEpoch}.txt');
        await file.writeAsString(text);
        debugPrint('Text saved to: ${file.path}');
        notifyListeners();
        return text;
      }
    } catch (e) {
      debugPrint('Error saving shared text: $e');
      return null;
    }
    return null;
  }

  // Update subscription for both media and text
  void updateIntentSub() {
    _intentSub = FlutterSharingIntent.instance.getMediaStream().listen((value) async {
      debugPrint('Received shared content: ${value.map((f) => f.toString())}');
      
      final processedFiles = <SharedFile>[];
      for (var sharedItem in value) {
        if (sharedItem.type == SharedMediaType.FILE || 
            sharedItem.type == SharedMediaType.IMAGE || 
            sharedItem.type == SharedMediaType.VIDEO) {
          final file = await getSharedFile(sharedItem);
          if (file != null) {
            processedFiles.add(sharedItem);
          }
        } else if (sharedItem.type == SharedMediaType.TEXT) {
          await saveSharedText(sharedItem.value!); // Text is passed in path for text type
        }
      }
      _sharedFiles.clear();
      _sharedFiles.addAll(processedFiles);
      notifyListeners();
    });
  }

  // Get initial media and text
  void getInitialContent() {
    FlutterSharingIntent.instance.getInitialSharing().then((value) async {
      debugPrint('Initial shared content: ${value.map((f) => f.toString())}');
      
      final processedFiles = <SharedFile>[];
      for (var sharedItem in value) {
        if (sharedItem.type == SharedMediaType.FILE || 
            sharedItem.type == SharedMediaType.IMAGE || 
            sharedItem.type == SharedMediaType.VIDEO) {
          final file = await getSharedFile(sharedItem);
          if (file != null) {
            processedFiles.add(sharedItem);
          }
        } else if (sharedItem.type == SharedMediaType.TEXT) {
          await saveSharedText(sharedItem.value!); // Text is passed in path
        }
      }
      _sharedFiles.clear();
      _sharedFiles.addAll(processedFiles);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }
}