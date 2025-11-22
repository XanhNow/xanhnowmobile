import '../../../core/network/api_client.dart';
import '../../../config/api_config.dart';
import '../../auth/data/models/auth_payload.dart';
import 'models/passkey_models.dart';

class PasskeyApiService {
  PasskeyApiService(this._client);

  final ApiClient _client;

  static final PasskeyApiService instance = PasskeyApiService(ApiClient.instance);

  Future<PasskeyAttestationOptions> beginAttestation() async {
    final response =
        await _client.dio.post(ApiConfig.passkeyAttestationOptions);
    // ignore: avoid_print
    print('[PasskeyApi] attestation options status ${response.statusCode}');
    return PasskeyAttestationOptions.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> completeAttestation({
    required String challenge,
    required Map<String, dynamic> attestation,
  }) async {
    await _client.dio.post(
      ApiConfig.passkeyAttestationVerify,
      queryParameters: {'challenge': challenge},
      data: attestation,
    );
    // ignore: avoid_print
    print('[PasskeyApi] attestation verify OK');
  }

  Future<PasskeyAssertionOptions> beginAssertion({
    required String phoneNumber,
  }) async {
    final response = await _client.dio.post(
      ApiConfig.passkeyAssertionOptions,
      data: {'phoneNumber': phoneNumber},
    );
    // ignore: avoid_print
    print('[PasskeyApi] assertion options status ${response.statusCode}');

    return PasskeyAssertionOptions.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AuthPayload> completeAssertion({
    required String phoneNumber,
    required String challenge,
    required Map<String, dynamic> assertion,
  }) async {
    final response = await _client.dio.post(
      ApiConfig.passkeyAssertionLogin,
      data: {
        'phoneNumber': phoneNumber,
        'challenge': challenge,
        'assertion': assertion,
      },
    );
    // ignore: avoid_print
    print('[PasskeyApi] assertion login status ${response.statusCode}');

    final body = Map<String, dynamic>.from(response.data as Map);
    final payload = AuthPayload.fromJson(body);

    await _client.tokenStorage.saveTokens(
      accessToken: payload.accessToken,
      refreshToken: payload.refreshToken,
    );

    return payload;
  }

  Future<void> resetPasswordWithPasskey({
    required String phoneNumber,
    required String challenge,
    required Map<String, dynamic> assertion,
    required String newPassword,
  }) async {
    await _client.dio.post(
      ApiConfig.passkeyAssertionReset,
      data: {
        'phoneNumber': phoneNumber,
        'challenge': challenge,
        'newPassword': newPassword,
        'assertion': assertion,
      },
    );
  }
}
