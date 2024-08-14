import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key, required this.pickFile,});
  final void Function() pickFile;

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("Pick file");
        widget.pickFile();
      },
      child: Row(
        children: [
        SvgPicture.asset("assets/svg/files-alt.svg"),
        const SizedBox(width: 5),
        Text("Upload Files", style: GoogleFonts.poppins(color: const Color(0xff006CFF)),),
        const Spacer(),
      ],),
    );
  }
}