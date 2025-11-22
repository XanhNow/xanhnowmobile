import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/utils/error_utils.dart';
import '../../core/utils/jwt_utils.dart';
import '../auth/data/models/auth_payload.dart';
import 'data/passkey_prompt_storage.dart';
import 'passkey_manager.dart';

class PasskeyPrompt {
  PasskeyPrompt._();

  static final PasskeyPrompt instance = PasskeyPrompt._();

  final PasskeyPromptStorage _storage = PasskeyPromptStorage();

  Future<void> maybeShow({
    required BuildContext context,
    required AuthPayload payload,
  }) async {
    final userIdFromUser = payload.user?.id;
    final userIdFromToken = JwtUtils.tryGetUserId(payload.accessToken);
    final userId = userIdFromUser ?? userIdFromToken;

    if (userId == null) return;
    if (await _storage.hasBeenPrompted(userId)) return;
    if (!context.mounted) return;

    final enable = await showModalBottomSheet<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      backgroundColor: const Color(0xFF05251B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PasskeyBottomSheet(),
    );

    await _storage.markPrompted(userId);

    if (enable == true && context.mounted) {
      await _enablePasskey(context);
    }
  }

  Future<void> _enablePasskey(BuildContext context) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var dialogClosed = false;
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    ).whenComplete(() => dialogClosed = true);

    try {
      await PasskeyManager.instance.registerPasskey();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passkey da duoc bat thanh cong.'),
        ),
      );
    } catch (e) {
      if (kDebugMode && e is DioException) {
        debugPrint('Passkey enable failed: ${e.response?.data}');
      }
      if (context.mounted) {
        final message = ErrorUtils.toUserMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (!dialogClosed) {
        rootNavigator.pop();
      }
      await dialogFuture;
    }
  }
}

class _PasskeyBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Row(
            children: const [
              Icon(Icons.fingerprint, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bat Passkey thay OTP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Xac thuc bang Face ID hoac van tay de dang nhap nhanh hon, '
            'khong can OTP.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB0F0D2),
                    side: const BorderSide(color: Color(0xFFB0F0D2)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('De sau'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2AAE74),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Bat Passkey'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
