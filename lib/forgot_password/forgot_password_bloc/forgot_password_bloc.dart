import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_scan_flutter/forgot_password/models/forgot_password_get_otp_request.dart';
import 'package:smart_scan_flutter/forgot_password/models/forgot_password_get_otp_response.dart';
import 'package:smart_scan_flutter/forgot_password/models/set_new_password_request.dart';
import 'package:smart_scan_flutter/forgot_password/models/set_new_password_response.dart';
import 'package:smart_scan_flutter/forgot_password/models/verify_otp_request.dart';
import 'package:smart_scan_flutter/forgot_password/models/verify_otp_response.dart';
import 'package:smart_scan_flutter/forgot_password/repository/forgot_password_repository.dart';

part 'forgot_password_event.dart';

part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordRepository forgotPasswordRepository;

  ForgotPasswordBloc({required this.forgotPasswordRepository})
      : super(ForgotPasswordInitial()) {
    on<ForgotPasswordGetOTPEvent>(_handleForgotPasswordGetOTPEvent);
    on<VerifyOTPEvent>(_handleVerifyOTPEvent);
    on<SetNewPasswordEvent>(_handleSetNewPasswordEvent);
  }

  Future<void> _handleForgotPasswordGetOTPEvent(ForgotPasswordGetOTPEvent event,
      Emitter<ForgotPasswordState> emit) async {
    emit(ForgotPasswordGetOTPLoading());
    try {
      final forgotPasswordOTPResponse = await forgotPasswordRepository
          .getOTP(event.forgotPasswordGetOTPRequest);
      if (forgotPasswordOTPResponse != null) {
        if (forgotPasswordOTPResponse.data?.statusCode == 200 &&
            forgotPasswordOTPResponse.error == null) {
          emit(ForgotPasswordGetOTPSuccess(
              forgotPasswordGetOTPResponse: forgotPasswordOTPResponse));
        } else {
          emit(ForgotPasswordGetOTPError(
              error: forgotPasswordOTPResponse.error ?? "Unexpected error"));
        }
      }
    } catch (e) {
      emit(ForgotPasswordGetOTPError(error: e.toString()));
    }
  }

  Future<void> _handleVerifyOTPEvent(
      VerifyOTPEvent event, Emitter<ForgotPasswordState> emit) async {
    emit(VerifyOTPLoading());
    try {
      final verifyOTPResponse =
          await forgotPasswordRepository.verifyOTP(event.verifyOTPRequest);
      if (verifyOTPResponse != null) {
        if (verifyOTPResponse.data?.statusCode == 200 &&
            verifyOTPResponse.error == null) {
          emit(VerifyOTPSuccess(verifyOTPResponse: verifyOTPResponse));
        } else {
          emit(VerifyOTPError(
              error: verifyOTPResponse.error ?? "Unexpected error"));
        }
      }
    } catch (e) {
      emit(VerifyOTPError(error: e.toString()));
    }
  }

  Future<void> _handleSetNewPasswordEvent(
      SetNewPasswordEvent event, Emitter<ForgotPasswordState> emit) async {
    emit(SetNewPasswordLoading());
    try {
      final setNewPasswordResponse = await forgotPasswordRepository
          .setNewPassword(event.setNewPasswordRequest);
      if (setNewPasswordResponse != null) {
        if (setNewPasswordResponse.data?.statusCode == 200 &&
            setNewPasswordResponse.error == null) {
          emit(SetNewPasswordSuccess(
              setNewPasswordResponse: setNewPasswordResponse));
        } else {
          emit(SetNewPasswordError(
              error: setNewPasswordResponse.error ?? "Unexpected error"));
        }
      }
    } catch (e) {
      emit(SetNewPasswordError(error: e.toString()));
    }
  }
}
