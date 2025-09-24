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
