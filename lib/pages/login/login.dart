import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../state/auth_state.dart';

class Login extends StatefulWidget {
  final AuthState authController;
  const Login({super.key, required this.authController});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  String name = '';

  @override
  void initState() {
    super.initState();
    setPermissions();
  }

  void setPermissions() async {
    if (kIsWeb) {
      await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
    } else {
      if (Platform.isAndroid) {
        debugPrint('Platform Android');
        if (await Permission.camera.isDenied ||
            await Permission.audio.isDenied ||
            await Permission.microphone.isDenied) {
          Map<Permission, PermissionStatus> status = await [
            Permission.camera,
            Permission.audio,
            Permission.microphone
          ].request();
          debugPrint('camera: ${status[Permission.camera]}');
          debugPrint('audio: ${status[Permission.audio]}');
          debugPrint('microphone: ${status[Permission.microphone]}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  onSaved: (str) {
                    if (str != null) {
                      name = str;
                    }
                  },
                  validator: (str) {
                    if (str == null || str.isEmpty) {
                      return 'Name is REQUIRED!';
                    }

                    return null;
                  },
                  onFieldSubmitted: (str) {
                    if (str.isEmpty) return;

                    widget.authController.loginUser(str, str);
                    context.go('/landing');
                    _formKey.currentState?.reset();
                  },
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() != null &&
                          _formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.authController.loginUser(name, name);
                        context.go('/landing');
                        _formKey.currentState?.reset();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[200],
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.deepPurple[50],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
