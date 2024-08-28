// ignore_for_file: deprecated_member_use

import 'package:air_desk/components/copy.dart';
import 'package:air_desk/provider/code_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CodeContainer extends StatelessWidget {
  const CodeContainer({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Consumer<CodeProvider>(
      builder: (context, cp, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffDFFCF8),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
              code,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: const Color(0xff166534), fontWeight: FontWeight.bold, fontSize: 25),)
          ),
          const SizedBox(width: 15),
          Copy(textToCopy: code,)
        ],
      ),
    );
  }
}

