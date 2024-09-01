// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/api_service.dart';
import '../pages/data_page/qr_data_page.dart';
import '../utils/error_dialog.dart';
import '../utils/loading_dialog.dart';


class ViewProvider extends ChangeNotifier {
  final _viewController = TextEditingController();
  TextEditingController get viewController => _viewController;

  Future<void> fetchData(BuildContext context, String deskId) async {
    showLoadingDialog(context);
    final url = 'https://airdesk-server.onrender.com/api/desk/$deskId';
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
    }
    notifyListeners();
  }
  
  
}