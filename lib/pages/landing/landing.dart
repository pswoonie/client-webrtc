import 'package:flutter/material.dart';

import '../../state/auth_state.dart';

class Landing extends StatelessWidget {
  final AuthState authController;
  const Landing({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Landing'),
      ),
      body: const SizedBox(),
    );
  }
}
