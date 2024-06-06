import 'package:flutter/material.dart';

import '../../state/auth_state.dart';
import 'browser/browser.dart';
import 'mobile/mobile.dart';

class Landing extends StatelessWidget {
  final AuthState authController;
  const Landing({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Browser(authController: authController);
        } else {
          return Mobile(authController: authController);
        }
      },
    );
  }
}
