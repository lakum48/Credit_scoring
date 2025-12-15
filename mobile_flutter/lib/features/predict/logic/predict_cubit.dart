import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/credit_api.dart';
import '../data/models/client_data.dart';
import '../data/models/predict_response.dart';

sealed class PredictState {}

class PredictIdle extends PredictState {}

class PredictLoading extends PredictState {}

class PredictSuccess extends PredictState {
  PredictSuccess(this.response);
  final PredictResponse response;
}

class PredictError extends PredictState {
  PredictError(this.message);
  final String message;
}

class PredictCubit extends Cubit<PredictState> {
  PredictCubit(this._api) : super(PredictIdle());

  final CreditApi _api;

  Future<void> submit(ClientData data) async {
    emit(PredictLoading());
    try {
      final result = await _api.predict(data);
      emit(PredictSuccess(result));
    } on DioException catch (e) {
      emit(PredictError(e.message ?? 'Ошибка сети'));
    } catch (e) {
      emit(PredictError(e.toString()));
    }
  }
}

