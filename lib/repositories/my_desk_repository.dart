import 'dart:convert';

import 'package:air_desk/api/api_config.dart';
import 'package:air_desk/model/create_desk.dart';
import 'package:air_desk/model/my_desk.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyDeskRepository {
  Future<void> storeAccessCode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('accessCode', value);
  }

  Future<String?> getAccessCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessCode');
  }

  Future<CreateDesk> createDesk(String customCode) async {
    const url ='${ApiConfig.baseUrl}/mydesk/create';
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({'customCode': customCode}),
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return CreateDesk.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to create desk');
    }
  }

  Future<MyDeskData> getCreatorDesks(String accessCode) async {
    // final accessCode = await getAccessCode();
    // if (accessCode == null) {
    //   throw Exception('Access code not found');
    // }
    final url = '${ApiConfig.baseUrl}/myDesk/admin/$accessCode';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return MyDeskData.fromJson(body['data']);
    } else {
      throw Exception('Desk does not exist');
    }
  }

  Future<bool> checkDesk(String deskName) async {
    const config = ApiConfig.baseUrl;
    // Constructs API URL and removes any @ symbols from the desk name for validation
    final url = '$config/mydesk/check/$deskName'.replaceAll('@', '');

    try {
      final response = await http.get(Uri.parse(url));
      final body = json.decode(response.body);
      if (body['data']['exists'] == false) {
        return false;
      } else {
        return true;
      }
    } on http.ClientException {
      rethrow;
    }
  }
}
