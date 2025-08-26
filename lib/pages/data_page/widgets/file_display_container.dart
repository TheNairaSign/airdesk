import 'package:air_desk/model/image_data.dart';
import 'package:air_desk/pages/data_page/widgets/file_preview_container.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

import '../../../widgets/download_file.dart';

class FileDisplayContainer extends StatelessWidget {
  const FileDisplayContainer({
    super.key,
    // required this.imageUrl,
    required this.files,
  });
  // final String imageUrl;
  final List<ImageData> files;

  @override
  Widget build(BuildContext context) {
    // CustomFileType fileType = CustomFileType();
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    
    const borderColor = Color.fromRGBO(0, 108, 255, 0.1);
    // Widget content = fileType.isImageFile(imageUrl)? 
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: files.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final url = files[index].url ?? '';

        final fileName = files[index].originalName ?? '';
        return Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: GlobalColours(context).containerColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDarkMode ? Colors.transparent : borderColor, width: 1),
          ),
          child: Row(
            children: [
              FilePreviewContainer(url: url),
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
                imageLength: files.length,
                url: url,
                fileName: fileName,
              ),
            ],
          ),
        );
      });
          // : Container(
          //     height: 110,
          //     width: double.infinity,
          //     decoration: BoxDecoration(
          //       color: Theme.of(context).cardColor,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Center(
          //       child: Text(
          //         imageUrl ?? 'No data',
          //         style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
          //       ),
          //     ),
          //   );

    // Widget body = uri != null && uri!.isAbsolute ? content : const SizedBox.shrink();
    // return body;
  }
}
