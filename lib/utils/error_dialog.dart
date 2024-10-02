import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Desk not found", style: GoogleFonts.poppins(color: primaryBlue)),
          content: Text("Failed to load data", style: GoogleFonts.poppins(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: GoogleFonts.poppins(color: primaryBlue)),
            ),
          ],
        );
      },
    );
  }