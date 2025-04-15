import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final darkTheme = ThemeData.dark().copyWith(
  // scaffoldBackgroundColor: Colors.black,
  brightness: Brightness.dark,
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.lato(color: Colors.white),
    bodyLarge: GoogleFonts.lato(
      color: Colors.white,
      
      ),
    headlineSmall: GoogleFonts.lato(color: Colors.grey),
  ),
  cardColor: Colors.grey,
  shadowColor: Colors.white,
);