class SetNewPasswordRequest {
  final String? emailAddress;
  final String? newPassword;
  final String? confirmPassword;

  SetNewPasswordRequest({
    required this.emailAddress,
    required this.newPassword,
    required this.confirmPassword,
  });

  // Factory constructor to create an instance from JSON
  factory SetNewPasswordRequest.fromJson(Map<String, dynamic> json) {
    return SetNewPasswordRequest(
      emailAddress: json['emailAddress'],
      newPassword: json['newPassword'],
      confirmPassword: json['confirmPassword'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'emailAddress': emailAddress,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
