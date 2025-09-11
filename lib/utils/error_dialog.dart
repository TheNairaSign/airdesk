import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Desk Error", style: GoogleFonts.poppins(color: Colors.red)),
          content: Text("Desk does not exist, please try again with another desk code", style: GoogleFonts.poppins(color: Colors.black)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                backgroundColor: Colors.red.withValues(alpha: .5),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }