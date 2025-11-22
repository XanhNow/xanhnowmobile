import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasskeyPromptStorage {
  PasskeyPromptStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _prefix = 'passkey_prompted_';
  final FlutterSecureStorage _storage;

  Future<bool> hasBeenPrompted(String userId) async {
    final value = await _storage.read(key: '$_prefix$userId');
    return value == '1';
  }

  Future<void> markPrompted(String userId) {
    return _storage.write(key: '$_prefix$userId', value: '1');
  }
}
