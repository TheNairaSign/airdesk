import 'package:air_desk/pages/startup_page.dart';
import 'package:air_desk/themes/dark_theme.dart';
import 'package:air_desk/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const AirDesk());
}

class AirDesk extends StatelessWidget {
  const AirDesk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StartUpPage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      // themeMode: ThemeMode.dark,
    );
  }
}