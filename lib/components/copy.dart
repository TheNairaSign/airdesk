// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class Copy extends StatelessWidget {
  const Copy({super.key, required this.textToCopy});
  final String textToCopy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: textToCopy));
        debugPrint("Text copied: $textToCopy");
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          dismissDirection: DismissDirection.up,
          content: Text('Copied to clipboard')),
        );
        debugPrint("Item copied");
        debugPrint(textToCopy);
      },
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/svg/files-alt.svg",
              color: Theme.of(context).textTheme.bodyLarge!.color),
          const SizedBox(width: 5),
          Text("Copy", style: Theme.of(context).textTheme.bodyLarge)
        ],
      ),
    );
  }
}
