// ...existing imports...

// Represents an editable file with both url and original name

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:air_desk/constants.dart';
import 'package:air_desk/model/image_data.dart';
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

class EditFile {
  
  final String url;
  final String originalName;
  EditFile({required this.url, required this.originalName});
}

class ShareProvider extends ChangeNotifier {

  void removeEditFileByPath(String url) {
    final removeIndex = _file.indexWhere((f) {
      // if (f.url.startsWith('http')) {
        debugPrint('Checking URL: ${f.path}');
        debugPrint('Against: $url');
        return f.path == url;
      // }
      // return f.url == url;
    });
    if (removeIndex >= 0) {
      _file.removeAt(removeIndex);
      notifyListeners();
    }
    debugPrint('Removed file at index: $removeIndex');
  }

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

  final List<EditFile> _editFiles = [];
  List<EditFile> get editFiles => _editFiles;

  String _editText = '';
  String get editText => _editText;

  String? _editAdminCode;
  String? get editAdminCode => _editAdminCode;

  bool _isEdit = false;
  bool get isEdit => _isEdit;

  bool isNetworkFile(String filePath) {
    return filePath.startsWith('http') || filePath.startsWith('https');
  }

  void getEditFiles(BuildContext context, String editCode) async {
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
        final newFiles = (editData['images'] as List).map((img) => ImageData.fromJson(img)).toList();
        debugPrint('Edit files before: $editFiles');
        _file.clear();
        final Set<String> seenNames = {};
        debugPrint('New files is list');
        for (var fileData in newFiles) {
          final filePath = fileData.url;
          debugPrint('File path: $filePath');
          final originalName = fileData.originalName;
          if (filePath != null && originalName != null) {
            if (!seenNames.contains(originalName)) {
              seenNames.add(originalName);
              final path = filePath.startsWith('http') ? filePath : filePath.replaceAll('file://', '');
              debugPrint('Adding file: $path with original name: $originalName');
              _editFiles.add(EditFile(url: path, originalName: originalName));
              // _file.addAll([File(path)]);
            } else {
              debugPrint('Duplicate file skipped by name: $originalName');
            }
            debugPrint('Edit files after: ${fileData.originalName}');
          }
        }
        debugPrint('<--------------->');
        debugPrint('Files after: $_file');
        _editAdminCode = editData['editCode'];
        notifyListeners();
      } else {
        debugPrint('Desk has expired and cannot be edited');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Desk has expired and cannot be edited.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        final viewProvider = Provider.of<ViewProvider>(context, listen: false);
        viewProvider.sendCodeController.clear();
      }
    } catch (error) {
      _isEdit = false;
      notifyListeners();
      debugPrint('An Error Occurred when getting edit for desk: $error');
    }
  }

  void onRemove(int index, List<SharedFile> sharedFiles) {
    if (index < _file.length) {
      // Remove from local files
      _file.removeAt(index);
    } else if (index < _file.length + _editFiles.length) {
      // Remove from edit files
      int editIndex = index - _file.length;
      _editFiles.removeAt(editIndex);
    } else {
      // Remove from shared files
      int sharedIndex = index - _file.length - _editFiles.length;
      sharedFiles.removeAt(sharedIndex);
    }
    notifyListeners();
  }

  Future<void> updateEdit(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final viewProvider = Provider.of<ViewProvider>(context, listen: false);

    debugPrint('Update Edit code: $_editAdminCode');

    final uri = Uri.parse('$baseUrl/edit/$_editAdminCode');

    var request = http.MultipartRequest('PUT', uri);

    // Add text content
    request.fields['content'] = _shareController.text;

    // Handle files
    if (_editFiles != _file) {
      debugPrint('File Edited');
      // Create a list to store URLs of network files
      List<String> networkUrls = [];
      
      for (var file in _file) {
        debugPrint("Processing file: ${file.path}");
        
        if (file.path.startsWith('http')) {
          // For network URLs, just add them to the list of URLs
          debugPrint("Adding network URL: ${file.path}");
          networkUrls.add(file.path);
        } else {
          // For local files, add them as multipart files
          debugPrint("Adding local file: ${file.path}");
          request.files.add(await http.MultipartFile.fromPath('files', file.path));
        }
      }
      
      // Add network URLs as a JSON array in a field
      if (networkUrls.isNotEmpty) {
        request.fields['fileUrls'] = jsonEncode(networkUrls);
        debugPrint("Added network URLs: $networkUrls");
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
