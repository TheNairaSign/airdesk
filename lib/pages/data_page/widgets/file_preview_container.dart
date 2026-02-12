import 'package:air_desk/constants.dart';
import 'package:air_desk/utils/file_type.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FilePreviewContainer extends StatelessWidget {
  const FilePreviewContainer({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    CustomFileType fileType = CustomFileType();
    final isImage = fileType.isImageFile(url);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 40,
      height: 40,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: isImage
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? Colors.white70 : codeColor,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.image_not_supported_outlined,
                size: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            )
          : Center(
              child: Icon(
                Icons.insert_drive_file_outlined, // Generic file icon
                size: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
    );
  }
}
