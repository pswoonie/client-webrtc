import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          width: 500,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
