// ignore_for_file: deprecated_member_use

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Copy extends StatelessWidget {
  const Copy({super.key, required this.textToCopy, this.textColor, this.borderColor});
  final String textToCopy;
  final Color? textColor, borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: textToCopy));
        debugPrint("Text copied: $textToCopy");
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          behavior: SnackBarBehavior.floating,
          // margin: const EdgeInsets.all(10),
          dismissDirection: DismissDirection.up,
          content: Text('Copied to clipboard', style: GoogleFonts.poppins(color: Colors.white))),
        );
        debugPrint("Item copied");
        debugPrint(textToCopy);
      },
      child: const Row(
        children: [
          // SvgPicture.asset(
          //   "assets/svg/files-alt.svg",
          //   color: textColor ?? Theme.of(context).textTheme.bodyLarge!.color
          // ),
          Icon(EvaIcons.copyOutline, color: Colors.green),
          // const SizedBox(width: 5),
          // Text("Copy", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor))
        ],
      ),
    );
  }
}
