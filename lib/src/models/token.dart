import 'package:constata/src/shared/auth_refresh_controller.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class Token with ChangeNotifier {
  String _token = "";

  AuthRefreshController refreshController = AuthRefreshController();

  String get token {
    refreshController.checkAuth(_token).then(
      (value) {
        if (value.isNotEmpty) {
          _token = value;
          developer.log(value, name: 'trocou o token');
          notifyListeners();
        }
      },
    );
    return _token;
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  @override
  String toString() {
    return '{"token":$_token}';
  }
}
