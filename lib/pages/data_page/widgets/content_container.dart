import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

import '../../../components/copy.dart';

class ContentContainer extends StatelessWidget {
  const ContentContainer({super.key, required this.content});

  final String? content;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    
    const borderColor = Color.fromRGBO(0, 108, 255, 0.1);

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 20),
      // height: 250,
      // width: double.infinity,
      decoration: BoxDecoration(
        color: GlobalColours(context).containerColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: isDarkMode ? Colors.transparent : borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:  MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_downward, size: 17, color: Colors.grey[700]),
              const SizedBox(width: 3),
              Text('Content', style: Theme.of(context).textTheme.bodyLarge!.copyWith()),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 15),
          if (content != null) ...[
            Text(
              content!,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
            ),
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(5),
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Copy(textToCopy: content ?? ""),
              ),
            ],
          ),
          ]
          else
            Center(
              child: Text(
                "No content",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
              ),
            ),
        ],
      ),
    );
  }
}
