import 'package:flutter/material.dart';

import '../core/utils/error_utils.dart';
import '../features/auth/data/auth_api_service.dart';
import '../features/auth/data/models/change_password_request.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool _currentObscure = true;
  bool _newObscure = true;
  bool _confirmObscure = true;
  bool _loading = false;

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String? _validate() {
    final current = currentController.text;
    final newPass = newController.text;
    final confirm = confirmController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      return 'Vui lòng nhập đầy đủ mật khẩu hiện tại và mật khẩu mới.';
    }
    if (newPass.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(newPass) ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(newPass)) {
      return 'Mật khẩu mới phải có ít nhất 8 ký tự, gồm chữ IN HOA và ký tự đặc biệt.';
    }
    if (newPass != confirm) {
      return 'Mật khẩu nhập lại không khớp.';
    }
    if (newPass == current) {
      return 'Mật khẩu mới phải khác mật khẩu hiện tại.';
    }
    return null;
  }

  Future<void> _submit() async {
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
      await AuthApiService.instance.changePassword(
        ChangePasswordRequest(
          currentPassword: currentController.text,
          newPassword: newController.text,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công.')),
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
        title: const Text('Đổi mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _PasswordField(
              controller: currentController,
              label: 'Mật khẩu hiện tại',
              obscure: _currentObscure,
              onToggle: () => setState(() => _currentObscure = !_currentObscure),
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
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Lưu thay đổi'),
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
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
