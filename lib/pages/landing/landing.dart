import 'package:flutter/material.dart';

import '../../state/auth_state.dart';
import '../../state/room_state.dart';
import 'browser/browser.dart';
import 'mobile/mobile.dart';

class Landing extends StatefulWidget {
  final AuthState authController;
  const Landing({super.key, required this.authController});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  RoomState roomController = RoomState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Browser(
            authController: widget.authController,
            roomController: roomController,
          );
        } else {
          return Mobile(
            authController: widget.authController,
            roomController: roomController,
          );
        }
      },
    );
  }
}
