import 'dart:convert';
import 'dart:io';

import 'package:air_desk/api/api_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShareRepository {
  Future<Map<String, dynamic>> getEditFiles(String editCode) async {
    const baseUrl = ApiConfig.baseUrl; 
    final url = '$baseUrl/edit/$editCode';
    final response = await http.get(Uri.parse(url));
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseBody['data'];
    } else {
      throw Exception('Desk has expired and cannot be edited');
    }
  }

  Future<void> updateEdit({
    required String editAdminCode,
    required String content,
    required List<String> imagesToRemove,
    required List<File> newFiles,
  }) async {

    const baseUrl = ApiConfig.baseUrl; 
    final uri = Uri.parse('$baseUrl/edit/$editAdminCode');
    var request = http.MultipartRequest('PUT', uri);
    request.fields['content'] = content;
    request.fields['imagesToRemove'] = json.encode(imagesToRemove);

    for (var file in newFiles) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Update Edit failed: ${response.reasonPhrase}');
    }
  }

  Future<void> submitToDesk({
    required String deskName,
    required String content,
    required List<File> files,
  }) async {
    const baseUrl = ApiConfig.baseUrl; 
    final url = Uri.parse('$baseUrl/mydesk/submit/${deskName.replaceAll('@', '')}');
    var request = http.MultipartRequest('POST', url);
    request.fields['content'] = content;

    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    var response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Invalid desk name, try again with another desk name');
    }
  }

  Future<List<File>> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'jpeg', 'gif', 'png']
      );

    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> postData({
    required String content,
    required bool isLive,
    required List<File> localFiles,
    required List<String> sharedFilePaths,
  }) async {

    const baseUrl = ApiConfig.baseUrl; 
    final url = Uri.parse("$baseUrl/dynamic");
    var request = http.MultipartRequest('POST', url);
    request.fields['content'] = content;

    if (isLive) {
      request.fields['deskType'] = 'live';
    }

    for (var file in localFiles) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    for (var path in sharedFilePaths) {
      request.files.add(await http.MultipartFile.fromPath('files', path));
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    debugPrint('Share Response Body: $responseBody');
    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Error posting data: ${response.reasonPhrase}');
    }
  }
}
