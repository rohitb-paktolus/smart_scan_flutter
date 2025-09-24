import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scan_flutter/registration/models/register_user_response.dart';
import 'package:smart_scan_flutter/registration/repository/registration_repository.dart';

import '../models/user_model.dart';

part 'registration_event.dart';

part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegistrationRepository registrationRepository;

  RegistrationBloc(this.registrationRepository) : super(RegistrationInitial()) {
    on<RegisterUserEvent>(_handleRegisterUserEvent);
  }

  Future<void> _handleRegisterUserEvent(
      RegisterUserEvent event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());
    try {
      final registerUserResponse =
          await registrationRepository.registerUser(event.user);
      if (registerUserResponse != null) {
        print(registerUserResponse.toJson());
        if (registerUserResponse.details?.error == null) {
          emit(RegistrationSuccess(registerUserResponse));
        } else {
          emit(RegistrationError(
              registerUserResponse.details?.message ?? "Error registering user"));
        }
      }
    } catch (error) {
      emit(RegistrationError(error.toString()));
    }
  }
}
