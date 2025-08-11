// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:air_desk/api/api_config.dart';
import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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

  bool _isLive = false;
  bool get isLive => _isLive;

  void setIsLive(bool value) {
    _isLive = value;
    debugPrint('Is Live: $_isLive');
    notifyListeners();
  }

  // List<File> _editFiles = [];
  // List<File> get editFiles => _editFiles;

  // String _editText = '';
  // String get editText => _editText;

  String? _editAdminCode;

  void getEditFiles(BuildContext context) async {
    final getEditController = Provider.of<ViewProvider>(context).sendCodeController.text.trim(); 
    const baseUrl = ApiConfig.getData;
    final url = '${baseUrl}edit/$getEditController';

    try {
      final response = await http.get(Uri.parse(url));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final editData = responseBody['data'];
        _shareController.text = editData['text'];
        _file = editData['images'];
        _editAdminCode = editData['editCode'];
      }
    } catch (error) {
      debugPrint('An Error Occurred when getting edit for desk');
    }
  }

  void updateEdit(BuildContext context) async {
    const baseUrl = ApiConfig.getData;
    final uri = Uri.parse('${baseUrl}edit/$_editAdminCode');

    var request = http.MultipartRequest('POST', uri);
    request.fields['content'] = _shareController.text;

    for (var file in _file) {
      debugPrint("Adding local file");
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
      debugPrint("File path: ${file.path}");
    }

    try {
      _isLoading = true;

      var response = await request.send();

      if (response.statusCode == 200) {
        // TODO: Clear share controller and files
        _shareController.clear();
        clearFiles(context);
      }
    } catch (error) {
      debugPrint('Error Sending edited data: $error');
      throw Exception('Can\'t edit data because: $error');
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'jpeg', 'gif', 'png']
    );

    if (result != null) {
      final newFiles = result.paths.map((path) => File(path!)).toList();
      _file.addAll(newFiles);
    }
    notifyListeners();
  }

  void clearFiles(BuildContext context) {
    _file.clear();
    context.read<ReceiveFileProvider>().sharedFiles.clear();
    notifyListeners();
  }

  Future<void> postData(BuildContext context, List<SharedFile> sharedFiles) async {
    final url = Uri.parse("$baseUrl/dynamic");

    // Add text content to the request
    var request = http.MultipartRequest('POST', url);
    request.fields['content'] = _shareController.text;

    if (_isLive) {
      debugPrint('Desk is Live');
      request.fields['deskType'] = 'live';
    }

    // Handle locally picked files
    for (var file in _file) {
      debugPrint("Adding local file");
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
      debugPrint("File path: ${file.path}");
    }

    // Handle shared files
    for (var sharedFile in sharedFiles) {
      debugPrint("Adding shared file");
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          sharedFile.value!,
        ),
      );
      debugPrint("Shared file path: ${sharedFile.value}");
    }

    try {
      _isLoading = true;
      notifyListeners();
      debugPrint("Request fields: ${request.fields}");
      debugPrint("Total files to upload: ${request.files.length}");

      // Send the request and get the response
      var response = await request.send();
      debugPrint("Response status code: ${response.statusCode}");
      debugPrint("Request Response: ${response.request}");

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        debugPrint("Status: $responseBody");
        
        final generatedCode = responseData["data"]["code"];

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
        clearFiles(context);
        _isLoading = false;
        notifyListeners();

        debugPrint('Success: $responseData');
      } else {
        debugPrint('Error: ${response.statusCode}, Body: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Network error: $e');
    } finally {
      _isLoading = false;
      _shareController.clear();
      // clearFiles(context);
      notifyListeners();
    }
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
