// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_local_variable

import 'package:air_desk/model/image_model.dart';
import 'package:air_desk/pages/data_page/widgets/content_container.dart';
import 'package:air_desk/pages/data_page/widgets/file_display_container.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/utils/file_type.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/pages/main_page/widgets/code_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/download_multiple.dart';

class QrDataPage extends StatefulWidget {
  final String? data, content, imageUrl, fileName;
  final List<ImageData>? file;
  final int? imageLength;
  final int? imageId;
  final List<String>? uris;

  const QrDataPage({
    super.key,
    this.data,
    this.content,
    this.imageUrl,
    this.fileName,
    this.file,
    this.imageLength,
    this.imageId,
    this.uris,
  });

  @override
  State<QrDataPage> createState() => _QrDataPageState();
}

class _QrDataPageState extends State<QrDataPage> {
  CustomFileType fileType = CustomFileType();

  @override
  Widget build(BuildContext context) {
    final Uri? uri = widget.imageUrl != null ? Uri.tryParse(widget.imageUrl!) : null;
    String extractedValue = widget.data?.replaceAll('"', '') ?? 'No code';
    final String receivedCode = extractedValue.trim();

    final cP = context.read<ViewProvider>();
    final viewControl = cP.viewController;

    return WillPopScope(
      onWillPop: () async {
        viewControl.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(elevation: 0,),
        body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    const AirdeskAndLogo(top: 10.0),
                    CodeContainer(code: receivedCode),
                    const SizedBox(),
                    ContentContainer(content: widget.content, uri: uri,),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Image Attachments",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        // DownloadMultiple(uris: widget.uris!)
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(height: 0),
                    const SizedBox(height: 20),
                    FileDisplayContainer(uri: uri, imageUrl: widget.imageUrl, imageLength: widget.imageLength, files: widget.file!)
                    ],
                  // ],
                ),
              ),
            ),
      ),
    );
  }
}
