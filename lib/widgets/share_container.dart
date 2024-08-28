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
  bool _isLoading = false;
  // List<File> pickedFiles = [];

  Future<void> postData() async {
    final url = Uri.parse("https://airdesk-server.onrender.com/api/desk/dynamic");
    final codeProvider = context.read<CodeProvider>();
    final shareController = codeProvider.shareController;
    final pickedFiles = codeProvider.file;

    // Add text content to the request
    var request = http.MultipartRequest('POST', url);
    request.fields['content'] = shareController.text;

    for (var file in pickedFiles) {
      debugPrint("Entering Loop");
      request.files.add(
        await http.MultipartFile.fromPath(
        'files',
        file.path,
      ));
      debugPrint(request.toString());
      debugPrint("File path: ${file.path}");
    }

    try {
      setState(() {
        _isLoading = true;
      });
      debugPrint(request.fields.toString());

      // Send the request and get the response
      var response = await request.send();
      print(response.statusCode.toString());
      debugPrint("Request Response: ${response.request}");

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        debugPrint("Status: $responseBody");

        final generatedCode = responseData["data"]["code"];

        // Navigate to the QRDisplayPage with the generated code
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRDisplayPage(
              data: "http://www.airdesk.me/view/$generatedCode",
              code: generatedCode,
            ),
          ),
        );

        debugPrint('Success: $responseData');
      } else {
        debugPrint('Error: ${response.statusCode}, Body: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Network error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

    return Consumer<CodeProvider>(
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
              _sendButton(context),
            ],
          ),
        );
      }
    );
  }

  Positioned _sendButton(BuildContext context) {
    return Positioned(
      right: 30,
      bottom: -25,
      child: GestureDetector(
        onTap: () async {
          debugPrint("Sending Data");
          await postData();
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
