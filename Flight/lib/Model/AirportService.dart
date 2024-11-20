import 'package:dio/dio.dart';

class AirportService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://staging.abisiniya.com/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  List<Map<String, dynamic>> _cachedAirports = [];

  Future<List<Map<String, dynamic>>> fetchAirports({String query = ''}) async {
    try {
      final response = await _dio.get('/amadeus/airportlist');
      if (response.statusCode == 200) {
        _cachedAirports = List<Map<String, dynamic>>.from(response.data);
        if (query.isNotEmpty) {
          return _cachedAirports
              .where((airport) {
            final searchString = query.toLowerCase();
            return airport['name'].toString().toLowerCase().contains(searchString) ||
                airport['iata'].toString().toLowerCase().contains(searchString) ||
                airport['city'].toString().toLowerCase().contains(searchString) ||
                airport['country'].toString().toLowerCase().contains(searchString);
          })
              .toList();
        }
        return _cachedAirports;
      } else {
        throw Exception('Failed to load airports: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch data: ${e.message}');
    }
  }
}