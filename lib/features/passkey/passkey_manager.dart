import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

import '../../core/error/api_exception.dart';
import '../../core/network/api_client.dart';
import '../auth/data/models/auth_payload.dart';
import 'data/models/passkey_models.dart';
import 'data/passkey_api_service.dart';

class PasskeyManager {
  PasskeyManager._();

  static final PasskeyManager instance = PasskeyManager._();

  final PasskeyAuthenticator _authenticator = PasskeyAuthenticator();
  final PasskeyApiService _api = PasskeyApiService.instance;

  Future<void> registerPasskey() async {
    // Bắt buộc phải có access token mới được bật Passkey
    final token = await ApiClient.instance.tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        'Vui long dang nhap lai truoc khi bat Passkey.',
        statusCode: 401,
      );
    }

    // Log checkpoint
    // ignore: avoid_print
    print('[Passkey] begin attestation...');

    final options = await _api.beginAttestation();

    // ignore: avoid_print
    print('[Passkey] attestation options: rpId=${options.rp.id}, user=${options.user.name}');

    final request = RegisterRequestType(
      challenge: options.challenge,
      relyingParty: RelyingPartyType(
        id: options.rp.id,
        name: options.rp.name,
      ),
      user: UserType(
        id: options.user.id,
        name: options.user.name,
        displayName: options.user.displayName,
      ),
      excludeCredentials: options.excludeCredentials
          .map(
            (cred) => CredentialType(
              type: cred.type,
              id: cred.id,
              transports: cred.transports,
            ),
          )
          .toList(),
      pubKeyCredParams: options.pubKeyCredParams
          .map(
            (param) => PubKeyCredParamType(type: param.type, alg: param.alg),
          )
          .toList(),
      authSelectionType: _buildAuthenticatorSelection(
        options.authenticatorSelection,
      ),
      timeout: options.timeout,
      attestation: options.attestation,
    );

    final response = await _authenticator.register(request);

    // ignore: avoid_print
    print('[Passkey] authenticator.register done, id=${response.id}');

    await _api.completeAttestation(
      challenge: options.challenge,
      attestation: {
        'id': response.id,
        'rawId': response.rawId,
        'type': 'public-key',
        'response': {
          'clientDataJSON': response.clientDataJSON,
          'attestationObject': response.attestationObject,
          'transports': response.transports.whereType<String>().toList(),
        },
      },
    );

    // ignore: avoid_print
    print('[Passkey] complete attestation ok');
  }

  Future<AuthPayload> loginWithPasskey({required String phoneNumber}) async {
    final normalizedPhone = _normalizePhone(phoneNumber);

    final options =
        await _api.beginAssertion(phoneNumber: normalizedPhone);

    final assertionPayload = await _authenticate(options);

    return _api.completeAssertion(
      phoneNumber: normalizedPhone,
      challenge: options.challenge,
      assertion: assertionPayload,
    );
  }

  Future<void> resetPasswordWithPasskey({
    required String phoneNumber,
    required String newPassword,
  }) async {
    final normalizedPhone = _normalizePhone(phoneNumber);

    final options =
        await _api.beginAssertion(phoneNumber: normalizedPhone);

    final assertionPayload = await _authenticate(options);

    await _api.resetPasswordWithPasskey(
      phoneNumber: normalizedPhone,
      challenge: options.challenge,
      assertion: assertionPayload,
      newPassword: newPassword,
    );
  }

  Future<Map<String, dynamic>> _authenticate(
    PasskeyAssertionOptions options,
  ) async {
    // Đảm bảo vẫn còn token hợp lệ trước khi xác thực
    final token = await ApiClient.instance.tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        'Vui long dang nhap lai truoc khi dung Passkey.',
        statusCode: 401,
      );
    }

    final request = AuthenticateRequestType(
      relyingPartyId: options.rpId,
      challenge: options.challenge,
      mediation: MediationType.Required,
      preferImmediatelyAvailableCredentials: true,
      timeout: options.timeout,
      userVerification: options.userVerification,
      allowCredentials: options.allowCredentials.isEmpty
          ? null
          : options.allowCredentials
              .map(
                (cred) => CredentialType(
                  type: cred.type,
                  id: cred.id,
                  transports: cred.transports,
                ),
              )
              .toList(),
    );

    final assertion = await _authenticator.authenticate(request);

    return {
      'id': assertion.id,
      'rawId': assertion.rawId,
      'type': 'public-key',
      'response': {
        'clientDataJSON': assertion.clientDataJSON,
        'authenticatorData': assertion.authenticatorData,
        'signature': assertion.signature,
        'userHandle': assertion.userHandle,
      },
    };
  }

  String _normalizePhone(String phoneNumber) {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) {
      throw ApiException('Vui long nhap so dien thoai.');
    }
    return trimmed;
  }
}

AuthenticatorSelectionType? _buildAuthenticatorSelection(
  Map<String, dynamic>? json,
) {
  if (json == null) return null;
  try {
    return AuthenticatorSelectionType.fromJson(json);
  } catch (_) {
    return null;
  }
}
