import 'package:air_desk/pages/main_page.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class StartUpPage extends StatefulWidget {
  const StartUpPage({super.key});

  @override
  State<StartUpPage> createState() => _StartUpPageState();
}

class _StartUpPageState extends State<StartUpPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainPage())));
  }
  @override
  Widget build(BuildContext context) {
    const size = 60.0;
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size,
              width: size,
              child: FadeInRight(
                animate: true,
                child: Image.asset("assets/air-desk-logo.png"))),
            FadeInLeft(
              animate: true,
              delay: const Duration(seconds: 2),
              // duration: ,
              child: Text("airdesk", style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: size - 10),))
          ],
        ),
      ),
    );
  }
}