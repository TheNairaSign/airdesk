import 'dart:convert';

import 'package:air_desk/api/api_config.dart';
import 'package:air_desk/core/failures/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class PaymentRepository {

  Future<Either<Failure, Map<String, dynamic>>> initializePayment({
    required String adminCode, 
    required String email
  }) async {
    const baseUrl = ApiConfig.baseUrl;
    const url = '$baseUrl/payment/initialize';

    final body = jsonEncode({
      'amount': 250000,
      'email': email,
      'callbackUrl': "https://www.airdesk.me/payment/success?adminCode=$adminCode",
      'metadata': {
        'adminCode': adminCode,
        'plan': 'premium',
      },
    });
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success']) {
          return Right(data);
        } else {
          return Left(Failure(data['message']));
        }
      } else {
        return Left(Failure('Error initializing payment: ${response.reasonPhrase}'));
      }
    } catch (error) {
      debugPrint('Error: $error');
      return Left(Failure('Error initializing payment: $error'));
    }
  }
}
