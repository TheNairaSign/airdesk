import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

const loadingSpinKit = SpinKitDualRing(color: primaryBlue, lineWidth: 2,);

void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Getting desk", style: GoogleFonts.poppins(color: primaryBlue),),
          content: const SizedBox(
            height: 50,
            width: 30,
            child: loadingSpinKit,
            ),
        );
      },
    );
  }