import 'package:air_desk/pages/startup_page.dart';
import 'package:air_desk/providers/history_provider.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/download_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: true,
    ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ShareProvider()),
        ChangeNotifierProvider(create: (context) => ViewProvider()),
        ChangeNotifierProvider(create: (context) => DownloadProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
        ChangeNotifierProvider(create: (context) => ReceiveFileProvider()),
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
      theme: lightTheme,
      themeMode: ThemeMode.light,
    );
  }
}