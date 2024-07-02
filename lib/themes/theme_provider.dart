import 'package:flutter/material.dart';
import 'package:food_express/themes/dark_mode.dart';
import 'package:food_express/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darktMode;

  set themeData(ThemeData themeData) {
   _themeData = themeData;
   notifyListeners(); 
  }

  void  toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darktMode;
    } else {
      themeData = lightMode;
    }
  }
}