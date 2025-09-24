part of 'registration_bloc.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();
}

class RegisterUserEvent extends RegistrationEvent {
  final UserModel user;

  const RegisterUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}
