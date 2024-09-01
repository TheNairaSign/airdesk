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
    
    await prefs.setStringList('myHistory', jsonStringList);
  }

  // Retrieve history items from SharedPreferences
  Future<List<HistoryItem>?> getHistoryItems() async {
    debugPrint("GetHistoryItem function");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('myHistory');
    
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
}
