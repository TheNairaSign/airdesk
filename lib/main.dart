import 'package:air_desk/pages/startup_page.dart';
import 'package:air_desk/themes/dark_theme.dart';
import 'package:air_desk/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import 'providers/download_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    ChangeNotifierProvider(
      create: (context) => DownloadProvider(),
      child: const ProviderScope(child: AirDesk()),
    ),
  );
}

class AirDesk extends StatefulWidget {
  const AirDesk({super.key});

  @override
  State<AirDesk> createState() => _AirDeskState();
}

class _AirDeskState extends State<AirDesk> {

  /*
  @override
  initState() {
    super.initState();
    FirebaseMessagingService.initialize(context);
    // NotificationService.getFCMToken(context);
  }
  */
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StartUpPage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDarkMode = brightness == Brightness.dark;

        final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: scaffoldColor,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: scaffoldColor,
          systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        ));

        return child!;
      },
    );
  }
}
