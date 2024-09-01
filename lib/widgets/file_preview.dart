import 'dart:io';

import 'package:flutter/material.dart';

class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    String fileExtension = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      return Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.file(
          file,
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.insert_drive_file, color: Colors.white),
      );
    }
  }
}