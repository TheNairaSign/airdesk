// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:air_desk/api/api_config.dart';
import 'package:air_desk/model/create_desk.dart';
import 'package:air_desk/model/my_desk.dart';
import 'package:air_desk/pages/main_page/my_desk/my_desk_created_page.dart';
import 'package:air_desk/pages/main_page/my_desk/my_desk_creator_page.dart';
import 'package:air_desk/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyDeskProvider extends ChangeNotifier {

  Future<void> storeAccessCode(String value) async {
    debugPrint('Stored access code: $value');

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('accessCode', value);
    notifyListeners();
  }

  final _createDeskController = TextEditingController();
  TextEditingController get createDeskController => _createDeskController;

  final _accessDeskController = TextEditingController();
  TextEditingController get accessDeskController => _accessDeskController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _deskNameValid = false;
  bool get deskNameValid => _deskNameValid;

  void updateValidity(String value) {
    debugPrint('...Updating validity...');
    if (value.isEmpty) {
      _deskNameValid = false;
      notifyListeners();
      return;
    }
    if (value.isNotEmpty && value.length < 6) {
      _deskNameValid = false;
      notifyListeners();
      return;
    } else {
      _deskNameValid = true;
      notifyListeners();
    }
    debugPrint('Validity: $_deskNameValid');
    notifyListeners();
  }

  String errorMessages() {
    final value = _createDeskController.text;
    if (value.isEmpty) {
      return 'Please enter a desk name';
    } else if (value.length < 6) {
      return 'Desk name must be at least 6 characters long';
    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Desk name must contain only letters and numbers';
    } else if (value.contains(' ')) {
      return 'Desk name must not contain spaces';
    }
    return '';
  }

  String generateMixedCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final StringBuffer buffer = StringBuffer();
    final Random random = Random();

    for (int i = 0; i < 6; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    debugPrint('Generated code: ${buffer.toString()}');

    return buffer.toString();
  }

  String _publicCode = '';
  String get public => _publicCode;

  String _adminCode = '';
  String get admin => _adminCode;

  // bool _isLoading = false;
  // bool get isLoading => _isLoading;

  Future<void> createDesk(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    const config = ApiConfig.getData;
    const url = '${config}create';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'customCode': _createDeskController.text,
        },
      );
      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        debugPrint('Desk created successfully');
        final json = jsonDecode(response.body);
        final desk = CreateDesk.fromJson(json);
        debugPrint('Create Desk Response: $desk');
        _publicCode = desk.publicCode;
        _adminCode = desk.adminCode;

        notifyListeners();
        _createDeskController.clear();

        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDeskCreatedPage()));

        
      } else {
        debugPrint('Failed to create desk: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }

    } on http.ClientException catch (e) {
      debugPrint('Failed to create desk: $e');
    }
  }

  MyDeskData? _myDeskData;
  MyDeskData? get myDeskData => _myDeskData;

  Future<MyDeskData?> getCreatorDesks(BuildContext context, {bool load = true, String? accessCode}) async {

    if (load) {
      _isLoading = true;
      notifyListeners();
    }

    final adminCode = accessCode ?? _accessDeskController.text;


    const config = ApiConfig.baseUrl;
    final url = '$config/api/myDesk/admin/$adminCode';

    try {
      final response = await http.get(Uri.parse(url));
      final body = json.decode(response.body);
      debugPrint('Get creator desk body: $body');
      _myDeskData = MyDeskData.fromJson(body['data']);
      notifyListeners();

      if (load) {
        _isLoading = false;
        notifyListeners();
        if (_myDeskData != null) {
          storeAccessCode(adminCode);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDeskCreatorPage()));
        } else {
          snackBar('Desk does not exist', context, isError: true);
          _accessDeskController.clear();
        }
      }
      return _myDeskData;
    } on http.ClientException catch (error) {
      if (load) {
        _isLoading = false;
        notifyListeners();
      }
      debugPrint('Error getting creator desks: $error');
      return null;
    }
  }

  bool _deskExists = false;
  bool get deskExists => _deskExists;

  Future<void> checkDesk(BuildContext context, String deskName) async {
    const config = ApiConfig.baseUrl;
    // Constructs API URL and removes any @ symbols from the desk name for validation
    final url = '$config/api/myDesk/check/$deskName'.replaceAll('@', '');

    try {
      final response = await http.get(Uri.parse(url));
      final body = json.decode(response.body);
      debugPrint('Get creator desk body: $body');
      if (body['data']['exists'] == false) {
        _deskExists = false;
        debugPrint('Desk does not exist');
        snackBar('Desk does not exist', context, isError: true);
        notifyListeners();
      } else {
        debugPrint('Desk exists');
        _deskExists = true;
        snackBar('Desk exists', context);
        notifyListeners();
      }
    } on http.ClientException catch (error) {
      debugPrint('Error getting creator desks: $error');
      snackBar('Error getting creator desks', context, isError: true);
    }
  }

  // Future<void> accessMyDesk() async {

  // }


  @override
  void dispose() {
    super.dispose();
    _createDeskController.dispose();
  }
}