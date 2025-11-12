// TODO: Remove later
/*
class LoginResponse {
  final Data? data;
  final String? error;
  final Details? details;

  LoginResponse({this.data, this.error, this.details});

  // Factory method to create a LoginResponse object from a JSON map
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      error: json['error'],
      details:
      json['details'] != null ? Details.fromJson(json['details']) : null,
    );
  }

  // Method to convert a LoginResponse object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'error': error,
      'details': details?.toJson(),
    };
  }
}

class Data {
  final String? token;
  final String? refreshToken;

  Data({this.token, this.refreshToken});

  // Factory method to create a Data object from a JSON map
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  // Method to convert a Data object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}

class Details {
  final String? emailAddress;

  Details({this.emailAddress});

  // Factory method to create a Details object from a JSON map
  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      emailAddress: json['emailAddress'],
    );
  }

  // Method to convert a Details object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'emailAddress': emailAddress,
    };
  }
}
*/

class LoginSuccessModel {
  final String message;
  final String accessToken;
  final String refreshToken;
  final User user;

  LoginSuccessModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginSuccessModel.fromJson(Map<String, dynamic> json) {
    return LoginSuccessModel(
      message: json['message'],
      accessToken: json['access_token'],
      refreshToken: json["refresh_token"],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'access_token': accessToken,
      "refresh_token": refreshToken,
      'user': user.toJson(),
    };
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    };
  }
}

class LoginFailureModel {
  final String message;
  final String error;
  final int statusCode;

  LoginFailureModel({
    required this.message,
    required this.error,
    required this.statusCode,
  });

  factory LoginFailureModel.fromJson(Map<String, dynamic> json) {
    return LoginFailureModel(
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'error': error, 'statusCode': statusCode};
  }
}

sealed class LoginResponse {}

class LoginSuccessResponse extends LoginResponse {
  final LoginSuccessModel data;

  LoginSuccessResponse(this.data);
}

class LoginFailureResponse extends LoginResponse {
  final LoginFailureModel data;

  LoginFailureResponse(this.data);
}
