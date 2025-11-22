class RegisterRequest {
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String fullName;

  RegisterRequest({
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
        'fullName': fullName,
      };
}
