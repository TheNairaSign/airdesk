import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatelessWidget {
  const About({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      height: 330,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xffedeff3),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/folders.png"),
          Text(
            "How Airdesk Works",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff4b5563),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            """Airdesk allows you to share web links, text or files between 2 devices, so instead of login into WhatsApp on two devices for example or adding someone on WhatsApp just to share something with them you just need to open airdesk on both devices and share resources in 15 seconds.""",
            style: GoogleFonts.poppins(color: Colors.black),
          )
        ],
      ),
    );
  }
}
