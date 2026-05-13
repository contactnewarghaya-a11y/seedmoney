import 'package:dio/dio.dart';

class ExploreApi {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api', 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    try {
      final response = await dio.get('/explore', queryParameters: {'query': query});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }
}
