import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../config/api_config.dart';
import '../../../core/error/api_exception.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';
import 'models/api_response.dart';
import 'models/auth_payload.dart';
import 'models/login_result.dart';
import 'models/change_password_request.dart';

class AuthApiService {
  AuthApiService(this._client);

  final ApiClient _client;

  static final AuthApiService instance = AuthApiService(ApiClient.instance);

  /// Đăng nhập
  ///
  /// Hỗ trợ 2 kiểu response:
  /// 1) Dạng bọc ApiResponse:
  ///    { "succeeded": true, "message": "...", "data": { ...token... } }
  /// 2) Dạng trả thẳng token:
  ///    { "accessToken": "...", "refreshToken": "...", "expiresInSeconds": 1800 }
  Future<LoginResult> login(LoginRequest request) async {
    try {
      final response = await _client.dio.post(
        ApiConfig.loginPath,
        data: request.toJson(),
      );

      final body = response.data;

      AuthPayload? payload;
      bool requiresPasskey = false;
      String? passkeyUserId;

      if (body is Map<String, dynamic> &&
          body.containsKey('succeeded') &&
          body.containsKey('data')) {
        // Backend wraps tokens inside ApiResponse<T>
        final api = ApiResponse<AuthPayload>.fromJson(
          body,
          (json) => AuthPayload.fromJson(json as Map<String, dynamic>),
        );

        if (!api.succeeded || api.data == null) {
          throw ApiException(
            api.message ?? '????ng nh??-p th???t b???i',
            statusCode: response.statusCode,
          );
        }

        payload = api.data;
      } else if (body is Map<String, dynamic> &&
          body.containsKey('requiresPasskey')) {
        requiresPasskey = body['requiresPasskey'] == true;
        passkeyUserId = body['userId']?.toString();

        final tokens = body['tokens'];
        if (!requiresPasskey && tokens is Map<String, dynamic>) {
          payload = AuthPayload.fromJson(tokens);
        }
      } else if (body is Map<String, dynamic>) {
        // Backend returns tokens directly (like /api/Auth/register)
        payload = AuthPayload.fromJson(body);
      } else {
        throw ApiException(
          '????ng nh??-p th???t b???i',
          statusCode: response.statusCode,
        );
      }

      // Lưu token lại để dùng cho các request sau
      if (payload != null) {
        await _client.tokenStorage.saveTokens(
          accessToken: payload.accessToken,
          refreshToken: payload.refreshToken,
        );

        return LoginResult(payload: payload);
      }

      return LoginResult(
        payload: null,
        requiresPasskey: requiresPasskey,
        userId: passkeyUserId,
      );
    } on DioException catch (e) {
      _client.throwApiError(e);
    }
  }

  /// Đăng ký
  ///
  /// Hiện tại /api/Auth/register của anh đang trả **thẳng JSON token**:
  /// { "accessToken": "...", "refreshToken": "...", "expiresInSeconds": 1800 }
  ///
  /// Hàm này cũng hỗ trợ luôn trường hợp sau này anh đổi sang ApiResponse.
  Future<AuthPayload> register(RegisterRequest request) async {
    try {
      final response = await _client.dio.post(
        ApiConfig.registerPath,
        data: request.toJson(),
      );

      final body = response.data;

      AuthPayload payload;

      if (body is Map<String, dynamic> &&
          body.containsKey('succeeded') &&
          body.containsKey('data')) {
        // Trường hợp tương lai nếu anh đổi register trả kiểu ApiResponse<T>
        final api = ApiResponse<AuthPayload>.fromJson(
          body,
          (json) => AuthPayload.fromJson(json as Map<String, dynamic>),
        );

        if (!api.succeeded || api.data == null) {
          throw ApiException(
            api.message ?? 'Đăng ký thất bại',
            statusCode: response.statusCode,
          );
        }

        payload = api.data!;
      } else if (body is Map<String, dynamic>) {
        // Trường hợp hiện tại: backend trả thẳng token
        payload = AuthPayload.fromJson(body);
      } else {
        throw ApiException(
          'Đăng ký thất bại',
          statusCode: response.statusCode,
        );
      }

      // Lưu token sau khi đăng ký thành công
      await _client.tokenStorage.saveTokens(
        accessToken: payload.accessToken,
        refreshToken: payload.refreshToken,
      );

      return payload;
    } on DioException catch (e) {
      _client.throwApiError(e);
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _client.dio.post(
        ApiConfig.changePassword,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      _client.throwApiError(e);
    }
  }

  /// Đăng xuất
  ///
  /// Sau này nếu backend có endpoint revoke refresh token
  /// thì mình chỉ cần bổ sung call API ở đây.
  Future<void> logout() async {
    await _client.tokenStorage.clearTokens();
  }
}

