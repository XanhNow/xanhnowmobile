import 'auth_payload.dart';

class LoginResult {
  final AuthPayload? payload;
  final bool requiresPasskey;
  final String? userId;

  const LoginResult({
    this.payload,
    this.requiresPasskey = false,
    this.userId,
  });

  bool get hasTokens => payload != null;
}
