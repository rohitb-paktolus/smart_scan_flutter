class ForgotPasswordGetOTPRequest {
  final String emailAddress;

  ForgotPasswordGetOTPRequest({required this.emailAddress});

  // Factory constructor for creating an instance from JSON
  factory ForgotPasswordGetOTPRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordGetOTPRequest(
      emailAddress: json['emailAddress'],
    );
  }

  // Method for converting an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'emailAddress': emailAddress,
    };
  }
}
