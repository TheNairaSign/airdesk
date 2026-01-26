import 'package:air_desk/pages/main_page/my_desk/dialogs/access_dialog.dart';
import 'package:air_desk/pages/main_page/my_desk/dialogs/creation_dialog.dart';
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

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'MyDesk',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ), 
        forceMaterialTransparency: true,
      ),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).popUntil((route) => route.settings.name == '/navigation');
            });
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your personal space for receiving and\nmanaging content',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                MyDeskCard(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Create MyDesk',
                  description: 'Get your personal desk with a custom code for receiving content',
                  iconColor: const Color(0xFF006CFF),
                  onPressed: () => showCreationDialog(context),
                ),
                const SizedBox(height: 16),
                MyDeskCard(
                  icon: Icons.lock_open_rounded,
                  title: 'Access MyDesk',
                  description: 'View and download submissions sent to your MyDesk',
                  iconColor: const Color(0xFF069383),
                  onPressed: () => showAccessDialog(context),
                ),
                const SizedBox(height: 32),
                const AboutMyDesk(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GlobalColours(context).containerColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
