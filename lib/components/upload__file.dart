import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _fileName = file.name;
      });

      // Further processing of the file can be done here
      debugPrint('File uploaded: ${file.name}');
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("Pick file");
        _pickFile();
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