import 'package:flutter/material.dart';

import '../../../components/copy.dart';

class ContentContainer extends StatelessWidget {
  const ContentContainer({super.key, required this.content, required this.uri});
  final String? content;
  final Uri? uri;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 20),
      // height: 250,
      // width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).shadowColor, width: 1)
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
                width: 75,
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
