// ignore_for_file: deprecated_member_use

import 'package:air_desk/components/copy.dart';
import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeContainer extends StatelessWidget {
  const CodeContainer({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 60,
          width: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Text(
            code,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: codeColor, fontWeight: FontWeight.bold, fontSize: 25),)
        ),
        const SizedBox(width: 15),
        Copy(textToCopy: code,)
      ],
    );
  }
}

