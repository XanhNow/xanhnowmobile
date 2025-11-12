import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final phone = phoneController.text.trim();
    final pass = passwordController.text;

    if (phone.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ SĐT và mật khẩu')),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // TODO: gọi API thật
    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/root');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LoginGradientBg(),

          // Nội dung chính (hero + welcome + form)
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
                      const _LoginHeroCluster(),
                      const SizedBox(height: 12),
                      const _WelcomeTitle(),
                      const SizedBox(height: 18),

                      _DarkField(
                        controller: phoneController,
                        label: 'Số điện thoại',
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone_iphone,
                      ),
                      const SizedBox(height: 14),
                      _DarkField(
                        controller: passwordController,
                        label: 'Mật khẩu',
                        obscureText: _obscure,
                        icon: Icons.lock_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 22),

                      _GlowButton(
                        onPressed: _loading ? null : _doLogin,
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
                                'ĐĂNG NHẬP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),

                      const SizedBox(height: 14),
                      const Text(
                        'Chưa có tài khoản?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Đăng ký ngay'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7ED9FF),
                          side: BorderSide(
                            color: const Color(0xFF7ED9FF)
                                .withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Điều khoản sát đáy
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Bằng cách tiếp tục, bạn đồng ý với\nĐiều khoản và Chính sách của OOXXI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===== NỀN GRADIENT =====
class _LoginGradientBg extends StatelessWidget {
  const _LoginGradientBg();

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

/// Helper item cho vòng icon
class _RingItem {
  final Widget child;
  final double deg;
  const _RingItem(this.child, this.deg);
}

/// ===== CỤM HERO: 6 icon đối xứng, người trên cùng, bus dưới cùng =====
class _LoginHeroCluster extends StatelessWidget {
  const _LoginHeroCluster();

  static const Color neon = Color(0xFF5EF39A);

  Alignment _polar(double r, double deg) {
    final rad = deg * math.pi / 180.0;
    return Alignment(math.cos(rad) * r, math.sin(rad) * r);
  }

  @override
  Widget build(BuildContext context) {
    const double orbit = 0.72; // bán kính vòng icon

    // Góc đối xứng: -90 (đỉnh), -30, 30, 90 (đáy), 150, -150
    const sizeTop = 34.0;
    const sizeOthers = 36.0;

    final items = <_RingItem>[
      _RingItem(
          const _NeonIcon(icon: Icons.person, size: sizeTop), -90), // đỉnh
      _RingItem(
          const _NeonIcon(icon: Icons.flight_rounded, size: sizeOthers),
          -30), // trên-phải
      _RingItem(
          const _NeonIcon(icon: Icons.directions_car_filled_rounded,
              size: sizeOthers),
          30), // dưới-phải
      _RingItem(
          const _NeonIcon(
              icon: Icons.directions_bus_filled_rounded, size: sizeOthers),
          90), // đáy (bus)
      _RingItem(
          const _NeonIcon(
              icon: Icons.local_shipping_rounded, size: sizeOthers),
          150), // dưới-trái (van)
      _RingItem(
          const _NeonIcon(icon: Icons.motorcycle_rounded, size: sizeOthers),
          -150), // trên-trái (moto)
    ];

    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final it in items)
            Align(alignment: _polar(orbit, it.deg), child: it.child),

          // Logo trung tâm: ưu tiên asset, fallback sang chữ gradient
          SizedBox(
            height: 86,
            child: Image.asset(
              'assets/logo/ooxxi.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xFF4ED3A1), Color(0xFF5EF39A)],
                ).createShader(r),
                child: const Text(
                  'OOXXI',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===== TIÊU ĐỀ CHÀO MỪNG (glow) =====
class _WelcomeTitle extends StatelessWidget {
  const _WelcomeTitle();

  TextStyle _glow(double size, {FontWeight weight = FontWeight.w700}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: Colors.white,
      shadows: const [
        Shadow(color: Colors.white70, blurRadius: 14),
        Shadow(color: Colors.white24, blurRadius: 28),
        Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Chào mừng tới OOXXI', style: _glow(22)),
        const SizedBox(height: 6),
        Text('Kết nối hành trình của bạn.',
            style: _glow(16, weight: FontWeight.w600)),
      ],
    );
  }
}

/// Icon neon (màu xanh + shadow nhẹ)
class _NeonIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const _NeonIcon({required this.icon, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x8044E59F),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Icon(icon, size: size, color: _LoginHeroCluster.neon),
    );
  }
}

/// Ô nhập nền tối bo tròn
class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? icon;
  final Widget? suffix;

  const _DarkField({
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

/// Nút phát sáng
class _GlowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  const _GlowButton({required this.onPressed, required this.child});

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
