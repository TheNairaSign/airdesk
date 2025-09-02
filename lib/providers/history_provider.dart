import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/history_model.dart';

class HistoryProvider extends ChangeNotifier {

  List<HistoryItem> _historyItems = [];
  List<HistoryItem> get historyItems => _historyItems;
  
  // Save history items to SharedPreferences
  Future<void> saveHistoryItems(List<HistoryItem> items) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Convert the list of HistoryItem objects to a list of JSON strings
    List<String> jsonStringList = items.map((item) => json.encode(item.toMap())).toList();

    debugPrint("The History list: $jsonStringList");
    
    await prefs.setStringList('myHistory', jsonStringList);
  }

  // Retrieve history items from SharedPreferences
  Future<List<HistoryItem>?> getHistoryItems() async {
    debugPrint("GetHistoryItem function");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('myHistory');

    debugPrint("The History list: $jsonStringList");
    
    if (jsonStringList != null) {
      // Convert the list of JSON strings back into a list of HistoryItem objects
      return jsonStringList.map((jsonString) => HistoryItem.fromMap(json.decode(jsonString))).toList();
    }
    return null;
  }

  // Update history by retrieving new data and saving it
  Future<void> updateHistory(List<HistoryItem> newData) async {
    _historyItems = newData;
    await saveHistoryItems(_historyItems);
    notifyListeners(); // Notify listeners to update the UI
  }

  // Load history when the provider is initialized
  Future<void> loadHistory() async {
    List<HistoryItem>? items = await getHistoryItems();
    if (items != null) {
      _historyItems = items;
      notifyListeners();
    }
  }

  Timer? _timer;

  void _handleTimerTick() {
    if (_historyItems.isEmpty) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    final now = DateTime.now();
    final expiredItems = _historyItems.where((item) {
      final expiryTime = DateTime.parse(item.createdAt).add(const Duration(hours: 24));
      return now.isAfter(expiryTime);
    }).toList();

    if (expiredItems.isNotEmpty) {
      _historyItems.removeWhere((item) => expiredItems.contains(item));
      // updateHistory also calls saveHistoryItems and notifyListeners
      updateHistory(_historyItems);
    } else {
      // If no items expired, still notify listeners to update countdowns in the UI.
      notifyListeners();
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
