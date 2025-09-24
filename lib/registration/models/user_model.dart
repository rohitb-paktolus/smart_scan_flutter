// models/user_model.dart
class UserModel {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String emailAddress;
  final String password;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        firstName: json['firstName'],
        lastName: json['lastName'],
        phoneNumber: json['phoneNumber'],
        emailAddress: json['emailAddress'],
        password: json['password']);
  }
}
