import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final darkTheme = ThemeData.dark().copyWith(
  // scaffoldBackgroundColor: Colors.black,
  brightness: Brightness.dark,
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.lato(color: Colors.white),
    headlineMedium: GoogleFonts.lato(color: Colors.white),
    bodyLarge: GoogleFonts.lato(color: Colors.white),
    headlineSmall: GoogleFonts.lato(color: Colors.grey),
    bodySmall: GoogleFonts.lato(color: Colors.grey),
    titleLarge: GoogleFonts.lato(color: Colors.white),
    titleMedium: GoogleFonts.lato(color: Colors.white),
    titleSmall: GoogleFonts.lato(color: Colors.grey),
    labelLarge: GoogleFonts.lato(color: Colors.white),
    labelMedium: GoogleFonts.lato(color: Colors.grey),
    labelSmall: GoogleFonts.lato(color: Colors.grey),
    bodyMedium: GoogleFonts.lato(color: Colors.white),
    displayLarge: GoogleFonts.lato(color: Colors.white),
    displayMedium: GoogleFonts.lato(color: Colors.white),
    displaySmall: GoogleFonts.lato(color: Colors.white),
  ),
  // cardColor: Colors.grey,
  cardColor: Colors.grey[900],
  // shadowColor: Colors.white,
  shadowColor: Colors.transparent
);