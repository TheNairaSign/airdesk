import 'dart:convert';
import 'package:air_desk/model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  // Create
  // Future<AirdeskData> createdata(AirdeskData data) async {
  //   debugPrint("Posting Data");
  //   final response = await http.post(
  //     Uri.parse(ApiConfig.baseUrl + ApiConfig.createData),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode(data.toJson()),
  //   );
  //   if (response.statusCode == 201) {
  //     return AirdeskData.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to create data');
  //   }
  //   }

  // Read
  Future<AirdeskData> getdata(String id, BuildContext context) async {
    debugPrint("Getting Data");
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.getData + id),
    );
      debugPrint(response.body.toString());
      return AirdeskData.fromJson(jsonDecode(response.body)['data']);
  }
}
