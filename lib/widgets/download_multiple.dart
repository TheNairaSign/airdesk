import 'package:air_desk/providers/download_provider.dart';
import 'package:air_desk/utils/file_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../utils/snack_bar.dart';

class DownloadMultiple extends StatelessWidget {
  const DownloadMultiple({super.key, required this.uris});
  final List<String>? uris;

  @override
  Widget build(BuildContext context) {
    CustomFileType fileType = CustomFileType();
    return Consumer<DownloadProvider>(
      builder: (context, downloadProvider, child) {
        return GestureDetector(
          onTap: () {
            if (uris != null && fileType.isImageFile(uris.toString())) {
                downloadProvider.downloadFiles(context, uris!,);
            } else {
              snackBar("No image found", context);
            }
            debugPrint("Download All");
          },
          child: Text(
            "Download All",
            style: GoogleFonts.poppins(
              color: const Color(0xff006CFF),
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }
    );
  }

Future<void> downloadMultipleFiles(List<String> urls, String saveDirectory) async {
  Dio dio = Dio();

  for (int i = 0; i < urls.length; i++) {
    String url = urls[i];
    String savePath = '$saveDirectory/file_$i.ext'; // Replace .ext with the actual file extension

    try {
      Response response = await dio.download(url, savePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          print('File $i: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      if (response.statusCode == 200) {
        print('File $i downloaded successfully!');
      } else {
        print('Failed to download file $i.');
      }
    } catch (e) {
      print('Error downloading file $i: $e');
    }
  }
}

}
