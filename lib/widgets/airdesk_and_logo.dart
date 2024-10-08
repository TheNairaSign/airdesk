// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AirdeskAndLogo extends StatelessWidget {
  const AirdeskAndLogo({super.key, this.top = 30.0});
  final img = "assets/air-desk-logo.png";
  final size = 45.0;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: size, width: size, child: Image.asset(img)),
          const SizedBox(
            width: 15,
          ),
          Text(
            "airdesk",
            style: Theme.of(context)
                .textTheme
                .headlineLarge!
                .copyWith(fontWeight: FontWeight.bold,
                ),
            textScaleFactor: 1.3,
          ),
        ],
      ),
    );
  }
}
