import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
      if (kDebugMode) {
        print(event.loginDetails.toJson());
      }
      final loginResponse = await loginRepository.loginUser(event.loginDetails);

      if (loginResponse != null) {
        if (loginResponse.error == null) {
          final String userEmail = event.loginDetails.emailAddress;
          await loginRepository.saveLocalUser(userEmail);
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
      if (kDebugMode) {
        print(e.toString());
      }
      emit(LoginError(error: e.toString()));
    }
  }
}
