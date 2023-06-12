import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DarkMode extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void changeMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
