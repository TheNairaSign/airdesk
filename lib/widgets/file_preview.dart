import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.file});
  final File file;

  static const _spinKit = SpinKitRing(color: Color(0xff069383), size: 50.0, lineWidth: 3.0);

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (file.path.startsWith('https')) {
      imageUrl = file.path;
    }
    String fileExtension = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      return Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.hardEdge,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                alignment: Alignment.center,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: _spinKit),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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