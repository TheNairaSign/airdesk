import 'package:dartz/dartz.dart';
import 'package:air_desk/core/failures/failure.dart';
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

  Future<Either<Failure, ViewSubmitResult>> submitView() async {
    final sendText = ref.read(sendCodeControllerProvider).text;
    final isMyDeskCode = sendText.startsWith('@') && sendText.substring(1).length >= 6;
    final isEdit = !sendText.contains('@') && sendText.length == 9;
    final isRegular = !sendText.startsWith('@') && sendText.length == 6;

    if (isMyDeskCode) {
      debugPrint('Is my desk code: ${ref.read(sendCodeControllerProvider).text}');
      final result = await checkDesk(sendText);
      return result.map((exists) => DeskCheckSuccess(exists ?? false));
    } else if (isEdit) {
      final result = await editDesk();
      return result.map((_) => EditFilesSuccess());
    } else if (isRegular) {
      final result = await fetchData(sendText);
      return result.map((data) => FetchDeskSuccess(data));
    } else {
      return Left(Failure("Invalid code format"));
    }
  }

  Future<Either<Failure, DeskData>> fetchData(String deskId) async {
    state = state.copyWith(isLoading: true);
    try {
      final deskData = await _viewRepo.fetchData(deskId);
      return deskData.fold(
        (l) => Left(l),
        (r) {
          if (mounted) {
            ref.read(sendCodeControllerProvider).clear();
            state = state.copyWith(deskData: r);
          }
          return Right(r);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<Either<Failure, Unit>> editDesk() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(shareProvider.notifier).getEditFiles(ref.read(sendCodeControllerProvider).text);
       return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  } 

  void resetControllerState() {
    state = state.copyWith(changeControllerState: false);
  }

  Future<Either<Failure, bool?>> checkDesk(String deskId) async {
     try {
      final result = await ref.read(myDeskProvider.notifier).checkDesk(deskId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  void deskNameListener() {
    final sendText = ref.read(sendCodeControllerProvider).text;
    final isEdit = !sendText.contains('@') && sendText.length == 9;
    final isMyDeskCode = sendText.startsWith('@') && sendText.substring(1).length == 8;

    if (isMyDeskCode) {
      state = state.copyWith(changeControllerState: true);
      // checkDesk(sendText); // Optimistic check can stay if needed but suppressing errors
       ref.read(myDeskProvider.notifier).checkDesk(sendText);
    } else if (isEdit) {
      // editDesk(); // Don't auto-fetch edits on typing? existing logic seemed to allow it.
      // But submitView is better for actions.
      // Keeping state update only for now
    } else {
      state = state.copyWith(changeControllerState: false);
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

abstract class ViewSubmitResult {}

class DeskCheckSuccess extends ViewSubmitResult {
  final bool exists;
  DeskCheckSuccess(this.exists);
}

class EditFilesSuccess extends ViewSubmitResult {}

class FetchDeskSuccess extends ViewSubmitResult {
  final DeskData data;
  FetchDeskSuccess(this.data);
}

final viewProvider = StateNotifierProvider.autoDispose<ViewNotifier, ViewState>((ref) {
  return ViewNotifier(ref);
});

final checkDeskProvider = StateProvider((ref) => () {});