// ignore_for_file: use_build_context_synchronously

import 'package:air_desk/components/qr_scanner.dart';
import 'package:air_desk/pages/main_page/widgets/send_button.dart';
import 'package:air_desk/pages/main_page/widgets/view_field.dart';
import 'package:air_desk/providers/share_provider.dart';
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

    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final controller = Provider.of<ShareProvider>(context, listen: false).shareController;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
        debugPrint("Container tapped — focusing textfield.");
      },
      behavior: HitTestBehavior.translucent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 400,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor, width: borderWidth),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const StatusSwitch(),
                // const SizedBox(height: 10),
                SizedBox(
                  width: width * 0.68,
                  child: TextFormField(
                    focusNode: _focusNode,
                    controller: controller,
                    textDirection: TextDirection.ltr,
                    keyboardType: TextInputType.multiline,
                    enabled: true,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                    maxLines: null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: "Share Desk",
                      hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        fontSize: 17,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                const Spacer(),
                const ViewField(),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 25,
            child: GestureDetector(
              onTap: () {
                debugPrint("QR Scanner");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const QrScanner(),
                  ),
                );
              },
              child: SvgPicture.asset("assets/svg/qr-scan.svg"),
            ),
          ),
          const SendButton(),
        ],
      ),
    );
  }
}

