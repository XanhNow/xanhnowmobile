import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/root_scaffold.dart';
import 'pages/register_page.dart';
import 'pages/change_password_page.dart';
import 'pages/forgot_password_page.dart';

void main() {
  runApp(const XanhNowApp());
}

class XanhNowApp extends StatelessWidget {
  const XanhNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOXXI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/root': (_) => const RootScaffold(),
        '/register': (_) => const RegisterPage(),
        '/change-password': (_) => const ChangePasswordPage(),
        '/forgot-password': (_) => const ForgotPasswordPage(),
      },
    );
  }
}
