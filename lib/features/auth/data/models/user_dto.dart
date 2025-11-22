class UserDto {
  final String id;
  final String phoneNumber;
  final String? fullName;
  final List<String> roles;

  UserDto({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.roles = const [],
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String?,
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
