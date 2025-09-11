import 'package:air_desk/pages/main_page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../services/url_launcher_service.dart';
import '../../themes/light_theme.dart';
import '../../utils/global_colours.dart';
import '../main_page/my_desk/my_desk_creator_page.dart';
import '../main_page/my_desk/my_desk_page.dart';
import 'history.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {

  int _currentIndex = 0;

  final List pages = [
    const MainPage(),
    const HistoryPage(),
  ];

  void onItemTapped(int index) {
  setState(() {
    _currentIndex = index; 
  });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   final historyProvider = context.read<HistoryProvider>();
  //   historyProvider.initializeTimer(context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? mainPageAppBar(context) : historyAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        currentIndex: _currentIndex,
        unselectedIconTheme: IconThemeData(color: Colors.grey[800], size: 30),
        selectedIconTheme: IconThemeData(color: primaryBlue.withValues(alpha: 0.80), size: 35),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        enableFeedback: true,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
        ),
    );
  }
}

Future<String?> _getAccessCode() async {
  debugPrint('Getting access code');
  final prefs = await SharedPreferences.getInstance();
  final accessCode = prefs.getString('accessCode');
  debugPrint('Access code: $accessCode');
  return accessCode;
}


AppBar mainPageAppBar(BuildContext context) {
  return AppBar(
    forceMaterialTransparency: true,
    leading: GestureDetector(
      onTap: () async {
        final accessCode = await _getAccessCode();
        if (accessCode != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyDeskCreatorPage()));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const MyDeskPage()));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: CircleAvatar(
          radius: 30,
          child: Image.network(placeholderProfilePic),
        ),
      ),
    ),
    actions: [
      Text("How it works", style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16)),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () {
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WebViewPage()));
          // openWebUrl();
          UrlLauncherService.launchInAppBrowser();
        },
        child: SizedBox(
            height: 40,
            width: 40,
            child: Image.asset("assets/x.png")),
      ),
      const SizedBox(width: 10),
    ],
  );
}

AppBar historyAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    forceMaterialTransparency: true,
    title: Column(
      children: [
        Text("Share History", style: Theme.of((context)).textTheme.headlineSmall?.copyWith(color: GlobalColours(context).textColorForContainer)),
        Text('(Disappears in 24hrs)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ],
    ),
  );
}