import 'package:air_desk/model/image_data.dart';
import 'package:animate_do/animate_do.dart';
import 'package:air_desk/pages/data_page/widgets/content_container.dart';
import 'package:air_desk/pages/data_page/widgets/file_display_container.dart';
import 'package:air_desk/pages/data_page/widgets/qr_and_countdown_container.dart';
import 'package:air_desk/providers/view_provider.dart';
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
    String extractedValue = widget.data?.replaceAll('"', '') ?? 'No code';
    final String receivedCode = extractedValue.trim();

    final viewControl = ref.read(viewControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        viewControl.clear();
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xff0a0a0a) : const Color(0xfff8faff),
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          title: Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 15, 0, 15),
                child: Image.asset("assets/air-desk-logo.png", height: 30, width: 30),
              ),
              const SizedBox(width: 10),
              Text(
                "airdesk",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black),
                textScaler: const TextScaler.linear(1.2),
              ),
            ],
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, size: 20, color: isDark ? Colors.white70 : Colors.black87),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: QrCountdownContainer(
                    title: "Live desk",
                    code: receivedCode,
                    createdAt: widget.createdAt,
                  ),
                ),
                const SizedBox(height: 24),
                
                if (widget.content != null && widget.content!.isNotEmpty)
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: ContentContainer(content: widget.content),
                  ),
                
                if (widget.files != null && widget.files!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: FileDisplayContainer(files: widget.files!),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
