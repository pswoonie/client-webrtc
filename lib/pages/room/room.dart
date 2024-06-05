import 'package:flutter/material.dart';

import '../../state/auth_state.dart';

class Room extends StatelessWidget {
  final AuthState authController;
  const Room({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Room'),
      ),
      body: const SizedBox(),
    );
  }
}
