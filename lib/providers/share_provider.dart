// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:air_desk/api/api_config.dart';
import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/utils/success_dialog.dart';
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

  final List<File> _file = [];
  List<File> get file => _file;

  bool _isLive = false;
  bool get isLive => _isLive;

  void setIsLive(bool value) {
    _isLive = value;
    debugPrint('Is Live: $_isLive');
    notifyListeners();
  }

  final List<dynamic> _editFiles = [];
  List<dynamic> get editFiles => _editFiles;

  String _editText = '';
  String get editText => _editText;

  String? _editAdminCode;
  String? get editAdminCode => _editAdminCode;


  bool _isEdit = false;
  bool get isEdit => _isEdit;

  void getEditFiles(BuildContext context, String editCode) async {
    // final getEditController = Provider.of<ViewProvider>(context, listen: false).sendCodeController.text.trim(); 
    final url = '$baseUrl/edit/$editCode';

    try {
      final response = await http.get(Uri.parse(url));

      final responseBody = jsonDecode(response.body);

      debugPrint('Edit response body: $responseBody');
      debugPrint('Edit code: $editCode');
      if (response.statusCode == 200) {
        _isEdit = true;
        notifyListeners();

        debugPrint('Edit files gotten successfully');
        final editData = responseBody['data'];
        _editText = editData['text'];
        _shareController.text = editData['text'];
        _editAdminCode = editData['editCode'];
        final newFiles = editData['images'];
        debugPrint('Edit files before: $editFiles');
        _editFiles.addAll(newFiles);
        
        // Don't try to cast dynamic list directly to List<File>
        // Instead, process each item properly if they contain file paths
        if (newFiles != null && newFiles is List) {
          debugPrint('New files is list');
          for (var fileData in newFiles) {
            if (fileData is Map && fileData.containsKey('url')) {
              final filePath = fileData['url'];
              if (filePath != null && filePath is String) {
                _file.add(File(filePath));
                debugPrint('New files: $_file');
              }
            }
          }
        }
        
        debugPrint('Edit files after: $editFiles');
        _editAdminCode = editData['editCode'];
        notifyListeners();
      }
    } catch (error) {
      _isEdit = false;
      notifyListeners();
      debugPrint('An Error Occurred when getting edit for desk: $error');
    }
  }

  Future<void> updateEdit(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final viewProvider = Provider.of<ViewProvider>(context, listen: false);


    debugPrint('Update Edit code: $_editAdminCode');


    // const baseUrl = ApiConfig.baseUrl;
    final uri = Uri.parse('$baseUrl/edit/$_editAdminCode');

    var request = http.MultipartRequest('PUT', uri);
    if (_editText != _shareController.text) {
      debugPrint('Text Edited');
      request.fields['content'] = _shareController.text;
    }


    if (_editFiles != _file) {
      debugPrint('File Edited');
      for (var file in _file) {
      debugPrint("Adding local file");
      debugPrint("File path: ${file.path}");

      if (file.path.startsWith('http')) {
        final getImage = await http.get(Uri.parse(file.path));
        if (getImage.statusCode == 200) {
          debugPrint("Successfully downloaded file from URL: ${file.path}");
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              getImage.bodyBytes,
              filename: file.path.split('/').last, // Use name from URL
            ),
          );
        } else {
          debugPrint("Failed to download file from URL: ${file.path}");
          debugPrint("Error: ${getImage.statusCode}");
        }
        } else {
          request.files.add(await http.MultipartFile.fromPath('files', file.path));
        }
        debugPrint("File path: ${file.path}");
      }
    }

    try {

      var response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final responseJson = jsonDecode(responseBody);
      debugPrint('Response body: $responseJson');

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        debugPrint('...Edit data successful...');
        _shareController.clear();
        viewProvider.sendCodeController.clear();
        clearFiles(context);
        _isEdit = false;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error Sending edited data: $error');
      _isLoading = false;
      notifyListeners();

      throw Exception('Can\'t edit data because: $error');
    } finally {
      _isLoading = false;
      // _isEdit = false;
      notifyListeners();
    }
  }


  void submit(BuildContext context) {
    final viewProvider = Provider.of<ViewProvider>(context, listen: false);
    final deskName = viewProvider.sendCodeController.text.trim();
    final sendToDesk = viewProvider.changeControllerState;
    final isEdit = viewProvider.isEdit;

    if (sendToDesk) {
      submitToDesk(context, deskName);
    } else if (isEdit) {
      updateEdit(context);
    } else {
      postData(context, context.read<ReceiveFileProvider>().sharedFiles);
    }
  }

  void submitToDesk(BuildContext context, String deskName) async {
    _isLoading = true;
    notifyListeners();

    const config = 'https://airdesk-be.onrender.com/api/';
    deskName = deskName.replaceAll('@', '');
    final url = Uri.parse('$config/myDesk/submit/$deskName');

    var request = http.MultipartRequest('POST', url);
    request.fields['content'] = _shareController.text;

    for (var file in _file) {
      debugPrint("Adding local file");
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
      debugPrint("File path: ${file.path}");
    }

    try {

      var response = await request.send();

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        _shareController.clear();
        clearFiles(context);
      }
    } catch (error) {
      debugPrint('Error Sending edited data: $error');
      _isLoading = false;
      notifyListeners();
      throw Exception('Can\'t edit data because: $error');
    } finally {
      _shareController.clear();
      clearFiles(context);
      showSuccessDialog(
        context, 
        deskName: deskName, 
        fileNames: file.map((f) => f.path).toList(), 
        content: _shareController.text
      );
      notifyListeners();
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
    _isLoading = true;
    notifyListeners();

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
      debugPrint("Request fields: ${request.fields}");
      debugPrint("Total files to upload: ${request.files.length}");

      // Send the request and get the response
      var response = await request.send();
      _isLoading = false;
      notifyListeners();
      debugPrint("Response status code: ${response.statusCode}");
      debugPrint("Request Response: ${response.request}");

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        debugPrint("Status: $responseBody");
        
        final generatedCode = responseData["data"]["code"];
        final editCode = responseData["data"]["editCode"];

        addNewHistoryItem(context, generatedCode, responseData);

        // Navigate to the QRDisplayPage with the generated code
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRDisplayPage(
                data: "http://www.airdesk.me/view/$generatedCode",
                code: generatedCode,
                editCode: editCode,
              ),
            ),
          );
        }
        clearFiles(context);
        _isLoading = false;
        notifyListeners();

        debugPrint('Success: $responseData');
      } else {
        _isLoading = false;
        notifyListeners();

        debugPrint('Error: ${response.statusCode}, Body: ${response.reasonPhrase}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

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

}
