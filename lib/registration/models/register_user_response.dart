// TODO: Remove later
class RegisterUserResponse {
  final Data? data;
  final Details? details;

  RegisterUserResponse({this.data, this.details});

  // Factory constructor to create an instance from JSON
  factory RegisterUserResponse.fromJson(Map<String, dynamic> json) {
    return RegisterUserResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      details:
          json['details'] != null ? Details.fromJson(json['details']) : null,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {'data': data?.toJson(), 'details': details?.toJson()};
  }
}

// TODO: Remove later
class Data {
  final bool? success;
  final int? statusCode;
  final String? message;

  Data({this.success, this.statusCode, this.message});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      success: json['success'],
      statusCode: json['statusCode'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'statusCode': statusCode, 'message': message};
  }
}

// TODO: Remove later
class Details {
  final int? statusCode;
  final bool? success;
  final String? error;
  final String? message;

  Details({this.statusCode, this.success, this.error, this.message});

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      statusCode: json['statusCode'],
      success: json['success'],
      error: json['error'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'error': error,
      'message': message,
    };
  }
}

class RegisterSuccessModel {
  final String message;
  final String accessToken;
  final String refreshToken;
  final User user;

  RegisterSuccessModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory RegisterSuccessModel.fromJson(Map<String, dynamic> json) {
    return RegisterSuccessModel(
      message: json['message'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
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

class RegisterFailureModel {
  final List<String> message;
  final String error;
  final int statusCode;

  RegisterFailureModel({
    required this.message,
    required this.error,
    required this.statusCode,
  });

  factory RegisterFailureModel.fromJson(Map<String, dynamic> json) {
    final messageJson = json["message"];
    List<String> messageList;

    if (messageJson is String) {
      messageList = [messageJson];
    } else if (messageJson is List) {
      messageList = List<String>.from(messageJson);
    } else {
      messageList = [];
    }

    return RegisterFailureModel(
      message: messageList,
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'error': error, 'statusCode': statusCode};
  }
}

sealed class RegisterResult {}

class RegisterSuccess extends RegisterResult {
  final RegisterSuccessModel data;

  RegisterSuccess(this.data);
}

class RegisterFailure extends RegisterResult {
  final RegisterFailureModel data;

  RegisterFailure(this.data);
}
