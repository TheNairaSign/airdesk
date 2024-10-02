// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../model/history_model.dart';
import '../pages/qr_display_page.dart';
import 'history_provider.dart';


class ShareProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading; 

  final _shareController = TextEditingController();
  TextEditingController get shareController => _shareController;

  List<File> _file = [];

  List<File> get file => _file;

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'jpeg', 'gif', 'png']
    );

    if (result != null) {
      _file = result.paths.map((path) => File(path!)).toList();
    }
    notifyListeners();
  }

  void clearFiles() {
    // final codeProvider = context.read<ShareProvider>();
    // final pickedFiles = codeProvider.file;
    _file.clear();
    notifyListeners();
  }

  Future<void> postData(BuildContext context) async {
    final url = Uri.parse("https://airdesk-server.onrender.com/api/desk/dynamic");
    final codeProvider = context.read<ShareProvider>();
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
      _isLoading = true;
      notifyListeners();
      debugPrint(request.fields.toString());

      // Send the request and get the response
      var response = await request.send();
      debugPrint(response.statusCode.toString());
      debugPrint("Request Response: ${response.request}");

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        debugPrint("Status: $responseBody");
        clearFiles(context);
        final generatedCode = responseData["data"]["code"];
        // final myCode = generatedCode.replaceAll("", '');

        addNewHistoryItem(context, generatedCode, responseData);

        // Navigate to the QRDisplayPage with the generated code
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRDisplayPage(
                data: "http://www.airdesk.me/view/$generatedCode",
                code: generatedCode,
              ),
            ),
          );
        }

        debugPrint('Success: $responseData');
      } else {
        debugPrint('Error: ${response.statusCode}, Body: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Network error: $e');
    } finally {
        _isLoading = false;
    }
    notifyListeners();
  }

  void addNewHistoryItem(BuildContext context, String generatedCode, Map<String, dynamic> responseData) async {
    debugPrint("Adding new history item");
    final historyController = context.read<HistoryProvider>();
    List<HistoryItem>? existingHistory = await historyController.getHistoryItems();

    // Create a new HistoryItem
    debugPrint("Adding new item");
    HistoryItem newItem = HistoryItem(
      code: generatedCode,
      id: responseData['data']['_id'],
      createdAt: responseData['data']['createdAt'],
    );

    // Append the new item to the existing history
    if (existingHistory != null) {
      debugPrint("Existing history not null");
      existingHistory.add(newItem);
    } else {
      debugPrint("New item Added");
      existingHistory = [newItem];
    }
    debugPrint("Saving to updated list");
    // Save the updated list
    historyController.saveHistoryItems(existingHistory);
}

  // Future<bool> _requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   } else {
  //     var result = await permission.request();
  //     return result == PermissionStatus.granted;
  //   }
  // }

}
