import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/widgets/share_container.dart';
import 'package:air_desk/widgets/view_container.dart';
import 'package:flutter/material.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 40),
            child: Column(
              children: [
                const AirdeskAndLogo(),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 40),
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
