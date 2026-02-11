import 'package:air_desk/components/qr_scanner.dart';
import 'package:air_desk/pages/main_page/my_desk/widgets/desk_valid_container.dart';
import 'package:air_desk/pages/main_page/widgets/send_button.dart';
import 'package:air_desk/pages/main_page/widgets/status_switch.dart';
import 'package:air_desk/pages/main_page/widgets/view_field.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/repositories/receive_file_repository.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../providers/view_provider.dart';

class ViewContainer extends ConsumerStatefulWidget {
  const ViewContainer({super.key});

  @override
  ConsumerState<ViewContainer> createState() => _ViewContainerState();
}

class _ViewContainerState extends ConsumerState<ViewContainer> {
  final String text = "Input Content to share or [desk code] to view";

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final viewNotifier = ref.read(viewProvider.notifier);
    final receiveFile = ref.read(receiveFileProvider);
    final shareController = ref.read(shareControllerProvider);

    viewNotifier.initialText(shareText: shareController.text, viewText: receiveFile.sharedText ?? '');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final shareNotifier = ref.watch(shareProvider.notifier);
    final controller = ref.watch(shareControllerProvider);
    final changeControllerState = ref.watch(viewProvider).changeControllerState;
    final sendController = ref.watch(shareControllerProvider);

    final scrollController = ScrollController();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
        debugPrint("Container tapped — focusing textfield.");
      },
      behavior: HitTestBehavior.translucent,
      child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 450,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF006CFF).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFF006CFF).withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (changeControllerState)
                          DeskValidContainer(deskName: sendController.text)
                        else 
                          const StatusSwitch(),
                        
                        GestureDetector(
                          onTap: () {
                            debugPrint("QR Scanner");
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const QrScanner()));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SvgPicture.asset(
                              "assets/svg/qr-scan.svg",
                              width: 25,
                              height: 25,
                              colorFilter: ColorFilter.mode(
                                isDarkMode ? Colors.white70 : const Color(0xFF006CFF),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Scrollbar(
                          controller: scrollController,
                          interactive: true,
                          radius: const Radius.circular(10),
                          thumbVisibility: true,
                          child: TextFormField(
                            focusNode: _focusNode,
                            scrollController: scrollController,
                            controller: controller,
                            textDirection: TextDirection.ltr,
                            keyboardType: TextInputType.multiline,
                            scrollPadding: const EdgeInsets.only(bottom: 100),
                            scrollPhysics: const BouncingScrollPhysics(),
                            enabled: true,
                            expands: true,
                            cursorColor: const Color(0xFF006CFF),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: GlobalColours(context).textColorForContainer,
                              height: 1.5,
                              fontSize: 16,
                            ),
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              filled: true,
                              isDense: true,
                              fillColor: Colors.transparent,
                              hintText: changeControllerState 
                                ? "Share contents to ${sendController.text}" 
                                : "Type or paste content to share...",
                              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDarkMode ? Colors.grey[600] : Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ViewField(),
                  ],
                ),
              ),
              const SendButton(),
            ],
          )
    );
  }
}

