import 'package:air_desk/pages/main_page/main_page.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _currentIndex,
        unselectedIconTheme: const IconThemeData(color: Colors.black, size: 30),
        selectedIconTheme: IconThemeData(color: primaryBlue.withOpacity(0.80), size: 35),
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