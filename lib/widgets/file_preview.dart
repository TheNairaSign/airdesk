import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.file});
  final File file;

  static const _spinKit = SpinKitRing(color: Color(0xff069383), size: 50.0, lineWidth: 3.0);

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (file.path.startsWith('http')) {
      imageUrl = file.path;
      debugPrint('ImageUrl  in preview: $imageUrl');
    }
    String fileExtension = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      return Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.hardEdge,
        child: imageUrl != null
          ? Image.network(
              imageUrl,
              alignment: Alignment.center,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: _spinKit);
              },
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            )
          : Image.file(
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