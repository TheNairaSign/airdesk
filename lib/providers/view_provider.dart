// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:air_desk/constants.dart';
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

  /// If there is an initial text share from an external source
  /// The shared text becomes the initial text
  /// Otherwise the textbox remains empty
  void initialText(BuildContext context){
    final sharedText = Provider.of<ReceiveFileProvider>(context, listen: false).sharedText;
    _viewController.text = sharedText ?? '';
  }

  // This is to store the value of the textbox when changed
  void storeInitialValues(String value) {
    _viewController.text = value.trim();
    notifyListeners();
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
              imageUrl: airdeskData.imageUrl,
              fileName: airdeskData.imageName,
              imageLength: airdeskData.images.length,
              file: airdeskData.images,
              uris: airdeskData.imageUrls,
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
              imageUrl: airdeskData.imageUrl,
              fileName: airdeskData.imageName,
              imageLength: airdeskData.images.length,
              file: airdeskData.images,
              uris: airdeskData.imageUrls,
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
}