import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import '../model/history_model.dart';
import '../repositories/history_repository.dart';

class HistoryNotifier extends StateNotifier<List<HistoryItem>> {
  final HistoryRepository _historyRepository;

  HistoryNotifier(this._historyRepository) : super([]);

  // Retrieve history items from SharedPreferences
  Future<List<HistoryItem>> getHistoryItems() async {
    final items = await _historyRepository.getHistoryItems();
    state = items;
    return items;
  }

  // Update history by retrieving new data and saving it
  Future<void> updateHistory(List<HistoryItem> newData) async {
    state = newData;
    await _historyRepository.saveHistoryItems(state);
  }

  // Load history when the provider is initialized
  Future<void> loadHistory() async {
    state = await _historyRepository.getHistoryItems();
  }

  Timer? _timer;

  void _handleTimerTick() {
    if (state.isEmpty) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    final now = DateTime.now();
    final expiredItems = state.where((item) {
      final expiryTime =
          DateTime.parse(item.createdAt).add(const Duration(hours: 24));
      return now.isAfter(expiryTime);
    }).toList();

    if (expiredItems.isNotEmpty) {
      final newList = List<HistoryItem>.from(state)
        ..removeWhere((item) => expiredItems.contains(item));
      updateHistory(newList);
    } else {
      // If no items expired, still update state to refresh countdowns in the UI.
      state = List.from(state);
    }
  }

  /// Initializes a timer that periodically checks for expired history items
  /// and updates the UI.
  ///
  /// It's recommended to call `loadHistory()` before calling this method.
  /// The timer will automatically stop if the history list becomes empty.
  void initializeTimer() {
    // Cancel any existing timer to avoid multiple timers running.
    _timer?.cancel();
    // Start a new timer that fires every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _handleTimerTick();
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, List<HistoryItem>>((ref) {
  final repository = ref.read(historyRepositoryProvider);
  return HistoryNotifier(repository);
});
