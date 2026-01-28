import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0.95, end: 1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.repeat(reverse: true);
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentGeometry.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('How it works', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),),
                    const SizedBox(width: 10),
                    ScaleTransition(
                      scale: _animation,
                      child: const CircleAvatar(
                        radius: 17,
                        backgroundImage: AssetImage('assets/x-shadow.jpg'),
                      ),
                    ),
                  ],
                )
              ),
              Image.asset("assets/folders.png"),
              Text(
                "How to share on Airdesk",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GlobalColours(context).aboutText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'How to Share a File, Text or links\n1. Tap Add files or drag file into the box or type content in the content section.\n2. Hit the Send button (paper plane icon).\n3. You\'ll get a 6-character code, your Desk Code.\n4. Share the code or QRcode with receiver',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
              ),
            ],
          ),
    );
  }
}
