// ...existing imports...

// Represents an editable file with both url and original name

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:air_desk/constants.dart';
import 'package:air_desk/model/image_data.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
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

  List<EditFile> _initialEditFiles = [];

  
  final String _editText = '';
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
        _initialEditFiles = (editData['images'] as List).map((img) => EditFile(url: img['url'], originalName: img['originalName'])).toList();
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
              _editFiles.add(EditFile(url: fileData.url!, originalName: originalName));
              notifyListeners();
            } else {
              debugPrint('Duplicate file skipped by name: $originalName');
            }
            debugPrint('Edit files after: ${fileData.url}');
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
            title: const Text('Invalid'),
            content: const Text('Desk has expired and cannot be found.'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: GlobalColours.errorColor.withOpacity(.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: GlobalColours.errorColor)),
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

  // Returns a list of EditFile objects that were newly added and not present in the initial files
  // by comparing URLs between current _editFiles and _initialEditFiles
  List<EditFile> getEditedFiles() {
    // Create a Set of URLs from initial files for efficient lookup
    final editPaths = _editFiles.map((e) => e.url).toSet();

    final removed = _initialEditFiles.where((f) => !editPaths.contains(f.url)).toList();
    debugPrint('Removed Files: $removed with length: ${removed.length}');

    return removed;
  }

  Future<void> updateEdit(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final viewProvider = Provider.of<ViewProvider>(context, listen: false);

    debugPrint('Update Edit code: $_editAdminCode');

    final uri = Uri.parse('$baseUrl/edit/$_editAdminCode');

    var request = http.MultipartRequest('PUT', uri);

    request.fields['content'] = _shareController.text;

    final List<String> removedFiles = [];

    for (var editedFiles in getEditedFiles()) {
      final lastSegment = Uri.parse(editedFiles.url).pathSegments.last;
      removedFiles.add(lastSegment);
      debugPrint('$removedFiles');
    }

    request.fields['imagesToRemove'] = json.encode(removedFiles);

    for (var file in _file) {
      debugPrint("Adding local file");
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
      debugPrint("File path: ${file.path}");
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
        debugPrint('Edit updated successfully');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Edit updated successfully.'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: GlobalColours.secondaryGreen.withOpacity(.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: GlobalColours(context).textColorForContainer)),
              ),
            ],
          ),
        );
        viewProvider.sendCodeController.clear();
        _editAdminCode = '';
        _isEdit = false;
        _initialEditFiles.clear();
        _editFiles.clear();
        _shareController.clear();
        _file.clear();
        notifyListeners();
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Update Edit failed: $error');
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
    final deskExists = Provider.of<MyDeskProvider>(context, listen: false).deskExists;

    if (deskExists == false) {
      // showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //       title: const Text('Invalid myDesk'),
      //       content: Text('User with MyDesk: $deskName does not exist.'),
      //       actions: [
      //         TextButton(
      //           style: TextButton.styleFrom(
      //             backgroundColor: GlobalColours.secondaryGreen.withOpacity(.1),
      //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      //           ),
      //           onPressed: () => Navigator.of(context).pop(),
      //           child: Text('OK', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: GlobalColours(context).textColorForContainer)),
      //         ),
      //       ],
      //     ),
      //   );
      return;
    }

    final viewProvider = Provider.of<ViewProvider>(context, listen: false);
    final controller = viewProvider.sendCodeController;


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
        showSuccessDialog(
          context, 
          deskName: deskName, 
          fileNames: file.map((f) => f.path).toList(), 
          content: _shareController.text,
          onPop: () {
            Navigator.of(context).pop();
            _shareController.clear();
            viewProvider.resetControllerState();
            controller.clear();
            clearFiles(context);
          }
        );
      }
    } catch (error) {
      debugPrint('Error Sending edited data: $error');
      _isLoading = false;
      notifyListeners();
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
