part of 'registration_bloc.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();
}

class RegisterUserEvent extends RegistrationEvent {
  final RegisterRequestModel registerRequest;

  const RegisterUserEvent(this.registerRequest);

  @override
  List<Object?> get props => [registerRequest];
}
