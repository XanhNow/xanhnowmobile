import 'dart:convert';

class JwtUtils {
  const JwtUtils._();

  /// Tries to extract the `sub` (userId) claim from a JWT access token.
  static String? tryGetUserId(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      final payloadSegment = _normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(payloadSegment));
      final map = jsonDecode(payloadJson);
      if (map is Map<String, dynamic>) {
        return (map['sub'] ??
                map['nameid'] ??
                map['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'])
            ?.toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static String _normalize(String input) {
    final sb = StringBuffer(input.replaceAll('-', '+').replaceAll('_', '/'));
    while (sb.length % 4 != 0) {
      sb.write('=');
    }
    return sb.toString();
  }
}
