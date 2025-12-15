import 'package:dio/dio.dart';
import 'models/client_data.dart';
import 'models/predict_response.dart';

class CreditApi {
  CreditApi(this._dio);

  final Dio _dio;

  Future<PredictResponse> predict(ClientData data) async {
    final response = await _dio.post('/score', data: data.toJson());
    return PredictResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

