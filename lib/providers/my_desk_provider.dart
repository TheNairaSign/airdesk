import 'dart:math';

import 'package:flutter/material.dart';

class MyDeskProvider extends ChangeNotifier {

  String generateMixedCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final StringBuffer buffer = StringBuffer();
    final Random random = Random();

    for (int i = 0; i < 6; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }
}