import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData().copyWith(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xfff4f8fd),

  textTheme: GoogleFonts.latoTextTheme(),
  // cardColor: const Color(0xfff4f8fd),
  cardColor: primaryGreen,
  // shadowColor: const Color.fromRGBO(0, 108, 255, 0.1),
  shadowColor: bordercolor,
);

const placeholderProfilePic = 'https://avatar.iran.liara.run/public/boy?username=Ash';