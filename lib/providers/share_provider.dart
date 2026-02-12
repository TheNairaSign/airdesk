import 'dart:io';
import 'package:air_desk/core/failures/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/desk_data.dart';
import '../model/history_model.dart';
import '../model/image_data.dart';
import '../repositories/share_repository.dart';
import '../services/desk_cache_service.dart';
import 'history_provider.dart';
import 'receive_file_provider.dart';
import 'view_provider.dart';


abstract class SubmitResult {}

class PostDataSuccess extends SubmitResult {
  final Map<String, dynamic> data;
  PostDataSuccess(this.data);
}

class DeskSubmitSuccess extends SubmitResult {}

class UpdateEditSuccess extends SubmitResult {}

class FetchDataSuccess extends SubmitResult {
  final DeskData data;
  FetchDataSuccess(this.data);
}


final shareRepositoryProvider = Provider<ShareRepository>((ref) => ShareRepository());
final shareControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

class EditFile {
  final String url;
  final String originalName;
  EditFile({required this.url, required this.originalName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditFile &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          originalName == other.originalName;

  @override
  int get hashCode => url.hashCode ^ originalName.hashCode;
}

class ShareState {
  final bool isLoading;
  final List<File> files;
  final bool isLive;
  final List<EditFile> editFiles;
  final List<EditFile> initialEditFiles;
  final String? editAdminCode;
  final bool isEdit;

  const ShareState({
    this.isLoading = false,
    this.files = const [],
    this.isLive = false,
    this.editFiles = const [],
    this.initialEditFiles = const [],
    this.editAdminCode,
    this.isEdit = false,
  });

  ShareState copyWith({
    bool? isLoading,
    List<File>? files,
    bool? isLive,
    List<EditFile>? editFiles,
    List<EditFile>? initialEditFiles,
    String? editAdminCode,
    bool? isEdit,
    bool forceEditAdminCode = false,
  }) {
    return ShareState(
      isLoading: isLoading ?? this.isLoading,
      files: files ?? this.files,
      isLive: isLive ?? this.isLive,
      editFiles: editFiles ?? this.editFiles,
      initialEditFiles: initialEditFiles ?? this.initialEditFiles,
      editAdminCode: forceEditAdminCode ? editAdminCode : (editAdminCode ?? this.editAdminCode),
      isEdit: isEdit ?? this.isEdit,
    );
  }
}

class ShareNotifier extends StateNotifier<ShareState> {
  final Ref ref;
  ShareNotifier(this.ref) : super(const ShareState());

  ShareRepository get _shareRepo => ref.read(shareRepositoryProvider);

  void removeEditFileByPath(String url) {
    final newFiles = state.files.where((f) => f.path != url).toList();
    state = state.copyWith(files: newFiles);
  }

  void setIsLive(bool value) {
    state = state.copyWith(isLive: value);
  }

  void resetEdit() {
    state = state.copyWith(isEdit: false);
  }

  bool isNetworkFile(String filePath) {
    return filePath.startsWith('http') || filePath.startsWith('https');
  }

  Future<void> getEditFiles(String editCode) async {
    state = state.copyWith(isLoading: true);
    try {
      final editData = await _shareRepo.getEditFiles(editCode);
      
      final initialEditFiles = (editData['images'] as List)
          .map((img) =>
              EditFile(url: img['url'], originalName: img['originalName']))
          .toList();

      final newFiles = (editData['images'] as List)
          .map((img) => ImageData.fromJson(img))
          .toList();
      
      final Set<String> seenNames = {};
      final List<EditFile> editFiles = [];
      for (var fileData in newFiles) {
        final filePath = fileData.url;
        final originalName = fileData.originalName;
        if (filePath != null && originalName != null) {
          if (!seenNames.contains(originalName)) {
            seenNames.add(originalName);
            editFiles.add(EditFile(url: fileData.url!, originalName: originalName));
          }
        }
      }

      ref.read(shareControllerProvider).text = editData['text'];

      state = state.copyWith(
        isEdit: true,
        initialEditFiles: initialEditFiles,
        editFiles: editFiles,
        editAdminCode: editData['editCode'],
        files: [],
      );
    } catch (error) {
      state = state.copyWith(isEdit: false);
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void onRemove(int index, List<SharedFile> sharedFiles) {
    if (index < state.files.length) {
      final newFiles = List<File>.from(state.files)..removeAt(index);
      state = state.copyWith(files: newFiles);
    } else if (index < state.files.length + state.editFiles.length) {
      int editIndex = index - state.files.length;
      final newEditFiles = List<EditFile>.from(state.editFiles)..removeAt(editIndex);
      state = state.copyWith(editFiles: newEditFiles);
    } else {
      int sharedIndex = index - state.files.length - state.editFiles.length;
      ref.read(receiveFileProvider.notifier).removeSharedFile(sharedIndex);
    }
  }

  List<EditFile> getEditedFiles() {
    final editPaths = state.editFiles.map((e) => e.url).toSet();
    return state.initialEditFiles.where((f) => !editPaths.contains(f.url)).toList();
  }

  Future<Either<Failure, Unit>> updateEdit() async {
    state = state.copyWith(isLoading: true);
    final removedFiles = getEditedFiles().map((e) => Uri.parse(e.url).pathSegments.last).toList();

    try {
      final result = await _shareRepo.updateEdit(
        editAdminCode: state.editAdminCode!,
        content: ref.read(shareControllerProvider).text,
        imagesToRemove: removedFiles,
        newFiles: state.files,
      );
      
      return result.fold(
        (l) => Left(l),
        (r) {
          ref.read(shareControllerProvider).clear();
          state = state.copyWith(
            editAdminCode: '',
            isEdit: false,
            initialEditFiles: [],
            editFiles: [],
            files: [],
            forceEditAdminCode: true,
          );
          return const Right(unit);
        }
      );
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Either<Failure, SubmitResult>> submit() async {
    final viewNotifier = ref.read(viewProvider.notifier);
    final viewState = ref.read(viewProvider);
    final sendCodeController = ref.read(sendCodeControllerProvider);
    final shareController = ref.read(shareControllerProvider);
    final receiveFileNotifier = ref.read(receiveFileProvider);

    final deskName = sendCodeController.text.trim();
    final sendToDesk = viewState.changeControllerState;
    final isEdit = viewNotifier.isEdit;
    final viewText = sendCodeController.text;
    final isView = shareController.text.isEmpty && (viewText.isNotEmpty && !viewText.startsWith('@') && viewText.length == 6);

    if (sendToDesk) {
      final result = await submitToDesk(deskName);
      return result.map((_) => DeskSubmitSuccess());
    } else if (isEdit) {
      final result = await updateEdit();
      return result.map((_) => UpdateEditSuccess());
    } else if (isView) {
      sendCodeController.clear();
      final result = await viewNotifier.fetchData(viewText);
      return result.map((data) => FetchDataSuccess(data));
    } else {
      final result = await postData(receiveFileNotifier.sharedFiles);
      return result.map((data) => PostDataSuccess(data));
    }
  }

  Future<Either<Failure, Unit>> submitToDesk(String deskName) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _shareRepo.submitToDesk(
        deskName: deskName,
        content: ref.read(shareControllerProvider).text,
        files: state.files,
      );

      return result.fold(
        (l) => Left(l),
        (r) async {
          await DeskCacheService().cacheDeskCode(deskName);
          ref.read(shareControllerProvider).clear();
          clearFiles();
          return const Right(unit);
        }
      );
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> pickFiles() async {
    final newFiles = await _shareRepo.pickFiles();
    state = state.copyWith(files: [...state.files, ...newFiles]);
  }

  void clearFiles() {
    state = state.copyWith(files: [], editFiles: []);
    ref.read(receiveFileProvider.notifier).clearFiles();
  }

  Future<Either<Failure, Map<String, dynamic>>> postData(List<SharedFile> sharedFiles) async {
    state = state.copyWith(isLoading: true);
    try {
      final responseData = await _shareRepo.postData(
        content: ref.read(shareControllerProvider).text,
        isLive: state.isLive,
        localFiles: state.files,
        sharedFilePaths: sharedFiles.map((e) => e.value ?? "").toList(),
      );

    return responseData.fold(
        (l) => Left(l), 
        (r) async {
          await addNewHistoryItem(r["data"]["code"], r);
          clearFiles();
          return Right(r);
        }
      );
    } catch (e) {
      debugPrint('Error in postData: $e');
      return Left(ServerFailure(e.toString()));
    } finally {
      state = state.copyWith(isLoading: false);
      ref.read(shareControllerProvider).clear();
    }
  }

  Future<void> addNewHistoryItem(
    String generatedCode,
    Map<String, dynamic> responseData, 
  ) async {
    final historyProvider = ref.read(historyNotifierProvider.notifier);
    List<HistoryItem> existingHistory = await historyProvider.getHistoryItems();

    HistoryItem newItem = HistoryItem(
      code: generatedCode,
      id: responseData['data']['_id'],
      editCode: responseData['data']['editCode'],
      type: responseData['data']['deskType'],
      createdAt: responseData['data']['createdAt'],
    );

    existingHistory.add(newItem);
    await historyProvider.updateHistory(existingHistory);
  }
}

final shareProvider = StateNotifierProvider.autoDispose<ShareNotifier, ShareState>((ref) => ShareNotifier(ref));
