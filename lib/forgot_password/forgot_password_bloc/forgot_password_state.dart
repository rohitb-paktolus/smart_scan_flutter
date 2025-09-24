part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  @override
  List<Object> get props => [];
}

final class ForgotPasswordGetOTPLoading extends ForgotPasswordState {
  @override
  List<Object?> get props => [];
}

final class ForgotPasswordGetOTPSuccess extends ForgotPasswordState {
  final ForgotPasswordGetOTPResponse forgotPasswordGetOTPResponse;

  const ForgotPasswordGetOTPSuccess(
      {required this.forgotPasswordGetOTPResponse});

  @override
  List<Object?> get props => [forgotPasswordGetOTPResponse];
}

final class ForgotPasswordGetOTPError extends ForgotPasswordState {
  final String error;

  const ForgotPasswordGetOTPError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class VerifyOTPLoading extends ForgotPasswordState {
  @override
  List<Object?> get props => [];
}

final class VerifyOTPSuccess extends ForgotPasswordState {
  final VerifyOTPResponse verifyOTPResponse;

  const VerifyOTPSuccess({required this.verifyOTPResponse});

  @override
  List<Object?> get props => [verifyOTPResponse];
}

final class VerifyOTPError extends ForgotPasswordState {
  final String error;

  const VerifyOTPError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class SetNewPasswordLoading extends ForgotPasswordState {
  @override
  List<Object?> get props => [];
}

final class SetNewPasswordSuccess extends ForgotPasswordState {
  final SetNewPasswordResponse setNewPasswordResponse;

  const SetNewPasswordSuccess({required this.setNewPasswordResponse});

  @override
  List<Object?> get props => [setNewPasswordResponse];
}

final class SetNewPasswordError extends ForgotPasswordState {
  final String error;

  const SetNewPasswordError({required this.error});

  @override
  List<Object?> get props => [error];
}
