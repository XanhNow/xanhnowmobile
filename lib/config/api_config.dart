class ApiConfig {
  /// Base URL của API .NET khi test trên điện thoại thật (máy API: 192.168.2.2).
  /// Nếu chạy emulator Android, đổi thành https://10.0.2.2:5000.
  static const String baseUrl = 'https://api.xanhnow.shop';

  static const String loginPath = '/api/auth/login';
  static const String registerPath = '/api/auth/register';
  static const String changePassword = '/api/auth/change-password';
  static const String passkeyAttestationOptions =
      '/api/Passkey/attestation/options';
  static const String passkeyAttestationVerify =
      '/api/Passkey/attestation/verify';
  static const String passkeyAssertionOptions =
      '/api/Passkey/assertion/options';
  static const String passkeyAssertionLogin = '/api/Passkey/assertion/login';
  static const String passkeyAssertionReset =
      '/api/Passkey/assertion/reset-password';
}


