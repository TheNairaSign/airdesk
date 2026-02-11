import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/history_model.dart';

class HistoryRepository {
  static const _historyKey = 'myHistory';

  Future<void> saveHistoryItems(List<HistoryItem> items) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = items.map((item) => json.encode(item.toMap())).toList();
    await prefs.setStringList(_historyKey, jsonStringList);
  }

  Future<List<HistoryItem>> getHistoryItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList(_historyKey);

    if (jsonStringList != null) {
      return jsonStringList
      .map((jsonString) => HistoryItem.fromMap(json.decode(jsonString)))
      .toList();
    }
    return [];
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) => HistoryRepository());