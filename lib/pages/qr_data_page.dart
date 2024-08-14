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
  final String? data;
  const QrDataPage({super.key, this.data});

  bool _isImageFile(String url) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final extension = url.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  bool _isVideoFile(String url) {
    final videoExtensions = ['mp4', 'avi', 'mov', 'mkv'];
    final extension = url.split('.').last.toLowerCase();
    return videoExtensions.contains(extension);
  }


  @override
  Widget build(BuildContext context) {
    final Uri? uri = data != null ? Uri.tryParse(data!) : null;
    // Uri url = Uri.parse(data!);
    String receivedCode = uri!.pathSegments.last;
    debugPrint("received code = $receivedCode");


  Future<void> _downloadFile(String url, String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $fileName successfully!')),
      );
    } else {
      throw Exception('Failed to download file');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

    

    return Scaffold(
      body: Consumer<CodeProvider>(
        builder: (context, codeProv, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const AirdeskAndLogo(
                  verticalSpace: 40.0,
                ),
                CodeContainer(code: receivedCode,),
                const SizedBox(),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xffecfcfa),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            size: 17,
                            color: Colors.grey[700],
                          ),
                          Text(
                            'Content',
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 15),
                      if (uri.isAbsolute)
                        Text(
                          'URL: $uri',
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
                                color: const Color(0xffdee7f4)),
                            child: Copy(textToCopy: uri.toString(),),
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
                        if (_isImageFile(uri.toString())) {
                          _downloadFile(uri.toString(), 'image_${DateTime.now().millisecondsSinceEpoch}.jpg');
                        } else if (_isVideoFile(uri.toString())) {
                          _downloadFile(uri.toString(), 'video_${DateTime.now().millisecondsSinceEpoch}.mp4');
                        }
                        debugPrint("Download All");
                      },
                      child: Text(
                        "Download All",
                        style: GoogleFonts.poppins(
                            color: const Color(0xff006CFF),
                            decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                const Divider(
                  height: 0,
                ),
                const SizedBox(
                  height: 30,
                ),
                if (uri.isAbsolute) ...[
                  if (_isImageFile(uri.toString())) ...[
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xffecfcfa),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Container(
                            height: 96,
                            width: 96,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: CachedNetworkImage(
                              imageUrl: uri.toString(),
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Text(
                            uri.toFilePath(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.file_download_outlined,
                            color: Color(0xff006CFF),
                          )
                        ],
                      ),
                    ),
                  ] else if (_isVideoFile(uri.toString())) ...[
                    VideoPlayerWidget(videoUrl: uri.toString()),
                  ],
                ] else ...[
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xffecfcfa),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        data ?? 'No data',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
