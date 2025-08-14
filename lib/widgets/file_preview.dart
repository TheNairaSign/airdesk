import 'dart:io';

import 'package:flutter/material.dart';

class FilePreview extends StatefulWidget {
  const FilePreview({super.key, required this.file});
  
  final File file;

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  late String? imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.file.path.startsWith('https')) {
      imageUrl = widget.file.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're dealing with a file or a URL
    // Handle local file
    String fileExtension = widget.file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      return Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.hardEdge,
        child: imageUrl != null
          ? Image.network(
            imageUrl!,
            alignment: Alignment.center,
            fit: BoxFit.cover,
          )
          : Image.file(
            widget.file,
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