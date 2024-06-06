import 'package:flutter/material.dart';

import '../../../state/auth_state.dart';
import 'widgets/members.dart';
import 'widgets/rooms.dart';

class Browser extends StatelessWidget {
  final AuthState authController;
  const Browser({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: const Center(
          child: Text(
            'Room',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text('Browser'),
      ),
      body: Row(
        children: [
          const Rooms(),
          Members(),
        ],
      ),
    );
  }
}
