// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../api/api_service.dart';
import '../pages/data_page/qr_data_page.dart';
import '../utils/error_dialog.dart';
import '../utils/loading_dialog.dart';


class ViewProvider extends ChangeNotifier {
  final _viewController = TextEditingController();
  TextEditingController get viewController => _viewController;

  final _sendCodeController = TextEditingController();
  TextEditingController get sendCodeController => _sendCodeController;

  // final _sendEditCodeController = TextEditingController();
  // TextEditingController get sendEditCodeController => _sendEditCodeController;

  /// If there is an initial text share from an external source
  /// The shared text becomes the initial text
  /// Otherwise the textbox remains empty
  void initialText(BuildContext context){
    final shareController = Provider.of<ShareProvider>(context, listen:  false).shareController;
    final sharedText = Provider.of<ReceiveFileProvider>(context, listen: false).sharedText;
    shareController.text = sharedText ?? '';
  }

  // This is to store the value of the textbox when changed
  void storeInitialValues(String value) {
    _viewController.text = value.trim();
    notifyListeners();
  }

  // bool _deskCredValid = false;
  // bool get deskCredValid => _deskCredValid;

  void sendToDesk() async {
    
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading; 

  Future<void> fetchData(BuildContext context, String deskId) async {
    showLoadingDialog(context);
    final url = '$baseUrl/$deskId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        debugPrint("The statusCode: ${response.statusCode}");
        var data = jsonDecode(response.body);
        final dataCode = data["data"]["code"];
        String extractedValue = dataCode.replaceAll('"', ''); // Removing quotes if necessary

        debugPrint("extracted Value: $extractedValue");
        debugPrint(data.toString());

        final ApiService apiService = ApiService();
        final airdeskData = await apiService.getdata(extractedValue, context);

        Navigator.of(context).pop(); // Close the loading dialog before navigation
        debugPrint("Switching page");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QrDataPage(
              data: jsonEncode(extractedValue),
              content: airdeskData.text,
              files: airdeskData.images,
            ),
          ),
        );
      } else {
        Navigator.of(context).pop(); // Close the loading dialog
        showErrorDialog(context);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog
      showErrorDialog(context);
      debugPrint('Error occurred: $e');
    } finally {
      _sendCodeController.clear();
    }
    notifyListeners();
  }

  Future<void> fetchOrShareData(BuildContext context, String deskId) async {
    // showLoadingDialog(context);

    // If there is a valid deskId, then view the data
    FocusScope.of(context).unfocus();
    final url = '$baseUrl/$deskId';
    try {
      _isLoading = true;
      notifyListeners();
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        debugPrint("The statusCode: ${response.statusCode}");
        var data = jsonDecode(response.body);
        final dataCode = data["data"]["code"];
        String extractedValue = dataCode.replaceAll('"', ''); // Removing quotes if necessary

        debugPrint("extracted Value: $extractedValue");
        debugPrint(data.toString());

        final ApiService apiService = ApiService();
        final airdeskData = await apiService.getdata(extractedValue, context);

        // Navigator.of(context).pop(); // Close the loading dialog before navigation

        // Try to fetch data first
        debugPrint("Switching page");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QrDataPage(
              data: jsonEncode(extractedValue),
              content: airdeskData.text,
              files: airdeskData.images,
            ),
          ),
        );
      }
      
      // If the data is not a valid deskId, then the send/share the data 
      else {
        // Navigator.of(context).pop(); // Close the loading dialog
        final shareProvider = Provider.of<ShareProvider>(context, listen: false);
        final receiveProvider = context.read<ReceiveFileProvider>();
        final sharedFile = receiveProvider.sharedFiles;

        shareProvider.postData(context, sharedFile);
        // showErrorDialog(context);
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
      _isLoading = false;
    } finally {
      _isLoading = false;
      viewController.clear();
    }
    notifyListeners();
  }

  void editDesk(BuildContext context, String editCode) {
    debugPrint('Edit code: $editCode');
    Provider.of<ShareProvider>(context, listen: false).getEditFiles(context, editCode);
  }

  bool _changeControllerState = false;
  bool get changeControllerState => _changeControllerState;

  void resetControllerState() {
    _changeControllerState = false;
    debugPrint('Reset controller State to: $_changeControllerState');
    notifyListeners();
  }

  void deskNameListener(BuildContext context) {
    final myDeskProvider = Provider.of<MyDeskProvider>(context, listen: false);

    final isMyDeskCode = _sendCodeController.text.startsWith('@') && _sendCodeController.text.substring(1).length == 8;
    if (isMyDeskCode) {
      debugPrint('Is my desk code: ${_sendCodeController.text}');
      _changeControllerState = true;
      FocusScope.of(context).unfocus();
      myDeskProvider.checkDesk(context, _sendCodeController.text);
      notifyListeners();
    } else {
      _changeControllerState = false;
      notifyListeners();
      debugPrint('Is not my desk code: ${_sendCodeController.text}');
    }
  }

  bool get isEdit {
    return !_sendCodeController.text.startsWith('@') && _sendCodeController.text.length == 9;
  } 

  void updateControllerState(BuildContext context) {
    final myDeskProvider = Provider.of<MyDeskProvider>(context, listen: false);

    // Checks if text starts with @ and has at least 6 characters after it
    final isMyDeskCode = _sendCodeController.text.startsWith('@') && _sendCodeController.text.substring(1).length >= 6;
    // final isEdit = !_sendCodeController.text.startsWith('@') && _sendCodeController.text.length == 9;
    final isRegular = !_sendCodeController.text.startsWith('@') && _sendCodeController.text.length == 6;


    if (isMyDeskCode) {
      debugPrint('Is my desk code: ${_sendCodeController.text}');

      // If it is a desk name, then check if it exists
      // If it exists, then update the validity to true
      myDeskProvider.checkDesk(context, _sendCodeController.text);
      notifyListeners();
    } else if (isEdit) {
      // If it is an edit code, then check if it exists
      // If it exists, then update the validity to true
      // If it does not exist, then update the validity to false
      editDesk(context, _sendCodeController.text);

      notifyListeners();
    } else if (isRegular) {
      // If it is a regular code, then fetch the data immediately
      fetchData(context, _sendCodeController.text);
      notifyListeners();
    }

  }

}