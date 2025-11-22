import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../config/api_config.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';
import 'models/register_request.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException($message)';
}

class AuthApiService {
  AuthApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  static final AuthApiService instance = AuthApiService._internal();

  late final Dio _dio;

  void _log(Object msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AUTH API] $msg');
    }
  }

  Never _handleDioError(DioException e) {
    _log('DioError type=${e.type} message=${e.message}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw ApiException(
          'Không kết nối được tới server (timeout). '
          'Kiểm tra lại WiFi/IP API hoặc server có đang chạy không.',
        );
      case DioExceptionType.connectionError:
        throw ApiException(
          'Không kết nối được tới server. Hãy kiểm tra mạng hoặc địa chỉ API.',
        );
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final data = e.response?.data;
        _log('Bad response: status=$status data=$data');
        throw ApiException('Server trả về lỗi ($status).');
      default:
        throw ApiException(e.message ?? 'Lỗi không xác định từ API.');
    }
  }

  // ============ REGISTER ============
  Future<void> register(RegisterRequest request) async {
    try {
      _log('POST ${ApiConfig.registerPath} body=${jsonEncode(request.toJson())}');
      final resp = await _dio.post(
        ApiConfig.registerPath,
        data: request.toJson(),
      );

      _log('Register status=${resp.statusCode} data=${resp.data}');
      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw ApiException('Đăng ký thất bại (mã ${resp.statusCode}).');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============ LOGIN ============
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      _log('POST ${ApiConfig.loginPath} body=${jsonEncode(request.toJson())}');
      final resp = await _dio.post(
        ApiConfig.loginPath,
        data: request.toJson(),
      );

      _log('Login status=${resp.statusCode} data=${resp.data}');
      if (resp.statusCode != 200) {
        throw ApiException('Đăng nhập thất bại (mã ${resp.statusCode}).');
      }

      return LoginResponse.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
