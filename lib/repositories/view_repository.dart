import 'dart:convert';

import 'package:air_desk/api/api_config.dart';
import 'package:air_desk/core/failures/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../model/desk_data.dart';

class ViewRepository {
  Future<Either<Failure, DeskData>> fetchData(String deskId) async {
    const baseUrl = ApiConfig.baseUrl; 
    final url = '$baseUrl/$deskId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final airdeskData = DeskData.fromJson(data['data']);
        return Right(airdeskData);
      } else {
        return Left(Failure('Failed to fetch data'));
      }
    } catch (e) {
      return Left(Failure('Error fetching data: $e'));
    }
  }
}

final viewRepositoryProvider = Provider<ViewRepository>((ref) => ViewRepository());
