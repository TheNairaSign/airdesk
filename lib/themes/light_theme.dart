import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData().copyWith(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xfff4f8fd),
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.poppins(color: Colors.black),
    headlineSmall: GoogleFonts.poppins(color: const Color(0xff14532D),),
    bodyLarge:  GoogleFonts.poppins(color: Colors.black),
  ),
  cardColor: const Color(0xfff4f8fd),
  shadowColor: const Color.fromRGBO(0, 108, 255, 0.1)
);