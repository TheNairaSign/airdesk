import 'dart:io';

import 'package:air_desk/widgets/file_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FileItem extends StatelessWidget {
  const FileItem({super.key, required this.filePath, required this.onRemove});
  final String filePath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FilePreview(file: File(filePath)), // Assuming FilePreview supports File
      const SizedBox(width: 15),
      Expanded(
        child: Text(
          filePath,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          maxLines: 4,
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
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