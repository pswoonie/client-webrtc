import 'package:flutter/material.dart';

import '../../../state/auth_state.dart';

class Mobile extends StatelessWidget {
  final AuthState authController;
  const Mobile({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Mobile'),
      ),
      body: const SizedBox(),
    );
  }
}
