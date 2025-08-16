import 'dart:io';

import 'package:air_desk/widgets/file_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      FilePreview(file: File(filePath)),
      const SizedBox(width: 15),
      Expanded(
        child: Text(
          fileName ?? filePath.split('/').last,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          maxLines: 4,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      GestureDetector(
        onTap: onRemove,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.close, color: Colors.red, size: 19),
            Text(
              "Remove",
              style: GoogleFonts.poppins(
                color: Colors.red,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
  }