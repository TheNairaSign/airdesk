// ignore_for_file: use_build_context_synchronously

import 'package:air_desk/components/qr_scanner.dart';
import 'package:air_desk/constants.dart';
import 'package:air_desk/pages/main_page/widgets/send_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../providers/view_provider.dart';

class ViewContainer extends StatelessWidget {
  const ViewContainer({
    super.key, 
    // required this.sharedMediaFile,
    });
  // final List<SharedMediaFile> sharedMediaFile;

  final String text = "Input Content to share or [desk code] to view";

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(0, 108, 255, 0.1);
    const borderWidth = 2.0;

    final size = MediaQuery.of(context).size;
    final double width = size.width;

    return Consumer<ViewProvider>(builder: (context, viewProvider, child) {
      final FocusNode focusNode = FocusNode();
      return GestureDetector(
        onTap: () {
          focusNode.requestFocus(); // Focus the TextField when the container is tapped
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            
            Container(
              height: 400,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width * 0.7,
                    child: TextField(
                      focusNode: focusNode, // Use the FocusNode here
                      controller: viewProvider.viewController,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "Share or View Desk",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 20,
                        ),
                        border: InputBorder.none,
                        enabled: true,
                        isDense: true,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: RichText(
                      maxLines: 2,
                      text: TextSpan(
                        text: '',
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Input Content to ',
                            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 16),
                          ),
                          TextSpan(
                            text: 'share',
                            style: GoogleFonts.poppins(color: primaryBlue, fontSize: 16),
                          ),
                          TextSpan(
                            text: ' or [desk code] to ',
                            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 16),
                          ),
                          TextSpan(
                            text: 'view',
                            style: GoogleFonts.poppins(color: const Color(0xff219c8e), fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20, // Adjust based on desired placement
              right: 15,
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
    });
  }
}
