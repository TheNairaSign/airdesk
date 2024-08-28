import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CodeProvider extends ChangeNotifier {

  final _shareController = TextEditingController();
  TextEditingController get shareController => _shareController;

  final _viewController = TextEditingController();
  TextEditingController get viewController => _viewController;

  List<File> _file = [];

  List<File> get file => _file;

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'jpeg', 'gif', 'png']
    );

    if (result != null) {
      _file = result.paths.map((path) => File(path!)).toList();
    }
    notifyListeners();
  }
}
