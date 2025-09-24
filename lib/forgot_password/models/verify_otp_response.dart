class VerifyOTPResponse {
  final Data? data;
  final String? error;
  final Details? details;

  VerifyOTPResponse({this.data, this.error, this.details});

  // Factory constructor for creating an instance from JSON
  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      error: json['error'],
      details: json['details'] != null ? Details.fromJson(json['details']) : null,
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
  final bool? success;

  Data({this.statusCode, this.success});

  // Factory constructor for creating an instance from JSON
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      statusCode: json['statusCode'],
      success: json['success'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
    };
  }
}

class Details {
  final String? otp;

  Details({this.otp});

  // Factory constructor for creating an instance from JSON
  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      otp: json['otp'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
    };
  }
}
