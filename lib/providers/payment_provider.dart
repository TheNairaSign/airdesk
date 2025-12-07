import 'dart:convert';

import 'package:air_desk/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class PaymentProvider extends ChangeNotifier {
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isInitializing = false;
  bool get isInitializing => _isInitializing;

  Future<void> paymentGateway({required String adminCode, required String email}) async {
    _isInitializing = true;
    notifyListeners();

    const url = '$baseUrl/payment/initialize';

    final body = jsonEncode({
      'amount' : 250000,
      'email': email,
      'callbackUrl' : "https://www.airdesk.me/payment/success?adminCode=$adminCode",
      'metadata' : {
        'adminCode': adminCode,
        'plan': 'premium',
      },
    });
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      _isInitializing = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {

        }
      }
    } catch (error) {
      _isInitializing = false;
      notifyListeners();
      debugPrint('Error: $error');
    }
  }
}