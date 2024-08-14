import 'package:air_desk/pages/qr_data_page.dart';
import 'package:air_desk/pages/startup_page.dart';
import 'package:air_desk/provider/code_provider.dart';
import 'package:air_desk/themes/dark_theme.dart';
import 'package:air_desk/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CodeProvider())
      ],
      child: const AirDesk(),
    ),
    
  );
}

class AirDesk extends StatelessWidget {
  const AirDesk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StartUpPage(),
      // home: const QrDataPage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      // themeMode: ThemeMode.light,
    );
  }
}