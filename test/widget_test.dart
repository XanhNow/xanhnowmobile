import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xanhnow_mobile/pages/login_page.dart';

void main() {
  testWidgets('LoginPage smoke test', (WidgetTester tester) async {
    // Build app với LoginPage làm màn hình đầu tiên
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    // Kiểm tra có nút ĐĂNG NHẬP
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);

    // Kiểm tra có nút Đăng ký ngay
    expect(find.text('Đăng ký ngay'), findsOneWidget);
  });
}
