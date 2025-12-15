import 'package:flutter_bloc/flutter_bloc.dart';
import '../../predict/data/credit_api.dart';
import '../data/models/application.dart';

sealed class HistoryState {}

class HistoryIdle extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  HistoryLoaded(this.items);
  final List<Application> items;
}

class HistoryError extends HistoryState {
  HistoryError(this.message);
  final String message;
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._api) : super(HistoryIdle());

  final CreditApi _api;

  Future<void> load({int limit = 50}) async {
    emit(HistoryLoading());
    try {
      final apps = await _api.fetchApplications(limit: limit);
      emit(HistoryLoaded(apps));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}

