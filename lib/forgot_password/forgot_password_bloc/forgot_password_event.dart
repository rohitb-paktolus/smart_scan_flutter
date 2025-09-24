part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
}

class ForgotPasswordGetOTPEvent extends ForgotPasswordEvent {
  final ForgotPasswordGetOTPRequest forgotPasswordGetOTPRequest;

  const ForgotPasswordGetOTPEvent({required this.forgotPasswordGetOTPRequest});

  @override
  List<Object?> get props => [forgotPasswordGetOTPRequest];
}

class VerifyOTPEvent extends ForgotPasswordEvent {
  final VerifyOTPRequest verifyOTPRequest;

  const VerifyOTPEvent({required this.verifyOTPRequest});

  @override
  List<Object?> get props => [verifyOTPRequest];
}

class SetNewPasswordEvent extends ForgotPasswordEvent {
  final SetNewPasswordRequest setNewPasswordRequest;

  const SetNewPasswordEvent({required this.setNewPasswordRequest});

  @override
  List<Object?> get props => [setNewPasswordRequest];
}
