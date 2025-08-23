// ignore_for_file: use_build_context_synchronously

import 'package:air_desk/components/qr_scanner.dart';
import 'package:air_desk/pages/main_page/my_desk/widgets/desk_valid_container.dart';
import 'package:air_desk/pages/main_page/widgets/send_button.dart';
import 'package:air_desk/pages/main_page/widgets/status_switch.dart';
import 'package:air_desk/pages/main_page/widgets/view_field.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
// import 'package:air_desk/pages/main_page/widgets/status_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../providers/view_provider.dart';

class ViewContainer extends StatefulWidget {
  const ViewContainer({super.key});

  @override
  State<ViewContainer> createState() => _ViewContainerState();
}

class _ViewContainerState extends State<ViewContainer> {
  final String text = "Input Content to share or [desk code] to view";

  // ✅ Create the FocusNode here to persist across rebuilds
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Provider.of<ViewProvider>(context, listen: false).initialText(context);
  }

  @override
  void dispose() {
    _focusNode.dispose(); // ✅ Always dispose your FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(0, 108, 255, 0.1);
    const borderWidth = 1.0;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final shareProvider = Provider.of<ShareProvider>(context);
    final controller = shareProvider.shareController;

    final scrollController = ScrollController();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
        debugPrint("Container tapped — focusing textfield.");
      },
      behavior: HitTestBehavior.translucent,
      child: Consumer<ViewProvider>(
        builder: (context, viewProvider, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 400,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  border: Border.all(color: isDarkMode ? Colors.transparent : borderColor, width: borderWidth),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (viewProvider.changeControllerState)
                    DeskValidContainer(deskName: viewProvider.sendCodeController.text)
                    else 
                    const StatusSwitch(),
                    const SizedBox(height: 20),
                    Expanded(
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
                          cursorColor: GlobalColours.secondaryGreen,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: GlobalColours(context).textColorForContainer),
                          maxLines: null,
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: Colors.transparent,
                            hintText: viewProvider.changeControllerState ? "Share contents to ${viewProvider.sendCodeController.text}" : "Share Desk",
                                              
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                              fontSize: 17,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    // const Spacer(),
                    // if (shareProvider.isEdit)
                    const ViewField(),
                  ],
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: GestureDetector(
                  onTap: () {
                    debugPrint("QR Scanner");
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const QrScanner(),),
                    );
                  },
                  child: SvgPicture.asset("assets/svg/qr-scan.svg"),
                ),
              ),
              const SendButton(),
            ],
          );
        }
      ),
    );
  }
}

