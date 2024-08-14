import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
  void generateCode() {
    final uuid = const Uuid().v4(); // Generate a unique identifier
    final code = getRandomString(6); // Generate the alphanumeric code
      _generatedCode = code;
      _qrData = jsonEncode({'uid': uuid, 'input': shareController.text});
      _uid = uuid; // Store the UID for later use
}
}