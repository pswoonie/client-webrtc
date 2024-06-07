import 'package:flutter/material.dart';

import '../../../state/auth_state.dart';
import '../../../state/room_state.dart';

class Mobile extends StatelessWidget {
  final AuthState authController;
  final RoomState roomController;
  const Mobile({
    super.key,
    required this.authController,
    required this.roomController,
  });

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
