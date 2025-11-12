import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final phoneController = TextEditingController();
  final pwController = TextEditingController();
  final pw2Controller = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  bool _toastShowing = false;

  @override
  void dispose() {
    phoneController.dispose();
    pwController.dispose();
    pw2Controller.dispose();
    super.dispose();
  }

  String? _validate() {
    final phone = phoneController.text.trim();
    final pw = pwController.text;
    final pw2 = pw2Controller.text;

    if (phone.isEmpty) return 'Vui lòng nhập Số điện thoại';
    if (pw.isEmpty || pw2.isEmpty) {
      return 'Vui lòng nhập Mật khẩu và Nhập lại mật khẩu';
    }

    final pwOkLen = pw.length >= 8;
    final pwHasUpper = RegExp(r'[A-Z]').hasMatch(pw);
    // Ít nhất 1 ký tự đặc biệt: ký tự KHÔNG phải chữ hoặc số
    final pwHasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(pw);

    if (!pwOkLen || !pwHasUpper || !pwHasSpecial) {
      return 'Mật khẩu ≥ 8, có chữ IN HOA và ký tự đặc biệt';
    }
    if (pw != pw2) return 'Mật khẩu nhập lại không khớp';
    return null;
  }

  Future<void> _showSuccessToast(String message) async {
    if (_toastShowing) return;
    _toastShowing = true;

    final overlay = Overlay.of(context);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final curve =
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

    late OverlayEntry entry;
    entry = OverlayEntry(builder: (ctx) {
      final topPad = 16.0 + MediaQuery.of(ctx).viewPadding.top; // tránh tai thỏ
      return Positioned(
        left: 24,
        right: 24,
        top: topPad,
        child: FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.15), // trượt từ trên xuống
              end: Offset.zero,
            ).animate(curve),
            child: _BlueToast(message: message),
          ),
        ),
      );
    });

    overlay.insert(entry);
    await controller.forward(); // hiện lên
    await Future.delayed(const Duration(seconds: 3));
    await controller.reverse(); // mờ dần
    entry.remove();
    controller.dispose();
    _toastShowing = false;
  }

  Future<void> _doRegister() async {
    final err = _validate();
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(
        const Duration(milliseconds: 800)); // TODO: gọi API đăng ký thật
    setState(() => _loading = false);

    if (!mounted) return;
    await _showSuccessToast('Bạn đã đăng ký thành công.');
    if (!mounted) return;
    Navigator.of(context).pop(); // quay lại Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const _RegisterGradientBg(),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _RegisterTitle(), // "Xin mời đăng ký"
                    const SizedBox(height: 20),

                    _RegDarkField(
                      controller: phoneController,
                      label: 'Số điện thoại (Bắt buộc)',
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_iphone,
                    ),
                    const SizedBox(height: 14),
                    _RegDarkField(
                      controller: pwController,
                      label: 'Mật khẩu',
                      obscureText: _obscure1,
                      icon: Icons.lock_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure1
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () =>
                            setState(() => _obscure1 = !_obscure1),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _RegDarkField(
                      controller: pw2Controller,
                      label: 'Nhập lại mật khẩu',
                      obscureText: _obscure2,
                      icon: Icons.lock_reset_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure2
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () =>
                            setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                    const SizedBox(height: 22),

                    _RegGlowButton(
                      onPressed: _loading ? null : _doRegister,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'ĐĂNG KÝ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Quay lại đăng nhập',
                        style: TextStyle(color: Color(0xFF7ED9FF)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// ===== Toast xanh dương ở phía trên (opacity + shadow + bo tròn) =====
class _BlueToast extends StatelessWidget {
  final String message;
  const _BlueToast({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xCC1E88E5), // xanh dương + opacity
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== NỀN GRADIENT (giống Login) =====
class _RegisterGradientBg extends StatelessWidget {
  const _RegisterGradientBg();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E4D3A), Color(0xFF0C2F28)],
        ),
      ),
    );
  }
}

/// ===== TIÊU ĐỀ =====
class _RegisterTitle extends StatelessWidget {
  const _RegisterTitle();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'Xin mời đăng ký',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.white70, blurRadius: 14),
              Shadow(color: Colors.white24, blurRadius: 28),
              Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1)),
            ],
          ),
        ),
      ],
    );
  }
}

/// ===== Ô nhập nền tối bo tròn =====
class _RegDarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? icon;
  final Widget? suffix;
  const _RegDarkField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.icon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
        suffixIcon: suffix,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF0C2621),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF154A3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFF29CC97), width: 1.2),
        ),
      ),
    );
  }
}

/// ===== Nút phát sáng =====
class _RegGlowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  const _RegGlowButton({required this.onPressed, required this.child});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x8036D39E),
            blurRadius: 18,
            spreadRadius: 1,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2AAE74),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
