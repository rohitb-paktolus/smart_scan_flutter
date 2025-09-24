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
    return {
      'data': data?.toJson(),
      'details': details?.toJson(),
    };
  }
}

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
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
    };
  }
}

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
