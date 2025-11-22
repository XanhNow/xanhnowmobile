import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import '../error/api_exception.dart';
import '../../config/api_config.dart';

class ApiClient {
  ApiClient._internal() {
    final options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);
    _tokenStorage = TokenStorage();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // TODO: sau nay xu ly refresh token o day neu can
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  late final TokenStorage _tokenStorage;

  static final ApiClient instance = ApiClient._internal();

  Dio get dio => _dio;

  TokenStorage get tokenStorage => _tokenStorage;

  // Helper cho loi chung
  Never throwApiError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String message = 'Da co loi ket noi toi server.';

    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final detailedMessages = errors.values
            .expand((value) {
              if (value is Iterable) {
                return value.map((e) => e?.toString()).whereType<String>();
              }
              return [value?.toString()].whereType<String>();
            })
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (detailedMessages.isNotEmpty) {
          message = detailedMessages.join('\n');
        }
      }

      if (message.isEmpty && data['message'] is String) {
        message = data['message'] as String;
      } else if (message.isEmpty && data['detail'] is String) {
        message = data['detail'] as String;
      } else if (message.isEmpty && data['title'] is String) {
        message = data['title'] as String;
      }
    }

    if (message.isEmpty && e.response?.statusCode != null) {
      message = 'Loi server ${e.response?.statusCode}';
    }

    // Neu van rong, thu lay tu e.error hoac e.message
    if (message.isEmpty && e.error != null) {
      message = e.error.toString();
    }

    message = message.isNotEmpty
        ? message
        : (e.message != null && e.message!.isNotEmpty
            ? 'Da co loi ket noi toi server: ${e.message}'
            : 'Da co loi ket noi toi server.');

    // In log ra console (ke ca release) de de bat loi
    // ignore: avoid_print
    print('[ApiError] status=$status, message=$message, raw=${e.message}');

    message = message
        .split('\n')
        .map(_localizeError)
        .where((line) => line.trim().isNotEmpty)
        .join('\n');

    throw ApiException(message, statusCode: status);
  }

  String _localizeError(String message) {
    final normalized = message.trim();
    switch (normalized) {
      case 'One or more validation errors occurred.':
        return 'Du lieu khong hop le. Vui long kiem tra lai.';
      case 'The PhoneNumber field is not a valid phone number.':
        return 'So dien thoai khong hop le.';
      case 'Invalid credentials.':
        return 'Sai so dien thoai hoac mat khau.';
      case 'Phone number already registered.':
        return 'So dien thoai da duoc dang ky.';
      case 'Password must be at least 8 characters and include uppercase, lowercase and special characters.':
        return 'Mat khau phai co it nhat 8 ky tu, bao gom chu hoa, chu thuong va ky tu dac biet.';
      default:
        return normalized;
    }
  }
}
