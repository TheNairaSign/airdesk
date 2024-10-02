import 'package:air_desk/utils/file_type.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FilePreviewContainer extends StatelessWidget {
  const FilePreviewContainer({super.key, required this.url, required this.uri});
  final String? url;
  final Uri? uri;

  @override
  Widget build(BuildContext context) {
    CustomFileType fileType = CustomFileType();

    Widget content = fileType.isImageFile(uri.toString())
        ? Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.picture_as_pdf),
            ),
        )
        : Container(
            color: Colors.white,
            child: const Icon(
              Icons.picture_as_pdf,
              size: 90,
              color: Colors.black,
            ),
          );

    return Container(
      height: 96,
      width: 96,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: content,
    );
}
}
