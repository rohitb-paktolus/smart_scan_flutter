class ForgotPasswordGetOTPResponse {
  final Data? data;
  final String? error;
  final Details? details;

  ForgotPasswordGetOTPResponse({this.data, this.error, this.details});

  // Factory constructor to create an instance from JSON
  factory ForgotPasswordGetOTPResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordGetOTPResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      error: json['error'],
      details:
          json['details'] != null ? Details.fromJson(json['details']) : null,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'error': error,
      'details': details?.toJson(),
    };
  }
}

class Data {
  final int? statusCode;
  final String? message;
  final bool? success;

  Data({this.statusCode, this.message, this.success});

  // Factory constructor to create an instance from JSON
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      statusCode: json['statusCode'],
      message: json['message'],
      success: json['success'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'success': success,
    };
  }
}

class Details {
  final String? emailAddress;

  Details({this.emailAddress});

  // Factory constructor to create an instance from JSON
  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      emailAddress: json['emailAddress'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'emailAddress': emailAddress,
    };
  }
}
