import 'dart:io';

import 'package:air_desk/widgets/file_preview.dart';
import 'package:flutter/material.dart';

class FileItem extends StatelessWidget {
  const FileItem({super.key, required this.filePath, required this.onRemove, this.fileName});
  final String filePath;
  final String? fileName;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FilePreview(file: File(filePath), size: 60),
      const SizedBox(width: 15),
      Expanded(
        child: Text(
          fileName ?? filePath.split('/').last,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          maxLines: 3,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      GestureDetector(
        onTap: onRemove,
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 15),
            Icon(Icons.close, color: Colors.red, size: 19),
          ],
        ),
      ),
    ],
  );
  }
  }