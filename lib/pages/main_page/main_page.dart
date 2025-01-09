import 'dart:io';

import 'package:air_desk/components/upload__file.dart';
import 'package:air_desk/pages/main_page/widgets/file_item.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/pages/main_page/widgets/view_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
    final receiveProvider = Provider.of<ReceiveFileProvider>(context, listen: false);
    receiveProvider
      ..updateIntentSub()
      ..getInitialMedia();
  }

  @override
  Widget build(BuildContext context) {
    final receiveProvider = Provider.of<ReceiveFileProvider>(context);
    final _sharedFiles = receiveProvider.sharedFiles;
    return SafeArea(
      child: Scaffold(
        body: Consumer<ShareProvider>(
          builder: (context, cP, child) {
            return Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 40),
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
                  const ViewContainer(),
                  const SizedBox(height: 30),
                  UploadFile(pickFile: () async => cP.pickFiles()),
                  const SizedBox(height: 10),
                  if (cP.file.isNotEmpty || _sharedFiles.isNotEmpty)
                    SizedBox(
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemCount: (cP.file.length + _sharedFiles.length),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (index < cP.file.length) {
                            // Files from ShareProvider
                            File file = cP.file[index];
                            return FileItem(
                              filePath: file.path,
                              onRemove: () {
                                setState(() {
                                  cP.file.removeAt(index); // Remove file from provider
                                });
                              },
                            );
                          } else {
                            // Shared files from _sharedFiles
                            int sharedIndex = index - cP.file.length;
                            final sharedFile = _sharedFiles[sharedIndex];
                            return FileItem(
                              filePath: sharedFile.path,
                              onRemove: () {
                                setState(() {
                                  _sharedFiles.removeAt(sharedIndex); // Remove shared file
                                });
                              },
                            );
                          }
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