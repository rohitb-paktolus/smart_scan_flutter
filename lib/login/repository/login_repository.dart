import 'package:dio/dio.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'package:smart_scan_flutter/login/models/login_details.dart';
import 'package:smart_scan_flutter/utils/api_constants.dart';

import 'package:smart_scan_flutter/login/models/login_response.dart';

class LoginRepository {
  final _dio = Dio();
  final DatabaseHelper databaseHelper;

  LoginRepository({required this.databaseHelper});

  Future<LoginResponse> loginUser(LoginDetails loginDetails) async {
    print(loginDetails.toJson());
    try {
      final response = await _dio.post(
        '$BASE_URL$LOGIN',
        data: loginDetails.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      var data = response.data;

      final loginResponse = LoginSuccessResponse(
        LoginSuccessModel.fromJson(data),
      );
      print("LoginResponse");
      print(loginResponse.data.toJson());
      return loginResponse;
    } on DioException catch (e) {
      print("LoginError");
      print(e.response.toString());
      print(e.response?.statusCode);
      if (e.response?.statusCode != null) {
        LoginResponse loginResponse = LoginFailureResponse(
          LoginFailureModel.fromJson(e.response?.data),
        );
        return loginResponse;
      }

      LoginResponse loginResponse = LoginFailureResponse(
        LoginFailureModel(
          message: "Could not connect to the server.",
          error: "Unknown Error",
          statusCode: 500,
        ),
      );
      return loginResponse;
    }
  }
}
