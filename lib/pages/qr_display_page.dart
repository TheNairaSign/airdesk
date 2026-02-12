import 'package:air_desk/pages/main_page/widgets/code_container.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/widgets/edit_code_container.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QRDisplayPage extends ConsumerWidget {
  const QRDisplayPage({super.key, required this.data, required this.code, this.editCode});
  final String data, code;
  final String? editCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareController = ref.read(shareControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          shareController.clear();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xff0a0a0a) : const Color(0xfff8faff),
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 20, color: isDark ? Colors.white70 : Colors.black87),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  title: "View my shared content on AirDesk",
                  text: "View my shared content on AirDesk: $data",
                ),
              ),
              icon: Icon(Icons.share_outlined, color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: const AirdeskAndLogo(top: 0),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff1a1a1a) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.blue.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.blue.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Your Desk is Ready!",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Anyone with this code can instantly access your shared content.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        CodeContainer(code: code),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: data,
                            version: QrVersions.auto,
                            size: 180.0,
                            gapless: false,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "Scan QR or use the link below",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(data);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xfff0f4ff),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.link, size: 18, color: GlobalColours.primaryColor),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    data,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: GlobalColours.primaryColor,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      decorationColor: GlobalColours.primaryColor
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (editCode != null) ...[
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: EditCodeContainer(editCode: editCode!),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
