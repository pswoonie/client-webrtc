import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/login/login.dart';
import 'pages/room/room.dart';
import 'pages/landing/landing.dart';
import 'state/auth_state.dart';
import 'state/room_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  static final AuthState authController = AuthState();
  static final RoomState roomController = RoomState();

  final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return Login(authController: authController);
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'landing',
            builder: (BuildContext context, GoRouterState state) {
              return Landing(
                  authController: authController,
                  roomController: roomController);
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'room',
                builder: (BuildContext context, GoRouterState state) {
                  return Room(
                      authController: authController,
                      roomController: roomController);
                },
              ),
            ],
          ),
        ],
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
