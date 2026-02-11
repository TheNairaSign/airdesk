import 'package:air_desk/model/image_data.dart';
import 'package:air_desk/pages/data_page/widgets/content_container.dart';
import 'package:air_desk/pages/data_page/widgets/file_display_container.dart';
import 'package:air_desk/pages/data_page/widgets/qr_and_countdown_container.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class QrDataPage extends ConsumerStatefulWidget {
  final String? data, content;
  final List<ImageData>? files;
  final DateTime createdAt;

  const QrDataPage({
    super.key,
    this.data,
    this.content,
    this.files,
    required this.createdAt,
  });

  @override
  ConsumerState<QrDataPage> createState() => _QrDataPageState();
}

class _QrDataPageState extends ConsumerState<QrDataPage> {

  @override
  Widget build(BuildContext context) {
    // final Uri? uri = widget.imageUrl != null ? Uri.tryParse(widget.imageUrl!) : null;
    String extractedValue = widget.data?.replaceAll('"', '') ?? 'No code';
    final String receivedCode = extractedValue.trim();

    final viewControl = ref.read(viewControllerProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        viewControl.clear();
      },
      child: Scaffold(
        appBar: AppBar(elevation: 0, forceMaterialTransparency: true),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const AirdeskAndLogo(top: 0.0),
                // CodeContainer(code: receivedCode),
                QrCountdownContainer(
                  title: "Live desk",
                  code: receivedCode,
                  createdAt: widget.createdAt,
                ),
                const SizedBox(),
                ContentContainer(content: widget.content),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Image Attachments",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    // const Spacer(),
                    // DownloadMultiple(uris: widget.uris!)
                  ],
                ),
                const SizedBox(height: 5),
                const Divider(height: 0),
                const SizedBox(height: 20),
                FileDisplayContainer(files: widget.files!)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
