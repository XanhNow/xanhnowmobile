import '../error/api_exception.dart';
import 'package:dio/dio.dart';

class ErrorUtils {
  static String toUserMessage(
    Object error, {
    String fallback = 'Da co loi xay ra, vui long thu lai.',
  }) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = (data['message'] ?? data['detail'] ?? data['title'])
            ?.toString()
            .trim();
        if (message != null && message.isNotEmpty) return message;

        // Trích ghép lỗi từ ModelState nếu có
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final msgs = errors.values
              .expand((v) => v is Iterable ? v : [v])
              .whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          if (msgs.isNotEmpty) return msgs.join('; ');
        }
      }

      // Lỗi kết nối/timed out
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Khong the ket noi toi may chu. Vui long kiem tra mang va thu lai.';
      }
    }

    if (error is ApiException) {
      final msg = error.message.trim();
      if (msg.isNotEmpty) return msg;
    }

    final raw = error.toString().trim();
    if (raw.isNotEmpty) {
      return raw
          .replaceFirst(RegExp(r'^Exception:\s*'), '')
          .replaceFirst(RegExp(r'^ApiException\([^)]*\):\s*'), '')
          .trim();
    }

    return fallback;
  }
}
