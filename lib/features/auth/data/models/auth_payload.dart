import 'user_dto.dart';

class AuthPayload {
  final String accessToken;
  final String refreshToken;
  final int? expiresIn;
  final UserDto? user;

  AuthPayload({
    required this.accessToken,
    required this.refreshToken,
    this.user,
    this.expiresIn,
  });

  factory AuthPayload.fromJson(Map<String, dynamic> json) {
    return AuthPayload(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      // Backend hiện tại trả "expiresInSeconds"
      // Nếu sau này anh đổi lại "expiresIn" thì vẫn map được
      expiresIn: (json['expiresInSeconds'] ?? json['expiresIn']) is int
          ? (json['expiresInSeconds'] ?? json['expiresIn']) as int
          : int.tryParse(
              (json['expiresInSeconds'] ?? json['expiresIn'])?.toString() ??
                  '0',
            ),
      // Register không có "user" -> để null.
      // Login nếu backend trả thêm "user" thì map bình thường.
      user: json['user'] != null
          ? UserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
