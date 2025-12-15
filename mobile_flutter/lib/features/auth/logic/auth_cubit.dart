import 'package:flutter_bloc/flutter_bloc.dart';
import '../../predict/data/credit_api.dart';

sealed class AuthState {}

class AuthUnknown extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  Authenticated(this.token);
  final String token;
}

class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._api) : super(AuthUnknown());

  final CreditApi _api;

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      final token = await _api.register(email, password);
      emit(Authenticated(token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final token = await _api.login(email, password);
      emit(Authenticated(token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void logout() {
    emit(AuthUnknown());
  }
}

