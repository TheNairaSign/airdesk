import 'dart:io';

import 'package:air_desk/components/upload__file.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/pages/main_page/widgets/view_container.dart';
import 'package:air_desk/widgets/file_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<ShareProvider>(
          builder: (context, cP, child) {
            return Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const AirdeskAndLogo(),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 40),
                    child: Text(
                      "Share links, texts and files between devices and people instantly.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 20.5),
                    ),
                  ),
                  // Image.asset("assets/home-Illustration.png"),
                  const SizedBox(height: 20),
                  const ViewContainer(),
                  const SizedBox(height: 30),
                  // const ShareContainer(),
                  UploadFile(pickFile: () async {
                        cP.pickFiles();
                      }),
                      const SizedBox(height: 10),
                      if (cP.file.isNotEmpty)
                        SizedBox(
                          child: ListView.separated(
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
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
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
