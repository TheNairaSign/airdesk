import 'dart:io';

import 'package:air_desk/components/upload__file.dart';
import 'package:air_desk/pages/main_page/widgets/about.dart';
import 'package:air_desk/pages/main_page/widgets/file_item.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/service/url_launcher_service.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/pages/main_page/widgets/view_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
      ..getInitialContent();
  }

  @override
  Widget build(BuildContext context) {
    final receiveProvider = Provider.of<ReceiveFileProvider>(context);
    final sharedFiles = receiveProvider.sharedFiles;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          actions: [
            Text("How it works", style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16)),
            GestureDetector(
              onTap: () {
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WebViewPage()));
                // openWebUrl();
                UrlLauncherService.launchInAppBrowser();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 25,
                width: 25,
                child: SvgPicture.asset("assets/svg/twitter.svg")),
            ),
          ],
        ),
        body: Consumer<ShareProvider>(
          builder: (context, cP, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const AirdeskAndLogo(),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 30),
                    child: Text(
                      "Share links, texts and files between devices and people instantly.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 17.5),
                    ),
                  ),
                  // Image.asset("assets/home-Illustration.png"),
                  const ViewContainer(),
                  const SizedBox(height: 30),
                  UploadFile(pickFile: () async => cP.pickFiles()),
                  const SizedBox(height: 10),
                  if (cP.file.isNotEmpty || sharedFiles.isNotEmpty)
                    SizedBox(
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemCount: (cP.file.length + sharedFiles.length),
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
                                  cP.file.removeAt(index);
                                });
                              },
                            );
                          } else {
                            // Shared files from _sharedFiles
                            int sharedIndex = index - cP.file.length;
                            final sharedFile = sharedFiles[sharedIndex];
                            return FileItem(
                              filePath: sharedFile.path,
                              onRemove: () {
                                setState(() {
                                  sharedFiles.removeAt(sharedIndex);
                                });
                              },
                            );
                          }
                        },
                      ),
                    ),
                  const About(),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}