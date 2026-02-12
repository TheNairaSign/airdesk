import 'dart:convert';

import 'package:air_desk/api/api_config.dart';
import 'package:air_desk/core/failures/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../model/desk_data.dart';

class ViewRepository {
  Future<Either<Failure, DeskData>> fetchData(String deskId) async {
    debugPrint('Fetching data for desk: $deskId...');
    const baseUrl = ApiConfig.baseUrl; 
    final url = '$baseUrl/desk/$deskId';
    try {
      final response = await http.get(Uri.parse(url));

      debugPrint('View Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final airdeskData = DeskData.fromJson(data['data']);
        debugPrint('View Data: $airdeskData');
        return Right(airdeskData);
      } else {
        debugPrint('Failed to fetch data');
        return Left(Failure('Failed to fetch data'));
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return Left(Failure('Error fetching data: $e'));
    }
  }
}

final viewRepositoryProvider = Provider<ViewRepository>((ref) => ViewRepository());
