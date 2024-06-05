import 'package:flutter/material.dart';

import '../../state/auth_state.dart';

class Login extends StatelessWidget {
  final AuthState authController;
  const Login({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login'),
      ),
      body: const SizedBox(),
    );
  }
}
