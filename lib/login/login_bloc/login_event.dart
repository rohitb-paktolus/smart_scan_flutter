part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
}

final class LoginUser extends LoginEvent {
  final LoginDetails loginDetails;

  const LoginUser({
    required this.loginDetails,
  });

  @override
  List<Object?> get props => [loginDetails];
}
