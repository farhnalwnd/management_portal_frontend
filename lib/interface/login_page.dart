import 'package:flutter/material.dart';
import 'package:frontend/interface/mobile/login_page_mobile.dart';
import 'package:frontend/interface/web/login_page_web.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Web / Tablet Landscape
          return const LoginPageWeb();
        } else {
          // Mobile / Tablet Portrait
          return const LoginPageMobile();
        }
      },
    );
  }
}
