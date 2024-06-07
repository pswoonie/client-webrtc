import 'package:flutter/material.dart';

import '../../state/auth_state.dart';
import '../../state/room_state.dart';

class Room extends StatelessWidget {
  final AuthState authController;
  final RoomState roomController;
  const Room({
    super.key,
    required this.authController,
    required this.roomController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Room'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(roomController.curr.title),
            Text(roomController.curr.id),
          ],
        ),
      ),
    );
  }
}
