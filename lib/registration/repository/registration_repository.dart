import 'package:dio/dio.dart';
import 'package:smart_scan_flutter/registration/models/register_user_response.dart';
import 'package:smart_scan_flutter/registration/models/user_model.dart';
import 'package:smart_scan_flutter/utils/api_constants.dart';

class RegistrationRepository {
  final Dio _dio = Dio();

  RegistrationRepository();

  Future<RegisterUserResponse?> registerUser(UserModel user) async {
    try {
      final response = await _dio.post(
        '$BASE_URL$REGISTER',
        data: user.toJson(),
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );
      final data = response.data;
      print("Success $data");
      print("Success ${response.data['message']}");

      if (response.statusCode == 200) {
        RegisterUserResponse registerUserResponse =
            RegisterUserResponse.fromJson(data);
        print(registerUserResponse.data?.message);
        return registerUserResponse;
      }
    } on DioException catch (error) {
      print("Error");
      print(error.response?.statusCode);
      print(error.response);
      RegisterUserResponse registerUserResponse =
          RegisterUserResponse.fromJson(error.response?.data);
      return registerUserResponse;
    }

    return null;
  }
}
