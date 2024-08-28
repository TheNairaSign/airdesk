// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:air_desk/components/copy.dart';
import 'package:air_desk/components/download_file.dart';
import 'package:air_desk/model/image_model.dart';
import 'package:air_desk/provider/code_provider.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/widgets/code_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class QrDataPage extends StatefulWidget {
  final String? data, content, imageUrl, fileName;
  final List<ImageData>? file;
  final int? imageLength;
  final int? imageId;

  const QrDataPage({super.key, this.data, this.content, this.imageUrl, this.fileName, this.file, this.imageLength, this.imageId});

  @override
  State<QrDataPage> createState() => _QrDataPageState();
}
class _QrDataPageState extends State<QrDataPage> {

  bool _isImageFile(String url) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf'];
    final extension = url.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }
  bool _isPdf(String url) {
    final imageExtensions = ['pdf'];
    final extension = url.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }


  bool _isDownloading = false;
  List<bool> _isDownloadingList = [];

  @override
  void initState() {
    super.initState();
    // Initialize the _isDownloadingList based on the number of items in the list
    _isDownloadingList = List<bool>.filled(widget.imageLength ?? 0, false);
  }

  
  Future<void> _downloadFile(String url, String fileName, BuildContext context) async {

  double progress = 0.0;
  try {
    FileDownload().startDownloading(
      context,
      (receivedBytes, totalBytes) {
        setState(() {
          progress = receivedBytes / totalBytes;
        });
      },
      url,
      fileName,
      () {
        setState(() {
          _isDownloading = false;
        });
      }
    );
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
    final Uri? uri = widget.imageUrl != null ? Uri.tryParse(widget.imageUrl!) : null;
    String extractedValue = widget.data?.replaceAll('"', '') ?? 'No code';
    final String receivedCode = extractedValue.trim();

    final cP = context.read<CodeProvider>();
    final viewControl = cP.viewController;
    
    return WillPopScope(
      onWillPop: () async {
        viewControl.clear();
        return true;
      },
      child: Scaffold(
        body: Consumer<CodeProvider>(
          builder: (context, codeProv, child) {
            return SingleChildScrollView(
              child: Padding(
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
                          if (widget.content != null)
                            Text(
                              widget.content!,
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
                                context,
                              );
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
                          // height: 110,
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffecfcfa),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView.separated(
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemCount: widget.imageLength!,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            key: ValueKey(widget.imageLength),
                            itemBuilder: (context, index) {
                              final url = widget.file![index].url;
                              final fileName = widget.file![index].originalName;
                              return Row(
                                children: [
                                  Container(
                                    height: 96,
                                    width: 96,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: _isImageFile(uri.toString())? CachedNetworkImage(
                                      imageUrl: url,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.picture_as_pdf),
                                    ) : Container(color: Colors.white, child: const Icon(Icons.picture_as_pdf, size: 90, color: Colors.black)),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      maxLines: 4,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  const Spacer(),
                                  download(context,index),
                                ],
                              );
                            }
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
                            widget.imageUrl ?? 'No data',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  bool isSuccess = false;

  GestureDetector download(BuildContext context, int index) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isDownloadingList[index] = true;
        });

        try {
          final dio = Dio();
          final fileName = widget.file![index].originalName;
          final url = widget.file![index].url;
          final path = await _getFilePath(fileName);
          await dio.download(url, path,).then((_) {
            isSuccess = true;
          });

          if (isSuccess && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xffDFFCF8),
          content: Text("Download Successful", style: GoogleFonts.poppins(color: Colors.black)),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          ),
      );
          }
        } catch (e) {
          if (context.mounted) {
            print("Error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error downloading file", style: GoogleFonts.poppins(color: Colors.white)),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          ),
      );
          }
        } finally {
          setState(() {
            _isDownloadingList[index] = false;
          });
        }
      },
      child: _isDownloadingList[index]
          ? const SizedBox(
              height: 15,
              width: 15,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xff006CFF)),
              ),
            )
          : const Icon(
              Icons.file_download_outlined,
              color: Color(0xff006CFF),
            ),
    );
  }

  Future<String> _getFilePath(String filename) async {
    Directory? dir = Directory("");
    var status = await Permission.storage.status;
    print("Ststus: ${status.toString()}");
    if (!status.isGranted) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }
    try {
      if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory(); // for iOS
      } else {
        dir = await getExternalStorageDirectory();
      }
    } catch (err) {
      print("Cannot get download folder path $err");
    }
    return "${dir?.path}$filename";
  }
}