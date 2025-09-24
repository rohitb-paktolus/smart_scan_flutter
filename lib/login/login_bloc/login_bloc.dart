import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_scan_flutter/login/models/login_details.dart';
import 'package:smart_scan_flutter/login/models/login_response.dart';
import 'package:smart_scan_flutter/login/repository/login_repository.dart';
import 'package:smart_scan_flutter/utils/prefs.dart';
import 'package:smart_scan_flutter/utils/pref_key.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginEmailBloc extends Bloc<LoginEvent, LoginState> {
  LoginRepository loginRepository;

  LoginEmailBloc({required this.loginRepository}) : super(LoginInitial()) {
    on<LoginUser>(_loginUser);
  }

  FutureOr<void> _loginUser(LoginUser event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      print(event.loginDetails.toJson());
      final loginResponse = await loginRepository.loginUser(event.loginDetails);

      if (loginResponse != null) {
        // This condition is wrong
        print(loginResponse.toJson());
        if (loginResponse.error == null) {
          Prefs.setString(TOKEN, loginResponse.data?.token);
          Prefs.setString(REFRESH_TOKEN_KEY, loginResponse.data?.refreshToken);
          emit(LoginSuccess(loginResponse: loginResponse));
        } else {
          emit(LoginError(error: loginResponse.error ?? "Unexpected error"));
        }
      } else {
        emit(const LoginError(error: "Unexpected Error"));
      }
    } catch (e) {
      emit(LoginError(error: e.toString()));
    }
  }
}
