import 'dart:math';

import 'package:air_desk/model/create_desk.dart';
import 'package:air_desk/model/my_desk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../repositories/my_desk_repository.dart';

class DeskState {
  final bool isLoading;
  final bool deskNameValid;
  final String? publicCode;
  final String? adminCode;
  final bool createLoading;
  final MyDeskData? myDeskData;
  final bool accessLoading;
  final bool deskAvailable;
  final bool? deskExists;
  final bool checkingDesk;

  const DeskState({
    required this.isLoading,
    required this.deskNameValid,
    this.publicCode,
    this.adminCode,
    required this.createLoading,
    this.myDeskData,
    required this.accessLoading,
    required this.deskAvailable,
    this.deskExists,
    required this.checkingDesk,
  });

  DeskState copyWith({
    bool? isLoading,
    bool? deskNameValid,
    String? publicCode,
    String? adminCode,
    bool? createLoading,
    MyDeskData? myDeskData,
    bool? accessLoading,
    bool? deskAvailable,
    bool? deskExists,
    bool? checkingDesk,
  }) {
    return DeskState(
      isLoading: isLoading ?? this.isLoading,
      deskNameValid: deskNameValid ?? this.deskNameValid,
      publicCode: publicCode ?? this.publicCode,
      adminCode: adminCode ?? this.adminCode,
      createLoading: createLoading ?? this.createLoading,
      myDeskData: myDeskData ?? this.myDeskData,
      accessLoading: accessLoading ?? this.accessLoading,
      deskAvailable: deskAvailable ?? this.deskAvailable,
      deskExists: deskExists ?? this.deskExists,
      checkingDesk: checkingDesk ?? this.checkingDesk,
    );
  }
}


final myDeskRepositoryProvider = Provider<MyDeskRepository>((ref) => MyDeskRepository());

// final accessDeskControllerProvider = Provider<TextEditingController>((ref) {
//   final controller = TextEditingController();
//   ref.onDispose(() => controller.dispose());
//   return controller;
// });

// final createDeskControllerProvider = Provider<TextEditingController>((ref) {
//   final controller = TextEditingController();
//   ref.onDispose(() => controller.dispose());
//   return controller;
// });


final deskNotifierProvider = StateNotifierProvider<DeskNotifier, DeskState>((ref) {
  final repo = ref.watch(myDeskRepositoryProvider);
  return DeskNotifier(repo);
});

class DeskNotifier extends StateNotifier<DeskState> {
  final MyDeskRepository _repo;

  DeskNotifier(this._repo) : super(const DeskState(
    isLoading: false,
    deskNameValid: false,
    createLoading: false,
    accessLoading: false,
    deskAvailable: true,
    checkingDesk: false,
  ));

  Future<void> storeAccessCode(String value) async {
    await _repo.storeAccessCode(value);
  }

  void updateValidity(String value) {
    if (value.isEmpty || value.length < 6) {
      state = state.copyWith(deskNameValid: false);
    } else {
      state = state.copyWith(deskNameValid: true);
    }
  }

  String errorMessages(String value) {
    if (value.isEmpty) {
      return 'Please enter a desk name';
    } else if (value.length < 6) {
      return 'Desk name must be at least 6 characters long';
    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Desk name must contain only letters and numbers';
    } else if (value.contains(' ')) {
      return 'Desk name must not contain spaces';
    }
    return '';
  }

  String generateMixedCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer();
    final random = Random();
    for (int i = 0; i < 6; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  Future<CreateDesk> createDesk(String deskName) async {
    state = state.copyWith(createLoading: true);
    try {
      final desk = await _repo.createDesk(deskName);
      state = state.copyWith(
        publicCode: desk.publicCode,
        adminCode: desk.adminCode,
        createLoading: false,
      );
      return desk;
    } on Exception catch (e) {
      if (e.toString().contains('already taken')) {
        state = state.copyWith(deskExists: true, createLoading: false);
      }
      rethrow;
    } finally {
      state = state.copyWith(createLoading: false);
    }
  }

  void updateAdminCode(String value) {
    state = state.copyWith(adminCode: value);
  }


  Future<MyDeskData?> getCreatorDesks({bool load = true}) async {
    if (load && !state.accessLoading) {
      state = state.copyWith(accessLoading: true);
    }
    try {
      String? code = state.adminCode;
      if (code == null) {
         code = await _repo.getAccessCode();
         if (code != null) {
           state = state.copyWith(adminCode: code);
         }
      }
      
      if (code == null) {
        throw Exception('Access code not found');
      }

      final data = await _repo.getCreatorDesks(code);
      state = state.copyWith(myDeskData: data, accessLoading: false);
      return data;
    } catch (e) {
      if (state.accessLoading) {
        state = state.copyWith(accessLoading: false);
      }
      rethrow;
    }
  }

  Future<bool?> checkDesk(String deskName) async {
    state = state.copyWith(checkingDesk: true);
    try {
      final result = await _repo.checkDesk(deskName);
      state = state.copyWith(deskExists: result, checkingDesk: false);
      return result;
    } catch (error) {
      state = state.copyWith(checkingDesk: false);
      rethrow;
    } finally {
      state = state.copyWith(checkingDesk: false);
    }
  }
}


final myDeskProvider = StateNotifierProvider.autoDispose<DeskNotifier, DeskState>((ref) {
  return DeskNotifier(ref.read(myDeskRepositoryProvider));
});