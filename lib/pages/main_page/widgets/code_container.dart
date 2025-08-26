// ignore_for_file: deprecated_member_use

import 'package:air_desk/components/copy.dart';
import 'package:flutter/material.dart';

class CodeContainer extends StatelessWidget {
  const CodeContainer({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            // color: Theme.of(context).cardColor,
            color: isDarkMode ? Colors.grey[900] : Colors.teal.withOpacity(.2),

            borderRadius: BorderRadius.circular(15)
          ),
          child: Center(
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: const Color(0xff069383), fontWeight: FontWeight.bold),
            ),
          )
        ),
        const SizedBox(width: 15),
        Copy(textToCopy: code)
      ],
    );
  }
}

