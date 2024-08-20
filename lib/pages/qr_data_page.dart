// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:air_desk/components/copy.dart';
import 'package:air_desk/provider/code_provider.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/widgets/code_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class QrDataPage extends StatelessWidget {
  final String? data, content, imageUrl, imageName;

  const QrDataPage(
      {super.key, this.data, this.content, this.imageUrl, this.imageName});

  bool _isImageFile(String url) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final extension = url.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  Future<void> _downloadFile(
      String url, String fileName, BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded $fileName successfully!')),
          );
        }
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Uri? uri = imageUrl != null ? Uri.tryParse(imageUrl!) : null;
    String extractedValue = data?.replaceAll('"', '') ?? 'No code';
    final String receivedCode = extractedValue.trim();

    return Scaffold(
      body: Consumer<CodeProvider>(
        builder: (context, codeProv, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const AirdeskAndLogo(verticalSpace: 40.0),
                CodeContainer(code: receivedCode),
                const SizedBox(),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xffecfcfa),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward,
                              size: 17, color: Colors.grey[700]),
                          Text('Content',
                              style:
                                  GoogleFonts.poppins(color: Colors.grey[700])),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 15),
                      if (content != null)
                        Text(
                          content!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      else
                        Center(
                          child: Text(
                            "No content",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xffdee7f4),
                            ),
                            child:
                                Copy(textToCopy: uri?.toString() ?? 'No URL'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text("Image Attachments",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (uri != null && _isImageFile(uri.toString())) {
                          _downloadFile(
                              uri.toString(),
                              'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
                              context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('No valid image to download')),
                          );
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
                    )
                  ],
                ),
                const SizedBox(height: 5),
                const Divider(height: 0),
                const SizedBox(height: 30),
                if (uri != null && uri.isAbsolute) ...[
                  if (_isImageFile(uri.toString())) ...[
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xffecfcfa),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 96,
                            width: 96,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl.toString(),
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Text(
                              imageName!,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              maxLines: 4,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const Spacer(),
                          download(context),
                        ],
                      ),
                    ),
                  ]
                ] else ...[
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffecfcfa),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        imageUrl ?? 'No data',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  GestureDetector download(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("Download Image");
        _downloadFile(imageUrl!, imageName!, context);
      },
      child: const Icon(
        Icons.file_download_outlined,
        color: Color(0xff006CFF),
      ),
    );
  }
}
