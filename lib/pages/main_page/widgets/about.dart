import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      height: 330,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : const Color(0xffedeff3),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/folders.png"),
          Text(
            "How to share on Airdesk",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? primaryBlue : const Color(0xff4b5563),
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
