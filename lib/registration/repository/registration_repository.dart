import 'package:dio/dio.dart';
import 'package:smart_scan_flutter/registration/models/register_user_response.dart';
import 'package:smart_scan_flutter/registration/models/user_model.dart';
import 'package:smart_scan_flutter/utils/api_constants.dart';

class RegistrationRepository {
  final Dio _dio = Dio();

  RegistrationRepository();

  Future<RegisterResult> registerUser(
    RegisterRequestModel registerRequest,
  ) async {
    try {
      final response = await _dio.post(
        '$BASE_URL$REGISTER',
        data: registerRequest.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      final data = response.data;
      print("Success $data");
      print("Success ${response.data['message']}");
      return RegisterSuccess(RegisterSuccessModel.fromJson(data));
    } on DioException catch (error) {
      return RegisterFailure(
        RegisterFailureModel.fromJson(error.response?.data),
      );
    }
  }
}
