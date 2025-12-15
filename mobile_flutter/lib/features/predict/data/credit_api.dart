import 'package:dio/dio.dart';
import '../../history/data/models/application.dart';
import '../data/models/client_data.dart';
import '../data/models/predict_response.dart';

class CreditApi {
  CreditApi(this._dio);

  final Dio _dio;

  Future<PredictResponse> predict(ClientData data) async {
    final response = await _dio.post('/score', data: data.toJson());
    return PredictResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Application>> fetchApplications({int limit = 50}) async {
    final response =
        await _dio.get('/applications', queryParameters: {'limit': limit});
    final data = response.data as List<dynamic>;
    return data
        .map((e) => Application.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> register(String email, String password) async {
    final response =
        await _dio.post('/register', data: {'email': email, 'password': password});
    return response.data['token'] as String;
  }

  Future<String> login(String email, String password) async {
    final response =
        await _dio.post('/login', data: {'email': email, 'password': password});
    return response.data['token'] as String;
  }
}

