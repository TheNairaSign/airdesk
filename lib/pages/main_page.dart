// ignore_for_file: deprecated_member_use

import 'package:air_desk/widgets/share_container.dart';
import 'package:air_desk/widgets/view_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final img = "assets/air-desk-logo.png";
  final size = 45.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 70, left: 15, right: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: size, width: size, child: Image.asset(img)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      "airdesk",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                      textScaleFactor: 1.3,
                    ),
                  ],
                ),
                // const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30, left: 15, right: 15, bottom: 40),
                  child: Text(
                    "Share links, texts and files between devices and people instantly.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontSize: 20.5),
                  ),
                ),
                Image.asset("assets/home-Illustration.png"),
                const SizedBox(height: 20),
                const ViewContainer(),
                const SizedBox(height: 30),
                const ShareContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
