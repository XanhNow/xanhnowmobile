import 'package:flutter/material.dart';

import '../core/utils/error_utils.dart';
import '../features/passkey/passkey_manager.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final phoneController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool _newObscure = true;
  bool _confirmObscure = true;
  bool _loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String? _validate() {
    final phone = phoneController.text.trim();
    final newPass = newController.text;
    final confirm = confirmController.text;

    if (phone.isEmpty) {
      return 'Vui lòng nhập số điện thoại đã đăng ký.';
    }
    if (newPass.isEmpty || confirm.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới.';
    }
    if (newPass.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(newPass) ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(newPass)) {
      return 'Mật khẩu mới phải có ít nhất 8 ký tự, gồm chữ IN HOA và ký tự đặc biệt.';
    }
    if (newPass != confirm) {
      return 'Mật khẩu nhập lại không khớp.';
    }
    return null;
  }

  Future<void> _resetWithPasskey() async {
    final err = _validate();
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await PasskeyManager.instance.resetPasswordWithPasskey(
        phoneNumber: phoneController.text,
        newPassword: newController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lại mật khẩu thành công. Vui lòng đăng nhập.'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final message = ErrorUtils.toUserMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xác thực bằng Passkey thay cho OTP. Bạn cần dùng đúng thiết bị đã bật Passkey trước đó.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: newController,
              label: 'Mật khẩu mới',
              obscure: _newObscure,
              onToggle: () => setState(() => _newObscure = !_newObscure),
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: confirmController,
              label: 'Nhập lại mật khẩu mới',
              obscure: _confirmObscure,
              onToggle: () =>
                  setState(() => _confirmObscure = !_confirmObscure),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _resetWithPasskey,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: const Text('Đặt lại bằng Passkey'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
