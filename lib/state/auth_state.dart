import 'package:flutter/material.dart';

import '../model/user_model.dart';

class AuthState with ChangeNotifier {
  bool _isLogin = false;
  bool get isLogin => _isLogin;

  UserModel _user = UserModel(id: '', name: '');
  UserModel get user => _user;

  void loginUser(String idParam, String nameParam) {
    _user = UserModel(id: idParam, name: nameParam);
    _isLogin = true;
    notifyListeners();
  }

  void logoutUser() {
    _isLogin = false;
    _user = UserModel(id: '', name: '');
    notifyListeners();
  }
}
