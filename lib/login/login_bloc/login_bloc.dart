import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'package:smart_scan_flutter/login/models/login_details.dart';
import 'package:smart_scan_flutter/login/models/login_response.dart';
import 'package:smart_scan_flutter/login/repository/login_repository.dart';
import 'package:smart_scan_flutter/utils/prefs.dart';
import 'package:smart_scan_flutter/utils/pref_key.dart';
import 'package:smart_scan_flutter/utils/secure_prefs.dart';

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
      final LoginResponse loginResponse = await loginRepository.loginUser(
        event.loginDetails,
      );

      switch (loginResponse) {
        case LoginSuccessResponse():
          await SecurePrefs().setString(TOKEN, loginResponse.data.accessToken);
          await SecurePrefs().setString(
            REFRESH_TOKEN,
            loginResponse.data.refreshToken,
          );
          await DatabaseHelper.instance.saveUserInfo(
            loginResponse.data.user.toJson(),
          );
          emit(LoginSuccess(loginResponse: loginResponse));
          break;
        case LoginFailureResponse():
          emit(LoginError(error: loginResponse.data.message));
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      emit(LoginError(error: e.toString()));
    }
  }
}
