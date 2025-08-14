import 'package:air_desk/pages/main_page/my_desk/access_my_desk_screen.dart';
import 'package:air_desk/pages/main_page/my_desk/desk_creation_page.dart';
import 'package:air_desk/pages/main_page/my_desk/my_desk_created_page.dart';
import 'package:air_desk/pages/main_page/my_desk/widgets/about_my_desk.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

class MyDeskPage extends StatefulWidget {
  const MyDeskPage({super.key});

  @override
  State<MyDeskPage> createState() => _MyDeskPageState();
}

class _MyDeskPageState extends State<MyDeskPage> {
  final pageController = PageController();

  void animateToPage(int page) {
    pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyDesk', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.bold)), 
        forceMaterialTransparency: true,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 245,
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Your personal space for receiving and managing content',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyDeskCard(
                            icon: Icons.add,
                            title: 'Create MyDesk',
                            description:
                                'Get your personal desk with a custom code for receiving content',
                            iconColor: Colors.green,
                            onPressed: () => animateToPage(1), // Add action
                          ),
                          MyDeskCard(
                            icon: Icons.lock_outline,
                            title: 'Access MyDesk',
                            description:
                                'View and download submissions sent to your MyDesk',
                            iconColor: Colors.blue,
                            onPressed: () => animateToPage(2), // Add action
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const MyDeskCreationScreen(),
                const AccessMyDeskScreen(),
                const MyDeskCreatedPage()
              ],
            ),
          ),
          const AboutMyDesk()
        ],
      ),
    );
  }
}

class MyDeskCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final VoidCallback onPressed;

  const MyDeskCard({super.key, 
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width * .45;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        
        decoration: BoxDecoration(
          color: GlobalColours(context).containerColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            GlobalColours(context).containerShadow
        ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
