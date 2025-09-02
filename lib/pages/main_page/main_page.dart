// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:air_desk/components/upload__file.dart';
import 'package:air_desk/constants.dart';
import 'package:air_desk/pages/main_page/my_desk/my_desk_creator_page.dart';
import 'package:air_desk/pages/main_page/my_desk/my_desk_page.dart';
import 'package:air_desk/pages/main_page/widgets/about.dart';
import 'package:air_desk/pages/main_page/widgets/file_item.dart';
import 'package:air_desk/pages/main_page/widgets/view_container.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/services/url_launcher_service.dart';
import 'package:air_desk/themes/light_theme.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
    _getAccessCode();
    final receiveProvider = Provider.of<ReceiveFileProvider>(context, listen: false);
    receiveProvider
      ..updateIntentSub()
      ..getInitialContent();
  }

  Future<String?> _getAccessCode() async {
    debugPrint('Getting access code');
    final prefs = await SharedPreferences.getInstance();
    final accessCode = prefs.getString('accessCode');
    debugPrint('Access code: $accessCode');
    return accessCode;
  }


  @override
  Widget build(BuildContext context) {
    final receiveProvider = Provider.of<ReceiveFileProvider>(context);
    final sharedFiles = receiveProvider.sharedFiles;


  final editFiles = Provider.of<ShareProvider>(context).editFiles;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          leading: GestureDetector(
            onTap: () async {
              final _accessCode = await _getAccessCode();
              if (_accessCode != null) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyDeskCreatorPage()));
              } else {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const MyDeskPage()));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 30,
                child: Image.network(placeholderProfilePic),
              ),
            ),
          ),
          actions: [
            Text("How it works", style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16)),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WebViewPage()));
                // openWebUrl();
                UrlLauncherService.launchInAppBrowser();
              },
              child: SizedBox(
                height: 40,
                width: 40,
                child: Image.asset("assets/x.png")),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Consumer<ShareProvider>(
          builder: (context, cP, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: RefreshIndicator(
                color: primaryBlue,
                onRefresh: () async {
                  Provider.of<ViewProvider>(context, listen: false).resetStates(context);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const AirdeskAndLogo(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 30),
                      child: Text(
                        "Share links, texts and files between internet devices and people instantly.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ),
                    ),
                    // Image.asset("assets/home-Illustration.png"),
                    const ViewContainer(),
                    const SizedBox(height: 30),
                    UploadFile(pickFile: () async => cP.pickFiles()),
                    const SizedBox(height: 10),
                    if (cP.file.isNotEmpty || editFiles.isNotEmpty || sharedFiles.isNotEmpty)
                      SizedBox(
                        child: ListView.separated(
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemCount: (cP.file.length + editFiles.length + sharedFiles.length),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (index < cP.file.length) {
                              // Files from ShareProvider
                              File file = cP.file[index];
                              return FileItem(
                                filePath: file.path,
                                onRemove: () {
                                  cP.onRemove(index, sharedFiles);
                                },
                              );
                            }
                            else if (index < cP.file.length + editFiles.length) {
                              // Files from editFiles (EditFile)
                              int editIndex = index - cP.file.length;
                              final editFile = editFiles[editIndex];
                              return FileItem(
                                filePath: editFile.url,
                                fileName: editFile.originalName,
                                onRemove: () {
                                  setState(() {
                                    editFiles.removeAt(editIndex);
                                  });
                                  // Provider.of<ShareProvider>(context, listen: false).removeEditFileByPath(editFile.url);
                                },
                              );
                            }
                            else {
                              // Shared files from _sharedFiles
                              int sharedIndex = index - cP.file.length - editFiles.length;
                              final sharedFile = sharedFiles[sharedIndex];
                              return FileItem(
                                filePath: sharedFile.value!,
                                onRemove: () {
                                  setState(() {
                                    debugPrint('Removing shared file: ${sharedFile.value} with index: $sharedIndex');
                                    // Find the current index of this shared file
                                    final currentIndex = sharedFiles.indexWhere((f) => f.value == sharedFile.value);
                                    if (currentIndex >= 0) {
                                      debugPrint('Found shared file at current index: $currentIndex');
                                      sharedFiles.removeAt(currentIndex);
                                    } else {
                                      debugPrint('Shared file not found in the list');
                                    }
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
              ),
            );
          }
        ),
      ),
    );
  }
}