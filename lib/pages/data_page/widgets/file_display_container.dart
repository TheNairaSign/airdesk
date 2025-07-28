import 'package:air_desk/pages/data_page/widgets/file_preview_container.dart';
import 'package:air_desk/utils/file_type.dart';
import 'package:flutter/material.dart';

import '../../../model/image_model.dart';
import '../../../widgets/download_file.dart';

class FileDisplayContainer extends StatelessWidget {
  const FileDisplayContainer({
    super.key,
    required this.uri,
    required this.imageUrl,
    required this.imageLength,
    required this.files,
  });
  final Uri? uri;
  final String? imageUrl;
  final int? imageLength;
  final List<ImageData> files;

  @override
  Widget build(BuildContext context) {
    CustomFileType fileType = CustomFileType();
    Widget content = fileType.isImageFile(uri.toString())
      ? ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: imageLength!,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final url = files[index].url;
            final fileName = files[index].originalName;
            return Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).shadowColor, width: 1)
              ),
              child: Row(
                children: [
                  FilePreviewContainer(url: url, uri: uri),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fileName,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                    ),
                  ),
                  const Spacer(),
                  DownloadFile(
                    index: index,
                    // file: files,
                    imageLength: imageLength,
                    url: url,
                    fileName: fileName,
                  ),
                ],
              ),
            );
          })
          : Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  imageUrl ?? 'No data',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                ),
              ),
            );

    Widget body = uri != null && uri!.isAbsolute ? content : const SizedBox.shrink();
    return body;
  }
}
