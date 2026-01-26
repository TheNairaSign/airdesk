import 'package:air_desk/constants.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

class UploadFile extends StatelessWidget {
  const UploadFile({super.key, required this.pickFile,});
  final void Function() pickFile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("Pick file");
        pickFile();
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(EvaIcons.attach2Outline, color: Colors.white, size: 20),
            const SizedBox(width: 5),
            Text("Upload Files", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }
}