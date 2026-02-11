import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/desk_data.dart';
import '../repositories/view_repository.dart';
import 'my_desk_provider.dart';
import 'receive_file_provider.dart';
import 'share_provider.dart';


final viewRepositoryProvider = Provider<ViewRepository>((ref) => ViewRepository());

final viewControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final sendCodeControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

class ViewState {
  final bool isLoading;
  final bool changeControllerState;
  final DeskData? deskData;

  const ViewState({
    this.isLoading = false,
    this.changeControllerState = false,
    this.deskData,
  });

  ViewState copyWith({
    bool? isLoading,
    bool? changeControllerState,
    DeskData? deskData,
  }) {
    return ViewState(
      isLoading: isLoading ?? this.isLoading,
      changeControllerState: changeControllerState ?? this.changeControllerState,
      deskData: deskData ?? this.deskData,
    );
  }
}

class ViewNotifier extends StateNotifier<ViewState> {
  final Ref ref;

  ViewNotifier(this.ref) : super(const ViewState()) {
    ref.listen(sendCodeControllerProvider, (prev, next) {
      deskNameListener();
    });
  }

  ViewRepository get _viewRepo => ref.read(viewRepositoryProvider);

  void removeSharedFile(int index) {
    ref.read(receiveFileProvider.notifier).removeSharedFile(index);
  }

  void initialText({required String shareText, required String viewText}) {
    ref.read(viewControllerProvider).text = shareText.isNotEmpty ? shareText : viewText;
  }

  void storeInitialValues(String value) {
    ref.read(viewControllerProvider).text = value.trim();
  }

  Future<DeskData> fetchData(String deskId) async {
    state = state.copyWith(isLoading: true);
    try {
      final deskData = await _viewRepo.fetchData(deskId);
      ref.read(sendCodeControllerProvider).clear();
      final data = deskData.fold((l) => throw l, (r) => r);
      state = state.copyWith(deskData: data);
      return data;
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void editDesk() => ref.read(shareProvider.notifier).getEditFiles(ref.read(sendCodeControllerProvider).text);

  void resetControllerState() {
    state = state.copyWith(changeControllerState: false);
  }

  void checkDesk(String deskId) {
    ref.read(myDeskProvider.notifier).checkDesk(deskId);
  }

  void deskNameListener() {
    final sendText = ref.read(sendCodeControllerProvider).text;
    final isEdit = !sendText.contains('@') && sendText.length == 9;
    final isMyDeskCode = sendText.startsWith('@') && sendText.substring(1).length == 8;

    if (isMyDeskCode) {
      state = state.copyWith(changeControllerState: true);
      checkDesk(sendText);
    } else if (isEdit) {
      editDesk();
    } else {
      state = state.copyWith(changeControllerState: false);
    }
  }

  void updateControllerState() {
    final sendText = ref.read(sendCodeControllerProvider).text;
    final isMyDeskCode = sendText.startsWith('@') && sendText.substring(1).length >= 6;
    final isRegular = !sendText.startsWith('@') && sendText.length == 6;

    if (isMyDeskCode) {
      debugPrint('Is my desk code: ${ref.read(sendCodeControllerProvider).text}');
      checkDesk(sendText);
    } else if (isEdit) {
      editDesk();
    } else if (isRegular) {
      fetchData(sendText);
    }
  }

  bool get isEdit {
    final sendText = ref.read(sendCodeControllerProvider).text;
    return !sendText.startsWith('@') && sendText.length == 9;
  }

  void resetStates() {
    state = state.copyWith(changeControllerState: false);
    ref.read(sendCodeControllerProvider).clear();
    final shareNotifier = ref.read(shareProvider.notifier);
    shareNotifier.resetEdit();
    ref.read(shareControllerProvider).clear();
    shareNotifier.clearFiles();
  }
}

final viewProvider = StateNotifierProvider.autoDispose<ViewNotifier, ViewState>((ref) {
  return ViewNotifier(ref);
});

final checkDeskProvider = StateProvider((ref) => () {});