import 'package:flutter/foundation.dart';

class DarkMode extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void changeMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
