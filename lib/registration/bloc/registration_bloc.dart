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
      final registerResult =
          await registrationRepository.registerUser(event.registerRequest);
      switch (registerResult) {
        case RegisterSuccess():
          print(registerResult.data.message);
          final data = registerResult.data;
          emit(RegistrationSuccess(data));
          break;
        case RegisterFailure():
          print(registerResult.data.message.first);
          final errorMessage = registerResult.data.message.first;
          emit(RegistrationError(errorMessage));
          break;
      }
    } catch (error) {
      emit(RegistrationError(error.toString()));
    }
  }
}
