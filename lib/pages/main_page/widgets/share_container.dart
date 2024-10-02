import 'dart:io';

import 'package:air_desk/components/upload__file.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/pages/main_page/widgets/send_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../widgets/file_preview.dart';

class ShareContainer extends StatefulWidget {
  const ShareContainer({super.key});

  @override
  State<ShareContainer> createState() => _ShareContainerState();
}

class _ShareContainerState extends State<ShareContainer> {

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color.fromRGBO(0, 108, 255, 0.1);

    return Consumer<ShareProvider>(
      builder: (context, cP, child) {
        return SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffF2F7FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 2.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.north_east,
                          color: Colors.grey[800],
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "To Share",
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: TextField(
                        controller: cP.shareController,
                        enableIMEPersonalizedLearning: true,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          hintTextDirection: TextDirection.ltr,
                          hintText: "Paste Link or text content here",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[900]!.withOpacity(0.5),
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                          ),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          enabled: true,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    UploadFile(pickFile: () async {
                      cP.pickFiles();
                    }),
                    const SizedBox(height: 10),
                    if (cP.file.isNotEmpty)
                      Flexible(
                        child: SizedBox(
                          child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemCount: cP.file.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              File file = cP.file[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FilePreview(file: file),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      file.path,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      maxLines: 4,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black, fontSize: 15),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        cP.file.removeAt(index); // Remove the file
                                      });
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.close,
                                          color: Colors.red, 
                                          size: 19,
                                          ),
                                        Text(
                                          "Remove",
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SendButton(),
            ],
          ),
        );
      }
    );
  }
}
