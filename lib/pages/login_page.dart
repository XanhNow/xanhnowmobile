import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/utils/error_utils.dart';
import '../features/auth/data/auth_api_service.dart';
import '../features/auth/data/models/auth_payload.dart';
import '../features/auth/data/models/login_request.dart';
import '../features/auth/data/models/login_result.dart';
import '../features/passkey/passkey_manager.dart';
import '../features/passkey/passkey_prompt.dart';

enum _LoginFlow { credentials, passkey }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  _LoginFlow? _flow;
  bool _obscurePassword = true;
  bool _passkeyRequired = false;
  bool _hasPhone = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_handlePhoneChange);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_handlePhoneChange);
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ SĐT và Mật khẩu.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _flow = _LoginFlow.credentials;
      _passkeyRequired = false;
    });

    try {
      final LoginResult result = await AuthApiService.instance.login(
        LoginRequest(phoneNumber: phone, password: password),
      );

      if (!mounted) return;

      if (result.requiresPasskey && !result.hasTokens) {
        setState(() => _passkeyRequired = true);
        _showMessage(
          'Tài khoản này đã bật Passkey. Vui lòng chọn "Đăng nhập bằng Passkey".',
        );
        return;
      }

      if (result.payload != null) {
        await PasskeyPrompt.instance.maybeShow(
          context: context,
          payload: result.payload!,
        );
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/root', (_) => false);
      } else {
        _showMessage('Đăng nhập thành công.');
        Navigator.pushNamedAndRemoveUntil(context, '/root', (_) => false);
      }
    } catch (e) {
      if (kDebugMode && e is DioException) {
        debugPrint('Credential login failed: ${e.response?.data}');
      }
      final message = ErrorUtils.toUserMessage(e);
      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _flow = null);
      }
    }
  }

  Future<void> _loginWithPasskey() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showMessage('Vui lòng nhập số điện thoại trước.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _flow = _LoginFlow.passkey;
      _passkeyRequired = false;
    });

    try {
      await PasskeyManager.instance.loginWithPasskey(phoneNumber: phone);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/root', (_) => false);
    } catch (e) {
      if (kDebugMode && e is DioException) {
        debugPrint('Passkey login failed: ${e.response?.data}');
      }
      final message = ErrorUtils.toUserMessage(e);
      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _flow = null);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openRegister() async {
    final result = await Navigator.pushNamed(context, '/register');
    if (!mounted || result is! AuthPayload) return;
    await PasskeyPrompt.instance.maybeShow(
      context: context,
      payload: result,
    );
  }

  void _openForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  void _handlePhoneChange() {
    final hasValue = _phoneController.text.trim().isNotEmpty;
    if (hasValue != _hasPhone) {
      setState(() => _hasPhone = hasValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F5E3A),
              Color(0xFF0A3B2E),
              Color(0xFF041E24),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight - 56),
                    ),
                  child: Column(
                    children: [
                      const _NeonOrbit(),
                      const SizedBox(height: 36),
                      const _WelcomeTitle(),
                      const SizedBox(height: 28),
                      _NeonField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        hint: 'Số điện thoại',
                        icon: Icons.phone_iphone,
                      ),
                      const SizedBox(height: 16),
                      _NeonField(
                        controller: _passwordController,
                        hint: 'Mật khẩu',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          color: Colors.white70,
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                              _flow == null ? _openForgotPassword : null,
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(color: Color(0xFF86F7FF)),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _passkeyRequired ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: _passkeyRequired
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: const [
                                    Icon(Icons.info_outline,
                                        color: Color(0xFF86F7FF)),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Tài khoản đã bật Passkey. Vui lòng xác thực bằng Passkey để tiếp tục.',
                                        style: TextStyle(
                                          color: Color(0xFF86F7FF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      _NeonButton(
                        label: 'ĐĂNG NHẬP',
                        onPressed:
                            _flow == null ? _submit : null,
                        busy: _flow == _LoginFlow.credentials,
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _hasPhone && _passkeyRequired
                            ? _PasskeyButton(
                                key: const ValueKey('passkey-btn'),
                                onPressed:
                                    _flow == null ? _loginWithPasskey : null,
                                busy: _flow == _LoginFlow.passkey,
                              )
                            : const SizedBox(
                                key: ValueKey('passkey-hidden'),
                              ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _flow == null ? _openRegister : null,
                        child: const Text(
                          'Chưa có tài khoản?\nĐăng ký ngay',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF7EC8FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      const _TermsText(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NeonOrbit extends StatelessWidget {
  const _NeonOrbit();

  static const _iconColor = Color(0xFF4DF8B1);
  static const _radius = 93.5; // 15% smaller than original radius
  static const _entries = <({IconData icon, double angle})>[
    (icon: Icons.person_outline, angle: -math.pi / 2), // top
    (icon: Icons.flight_takeoff, angle: -math.pi / 2 + math.pi / 3),
    (icon: Icons.local_shipping_outlined, angle: -math.pi / 2 + 2 * math.pi / 3),
    (icon: Icons.airport_shuttle, angle: -math.pi / 2 + math.pi),
    (icon: Icons.directions_car, angle: -math.pi / 2 + 4 * math.pi / 3),
    (icon: Icons.motorcycle, angle: -math.pi / 2 + 5 * math.pi / 3),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x4036D39E), Colors.transparent],
                  radius: 0.9,
                ),
              ),
            ),
          ),
          for (final entry in _entries)
            Transform.translate(
              offset: Offset(
                _radius * math.cos(entry.angle),
                _radius * math.sin(entry.angle),
              ),
              child: Icon(
                entry.icon,
                color: _iconColor,
                size: 34,
              ),
            ),
          Image.asset(
            'assets/logo/ooxxi.png',
            fit: BoxFit.contain,
            height: 72, // 25% smaller than previous size
          ),
        ],
      ),
    );
  }
}

class _WelcomeTitle extends StatelessWidget {
  const _WelcomeTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
          Text(
            'Chào mừng tới OOXXI',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.white54, blurRadius: 16),
              Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
        ),
        SizedBox(height: 8),
          Text(
            'Kết nối hành trình của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFBDF5FF),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _NeonField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String hint;
  final IconData icon;
  final Widget? suffix;

  const _NeonField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF041B1F).withOpacity(0.8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF1B4D3E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF4DF8B1)),
          ),
        ),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  const _NeonButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2FB96A), Color(0xFF168347)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8036D39E),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: SizedBox(
              height: 45,
              child: Center(
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasskeyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool busy;

  const _PasskeyButton({
    super.key,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF4DF8B1)),
          minimumSize: const Size.fromHeight(45),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.fingerprint),
        label: Text(
          busy ? 'Đang xác thực...' : 'Đăng nhập bằng Passkey',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Text(
        'Bằng cách tiếp tục, bạn đồng ý với\nĐiều khoản và Chính sách của OOXXI.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
    );
  }
}
