class VerifyOTPRequest {
  final String otp;

  VerifyOTPRequest({required this.otp});

  // Factory constructor to create an instance from JSON
  factory VerifyOTPRequest.fromJson(Map<String, dynamic> json) {
    return VerifyOTPRequest(
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
