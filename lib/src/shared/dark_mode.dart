import 'package:flutter/material.dart';

class DarkMode extends ChangeNotifier {
  DarkMode() {
    if (brightness == Brightness.dark) {
      _isDarkMode = true;
    } else {
      _isDarkMode = false;
    }
  }
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void changeMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
