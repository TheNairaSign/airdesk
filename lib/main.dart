import 'package:air_desk/pages/startup_page.dart';
import 'package:air_desk/providers/history_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/download_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ShareProvider()),
        ChangeNotifierProvider(create: (context) => ViewProvider()),
        ChangeNotifierProvider(create: (context) => DownloadProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider())
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