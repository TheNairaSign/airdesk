import 'dart:io';
import 'dart:convert';

import 'package:air_desk/components/upload__file.dart';
import 'package:air_desk/pages/qr_display_page.dart';
import 'package:air_desk/provider/code_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ShareContainer extends StatefulWidget {
  const ShareContainer({super.key});

  @override
  State<ShareContainer> createState() => _ShareContainerState();
}

class _ShareContainerState extends State<ShareContainer> {
  File? _imageFile;
  bool _isLoading = false;
  List<File> _pickedFiles = [];
  String? base64String; // Declare globally to use later

  Future<void> postData(String code, String text) async {
    final url = Uri.parse("https://airdesk-server.onrender.com/api/desk/$code");

    // Prepare the list of base64 images
    List<String> imagesBase64 = [];
    if (_pickedFiles.isNotEmpty) {
      for (var file in _pickedFiles) {
        String base64 = await fileToBase64(file);
        imagesBase64.add(base64);
      }
    }

    // Prepare the request body
    final body = jsonEncode({
      "code": code, // Adjust as needed
      "text": text, // Use the text input
      "images": imagesBase64,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle success
        final responseData = jsonDecode(response.body);
        debugPrint('Success: $responseData');
      } else {
        // Handle server error
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      debugPrint('Network error: $e');
    }
  }

  Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _pickFiles() async {
    if (await _requestPermission(Permission.storage)) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        base64String = await fileToBase64(file); // Update the global variable

        setState(() {
          _pickedFiles.addAll(result.paths.map((path) => File(path!)).toList());
        });
      }
    } else {
      debugPrint('Permission denied');
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  final _spinKit = const SpinKitThreeBounce(
    color: Colors.white,
    size: 15,
  );

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color.fromRGBO(0, 108, 255, 0.1);
    final codeProvider = context.read<CodeProvider>();
    final shareController = codeProvider.shareController;

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
                    controller: shareController,
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
                UploadFile(pickFile: _pickFiles),
                const SizedBox(height: 10),
                if (_pickedFiles.isNotEmpty)
                  Flexible(
                    child: SizedBox(
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemCount: _pickedFiles.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          File file = _pickedFiles[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilePreview(file),
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
                                    _pickedFiles
                                        .removeAt(index); // Remove the file
                                  });
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.close,
                                        color: Colors.red, size: 19),
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
          _sendButton(context),
        ],
      ),
    );
  }

  Positioned _sendButton(BuildContext context) {
    final codeProvider = context.read<CodeProvider>();
    final shareController = codeProvider.shareController;

    return Positioned(
      right: 30,
      bottom: -25,
      child: GestureDetector(
        onTap: () async {
          if (shareController.text.isNotEmpty) {
            setState(() {
              _isLoading = true;
            });

            try {
              // Call the postData function
              await postData(codeProvider.generatedCode, shareController.text);

              // Navigate to the QRDisplayPage after posting
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRDisplayPage(
                    data: shareController.text,
                    code: codeProvider.generatedCode,
                  ),
                ),
              );
            } catch (e) {
              debugPrint("There has been an error submitting the form: $e");
            } finally {
              setState(() {
                _isLoading = false;
              });
            }

            codeProvider.generateCode();
          }
        },
        child: _isLoading
            ? Container(
                height: 35,
                width: 60,
                decoration: BoxDecoration(
                  color: const Color(0xff0054ff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _spinKit,
              )
            : Container(
                padding: const EdgeInsets.all(13),
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff0054ff),
                ),
                child: SvgPicture.asset("assets/svg/paper-plane.svg"),
              ),
      ),
    );
  }

  Widget _buildFilePreview(File file) {
    String fileExtension = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      return Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.file(
          file,
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.insert_drive_file, color: Colors.white),
      );
    }
  }
}
