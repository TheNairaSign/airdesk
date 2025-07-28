import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData().copyWith(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xfff4f8fd),

  textTheme: TextTheme(
    headlineLarge: GoogleFonts.lato(color: Colors.black),
    headlineMedium: GoogleFonts.lato(color: Colors.black),
    headlineSmall: GoogleFonts.lato(color: const Color(0xff14532D),),
    bodyLarge:  GoogleFonts.lato(color: Colors.black),
    bodyMedium: GoogleFonts.lato(color: Colors.black87),
    bodySmall: GoogleFonts.lato(color: Colors.black54),
    labelLarge: GoogleFonts.lato(color: Colors.black),
    labelMedium: GoogleFonts.lato(color: Colors.black87),
    labelSmall: GoogleFonts.lato(color: Colors.black54),
    titleLarge: GoogleFonts.lato(color: Colors.black),
    titleMedium: GoogleFonts.lato(color: Colors.black87),
    titleSmall: GoogleFonts.lato(color: Colors.black54),
    displayLarge: GoogleFonts.lato(color: Colors.black),
    displayMedium: GoogleFonts.lato(color: Colors.black87),
    displaySmall: GoogleFonts.lato(color: Colors.black54),
  ),
  // cardColor: const Color(0xfff4f8fd),
  cardColor: primaryGreen,
  // shadowColor: const Color.fromRGBO(0, 108, 255, 0.1),
  shadowColor: bordercolor,
);

const placeholderProfilePic = 'https://avatar.iran.liara.run/public/boy?username=Ash';