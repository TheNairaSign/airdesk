import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Colors.black,
  brightness: Brightness.dark,
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.poppins(color: Colors.white),
    bodyLarge: GoogleFonts.poppins(color: Colors.white),
    headlineSmall: GoogleFonts.poppins(color: Colors.grey),
  )
);