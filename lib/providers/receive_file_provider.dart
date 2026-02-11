import 'dart:async';


import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import '../repositories/receive_file_repository.dart';

class ReceiveFileNotifier extends StateNotifier<ReceiveFileState> {
  final ReceiveFileRepository _receiveFileRepository;
  StreamSubscription? _intentSub;

  ReceiveFileNotifier(this._receiveFileRepository) : super(const ReceiveFileState());

  /// Remove a shared file by index
  void removeSharedFile(int index) {
    if (index >= 0 && index < state.sharedFiles.length) {
      final updated = List<SharedFile>.from(state.sharedFiles)..removeAt(index);
      state = state.copyWith(sharedFiles: updated);
    }
  }

  /// Clear all shared files
  void clearFiles() {
    state = state.copyWith(sharedFiles: []);
  }

  StreamSubscription? get intentSub => _intentSub;

  String? get sharedText => state.sharedText;

  List<SharedFile> get sharedFiles => state.sharedFiles;

  // Handle shared files
  Future<void> _handleSharedFiles(List<SharedFile> value) async {
    final processedFiles = <SharedFile>[];
    String? newText = state.sharedText;
    for (var sharedItem in value) {
      if (sharedItem.type == SharedMediaType.FILE ||
          sharedItem.type == SharedMediaType.IMAGE ||
          sharedItem.type == SharedMediaType.VIDEO) {
        final file = await _receiveFileRepository.copySharedFile(sharedItem);
        if (file != null) {
          processedFiles.add(sharedItem);
        }
      } else if (sharedItem.type == SharedMediaType.TEXT) {
        newText = await _receiveFileRepository.saveSharedText(sharedItem.value!);
      }
    }
    state = state.copyWith(
      sharedFiles: processedFiles,
      sharedText: newText,
    );
  }

  // Update subscription for both media and text
  void listenToSharingIntent() {
    _intentSub = FlutterSharingIntent.instance.getMediaStream().listen((value) async {
      await _handleSharedFiles(value);
    });
  }

  // Get initial media and text
  void getInitialContent() {
    FlutterSharingIntent.instance.getInitialSharing().then((value) async {
      await _handleSharedFiles(value);
    });
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }
}

class ReceiveFileState {
  final List<SharedFile> sharedFiles;
  final String? sharedText;

  const ReceiveFileState({
    this.sharedFiles = const [],
    this.sharedText,
  });

  ReceiveFileState copyWith({
    List<SharedFile>? sharedFiles,
    String? sharedText,
  }) {
    return ReceiveFileState(
      sharedFiles: sharedFiles ?? this.sharedFiles,
      sharedText: sharedText ?? this.sharedText,
    );
  }
}

final receiveFileProvider = StateNotifierProvider<ReceiveFileNotifier, ReceiveFileState>(
  (ref) {
    final repo = ref.watch(receiveFileRepositoryProvider);
    return ReceiveFileNotifier(repo)
      ..getInitialContent()
      ..listenToSharingIntent();
  },
);
