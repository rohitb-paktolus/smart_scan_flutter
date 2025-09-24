class SetNewPasswordResponse {
  final Data? data;
  final String? error;
  final Map<String, dynamic>? details;

  SetNewPasswordResponse({this.data, this.error, this.details});

  // Factory constructor to create an instance from JSON
  factory SetNewPasswordResponse.fromJson(Map<String, dynamic> json) {
    return SetNewPasswordResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      error: json['error'],
      details: json['details'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'error': error,
      'details': details,
    };
  }
}

class Data {
  final bool? success;
  final int? statusCode;
  final String? message;

  Data({this.success, this.statusCode, this.message});

  // Factory constructor to create an instance from JSON
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      success: json['success'],
      statusCode: json['statusCode'],
      message: json['message'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
    };
  }
}
