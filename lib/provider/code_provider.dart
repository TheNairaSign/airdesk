import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class CodeProvider extends ChangeNotifier {
  
  String _generatedCode = '';
  String get generatedCode => _generatedCode;
  String _qrData = '';
  String get qrData => _qrData;
  String _uid = '';
  String get uid => _uid;
  final _shareController = TextEditingController();
  TextEditingController get shareController => _shareController;

  final _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) {
    notifyListeners();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );
  }
  void generateCode(String code) async {
    final url = Uri.parse("https://airdesk-server.onrender.com/api/desk/$code");
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // Extracting content, images, and code
      var content = data["data"]["code"];
      _generatedCode = content;
}
}
}
