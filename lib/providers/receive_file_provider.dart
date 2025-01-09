import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;


class ReceiveFileProvider extends ChangeNotifier {
  StreamSubscription? _intentSub;
  StreamSubscription? get intentSub => _intentSub;

  File? _file;
  File? get file => _file;

  final List<SharedMediaFile> _sharedFiles = [];
  List<SharedMediaFile> get sharedFiles => _sharedFiles;

  Future<File?> getSharedFile(SharedMediaFile sharedFile) async {
    try {
      final file = File(sharedFile.path);
      if (await file.exists()) {
        // Copy file from cache to app's documents directory for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(file.path);
        _file = await file.copy('${appDir.path}/$fileName');
        debugPrint('File saved to: ${_file?.path}');
        notifyListeners();
      } else {
        debugPrint('Shared file does not exist: ${sharedFile.path}');
        // return null;
      }
    } catch (e) {
      debugPrint('Error accessing shared file: $e');
      // return null;
    }
    notifyListeners();
    return _file;
  }

  void updateIntentSub() {
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) async {
      debugPrint('Received shared files: ${value.map((f) => f.toMap())}');
      
      final processedFiles = <SharedMediaFile>[];
      for (var sharedFile in value) {
        final file = await getSharedFile(sharedFile);
        if (file != null) {
          processedFiles.add(sharedFile);
          notifyListeners();
        }
      }
      _sharedFiles.clear();
      _sharedFiles.addAll(processedFiles);
    });
    // notifyListeners();
  }

  void getInitialMedia() {
    ReceiveSharingIntent.instance.getInitialMedia().then((value) async {
      debugPrint('Initial shared files: ${value.map((f) => f.toMap())}');
      
      final processedFiles = <SharedMediaFile>[];
      for (var sharedFile in value) {
        final file = await getSharedFile(sharedFile);
        if (file != null) {
          processedFiles.add(sharedFile);
          notifyListeners();
        }
      }
        _sharedFiles.clear();
        _sharedFiles.addAll(processedFiles);
      });
      // notifyListeners();
    }

    @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }
}