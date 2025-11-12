import 'package:flutter/material.dart';

class NotifyTab extends StatelessWidget {
  const NotifyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chưa có thông báo', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
