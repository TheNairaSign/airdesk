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

  final bool _isLoading = false;
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

  String? _publicCode = '';
  String? get public => _publicCode;

  String? _adminCode = '';
  String? get admin => _adminCode;

  bool _createLoading = false;
  bool get createLoading => _createLoading;

  Future<void> createDesk(BuildContext context) async {
    _createLoading = true;
    notifyListeners();

    const baseUrl = 'https://airdesk-be.onrender.com/api/myDesk';

    const url = '$baseUrl/create';

    debugPrint('Desk creation code: ${ _createDeskController.text}');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'customCode': _createDeskController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      _createLoading = false;
      notifyListeners();

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('Desk created successfully');
        debugPrint('Create Desk Response: $json');

        final desk = CreateDesk.fromJson(json['data']);
        debugPrint('Create Desk Response: $desk');

        _publicCode = desk.publicCode;
        _adminCode = desk.adminCode;
        debugPrint('Public Code: $_publicCode');
        debugPrint('Admin Code: $_adminCode');

        notifyListeners();
        _createDeskController.clear();
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDeskCreatedPage()));

        
      } else if (response.statusCode == 500 && json['message'].toString().contains('already taken')) {
        _deskExists = true;
        notifyListeners();
        debugPrint('Desk already exists with status code: ${response.statusCode}');
        _createLoading = false;
        notifyListeners();
      } else {
        _createLoading = false;
        notifyListeners();
        debugPrint('Failed to create desk: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }

    } on http.ClientException catch (e) {
      debugPrint('Failed to create desk: $e');
      _createLoading = false;
      notifyListeners();
    } finally {
      // _createDeskController.clear();
      // _deskExists = false;
      notifyListeners();
    }
  }

  MyDeskData? _myDeskData;
  MyDeskData? get myDeskData => _myDeskData;

  bool _accessLoading = false;
  bool get accessLoading => _accessLoading;

  bool _deskAvailable = true;
  bool get deskAvailable => _deskAvailable;

  Future<MyDeskData?> getCreatorDesks(BuildContext context, {bool load = true}) async {
  try {
    // Get stored access code or use input
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('accessCode');
    String? adminCode = _accessDeskController.text.isEmpty ? existing : _accessDeskController.text;

    // Set loading state if needed
    if (load) {
      _setLoadingState(true);
    }

    // Make API request
    final url = '${ApiConfig.baseUrl}/api/myDesk/admin/$adminCode';
    final response = await http.get(Uri.parse(url));
    final body = json.decode(response.body);

    debugPrint('Get creator desks response: $body with status code: ${response.statusCode}');

    // Handle successful response
    if (response.statusCode == 200) {
      _myDeskData = MyDeskData.fromJson(body['data']);
      // Store new access code if needed
      if (load && existing != adminCode && adminCode != null) {
        debugPrint('Storing new access code: $adminCode');
        await storeAccessCode(adminCode);
      }

      // Navigate if loading
      if (load) {
        Navigator.of(context)
          ..pop()
          ..push(MaterialPageRoute(
            builder: (context) => const MyDeskCreatorPage(),
          ));
      }
    } else {
      snackBar('Desk does not exist', context, isError: true);
      _clearAccessDeskController();
      return null;
    }

    return _myDeskData;

  } catch (e) {
    debugPrint('Error getting creator desks: $e');
    snackBar('Error getting creator desks', context, isError: true);
    _clearAccessDeskController();
    return null;
  } finally {
    if (load) {
      _setLoadingState(false);
    }
  }
}

void _setLoadingState(bool isLoading) {
  _accessLoading = isLoading;
  notifyListeners();
}

void _clearAccessDeskController() {
  _accessDeskController.clear();
}

  bool? _deskExists;
  bool? get deskExists => _deskExists;

  bool _checkingDesk = false;
  bool get checkingDesk => _checkingDesk;

  Future<bool?> checkDesk(BuildContext context, String deskName) async {
    _checkingDesk = true;
    notifyListeners();
    const config = ApiConfig.baseUrl;
    // Constructs API URL and removes any @ symbols from the desk name for validation
    final url = '$config/api/myDesk/check/$deskName'.replaceAll('@', '');

    try {
      final response = await http.get(Uri.parse(url));
      final body = json.decode(response.body);
      debugPrint('Get creator desk body: $body');
      _checkingDesk = false;
      notifyListeners();
      if (body['data']['exists'] == false) {
        _deskExists = false;
        debugPrint('Desk does not exist');
        snackBar('Desk does not exist', context, isError: true);
        notifyListeners();
        return false;
      } else {
        debugPrint('Desk exists');
        _deskExists = true;
        notifyListeners();
        return true;
      }
    } on http.ClientException catch (error) {
      debugPrint('Error getting creator desks: $error');
      snackBar('Error getting creator desks', context, isError: true);
      _checkingDesk = false;
      notifyListeners();
      return null;
    }
  }


  @override
  void dispose() {
    super.dispose();
    _createDeskController.dispose();
    _accessDeskController.dispose();
  }
}