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
  const ViewContainer({super.key});

  final String text = "Input Content to share or [desk code] to view";

  String colorText() {
    Text(text, style: GoogleFonts.poppins(color: Colors.blue, fontSize: 16));
    return text;
  }

  @override
  Widget build(BuildContext context) {
    const borderColor =  Color.fromRGBO(0, 108, 255, 0.1);
    const borderWidth = 2.0;

    return Consumer<ViewProvider>(builder: (context, viewProvider, child) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 400,
            // margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor, width: borderWidth),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Flexible(
                        child: TextField(
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
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
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    maxLines: 2,
                    text: TextSpan(
                      text: '', // The base text is empty
                      style: DefaultTextStyle.of(context).style, // Default styling
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
          const SendButton(),
        ],
      );
    });
  }
}
