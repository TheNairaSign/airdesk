import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';


class AboutMyDesk extends StatelessWidget {
  const AboutMyDesk({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: GlobalColours(context).aboutContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'About MyDesk',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: GlobalColours(context).aboutText
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'MyDesk provides your own personal space on Airdesk. Create a desk with your custom code, share it with others, and receive files and messages directly to your personal inbox.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: GlobalColours(context).textColorForContainer,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GlobalColours(context).onAboutContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to use MyDesk:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                bulletPoint(
                  context,
                  title: "Create MyDesk:",
                  text:
                      "Get your personal desk with a unique code. Store your admin code safely – you’ll need it to access your submissions.",
                ),
                const SizedBox(height: 8),
                bulletPoint(
                  context,
                  title: "Access MyDesk:",
                  text:
                      "Enter your admin code to view all files and messages sent to your desk.",
                ),
                const SizedBox(height: 8),
                bulletPoint(
                  context,
                  title: "Send to MyDesk:",
                  text:
                      "From the home page, enter an @ symbol followed by the recipient's MyDesk code in the code field (e.g., @ABC12345) to send files and messages.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bulletPoint(BuildContext context, {required String title, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("•  ", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18)),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: GlobalColours(context).textColorForContainer
              ),
              children: [
                TextSpan(
                  text: " $text",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
