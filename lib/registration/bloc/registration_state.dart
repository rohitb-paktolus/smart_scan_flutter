part of 'registration_bloc.dart';

sealed class RegistrationState extends Equatable {
  const RegistrationState();
}

final class RegistrationInitial extends RegistrationState {
  @override
  List<Object> get props => [];
}

final class RegistrationLoading extends RegistrationState {
  @override
  List<Object?> get props => [];
}

final class RegistrationSuccess extends RegistrationState {
  final RegisterUserResponse registerUserResponse;

  const RegistrationSuccess(this.registerUserResponse);

  @override
  List<Object?> get props => [registerUserResponse];
}

final class RegistrationError extends RegistrationState {
  final String error;

  const RegistrationError(this.error);

  @override
  List<Object?> get props => [error];
}
