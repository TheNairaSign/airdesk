import 'dart:io';

import 'package:air_desk/components/upload_file.dart';
import 'package:air_desk/constants.dart';
import 'package:air_desk/pages/main_page/widgets/about.dart';
import 'package:air_desk/pages/main_page/widgets/file_item.dart';
import 'package:air_desk/pages/main_page/widgets/view_container.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {

  @override
  void initState() {
    super.initState();
    _getAccessCode();
    final receiveProvider = ref.read(receiveFileProvider.notifier);
    receiveProvider
      ..listenToSharingIntent()
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final receiveProvider = ref.watch(receiveFileProvider);
    final sharedFiles = receiveProvider.sharedFiles;
    final editFiles = ref.watch(shareProvider).editFiles;

    final shareState = ref.watch(shareProvider);

    return RefreshIndicator(
      color: primaryBlue,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onRefresh: () async {
        ref.read(viewProvider.notifier).resetStates();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const AirdeskAndLogo(),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 20),
              child: Text(
                "Share links, texts and files between internet devices and people instantly.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDark ? Colors.grey : Colors.grey[700]),
              ),
            ),
            // Image.asset("assets/home-Illustration.png"),
            const ViewContainer(),
            const SizedBox(height: 30),
            UploadFile(pickFile: () async => ref.read(shareProvider.notifier).pickFiles()),
            const SizedBox(height: 20),
            if (shareState.files.isNotEmpty || editFiles.isNotEmpty || sharedFiles.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(height: 10, color: isDark ? Colors.grey[800] : Colors.grey[200],),
                  itemCount: (shareState.files.length + editFiles.length + sharedFiles.length),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (index < shareState.files.length) {
                      // Files from ShareProvider
                      File file = shareState.files[index];
                      return FileItem(
                        filePath: file.path,
                        onRemove: () {
                          ref.read(shareProvider.notifier).onRemove(index, sharedFiles);
                        },
                      );
                    }
                    else if (index < shareState.files.length + editFiles.length) {
                      // Files from editFiles (EditFile)
                      int editIndex = index - shareState.files.length;
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
                      int sharedIndex = index - shareState.files.length - editFiles.length;
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
            const SizedBox(height: 20),
            const About(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}