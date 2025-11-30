import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lit_reader/env/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UIController extends GetxController {
  final _fontSize = 18.0.obs;
  double get fontSize => _fontSize.value;
  set fontSize(double value) {
    if (value < 10 || value > 30) {
      throw Exception('Font size must be between 10 and 30');
    }
    _fontSize.value = value;
    saveUISettings();
  }

  final _fontColor = 0.obs;
  int get fontColor => _fontColor.value;
  set fontColor(int value) {
    _fontColor.value = value;
    saveUISettings();
  }

  final _lineHeight = 1.5.obs;
  double get lineHeight => _lineHeight.value;
  set lineHeight(double value) {
    if (value < 1.0 || value > 3.0) {
      throw Exception('Line height must be between 1.0 and 3.0');
    }
    _lineHeight.value = value;
    saveUISettings();
  }

  // void toggleDarkMode() {
  //   if (themeMode.value == ThemeMode.dark) {
  //     themeMode.value = ThemeMode.light;
  //   } else {
  //     themeMode.value = ThemeMode.dark;
  //   }
  //   saveUISettings();
  // }

  Future<void> saveUISettings() async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(
        'uiSettings',
        jsonEncode({
          'fontSize': fontSize,
          'lineHeight': lineHeight,
          'fontColor': fontColor,
          'darkMode': themeMode.value == ThemeMode.dark,
        }));
  }

  Future<void> loadUISettings() async {
    final pref = await SharedPreferences.getInstance();

    final settings = pref.getString('uiSettings');
    if (settings != null) {
      final data = jsonDecode(settings);
      fontSize = data['fontSize']?.toDouble() ?? 18.0;
      lineHeight = data['lineHeight']?.toDouble() ?? 1.5;
      fontColor = data['fontColor'] ?? 0; // Default to 0 if not set
      if (data['darkMode'] != null) {
        themeMode.value = data['darkMode'] ? ThemeMode.dark : ThemeMode.light;
      } else {
        themeMode.value = ThemeMode.dark; // Default to system theme
      }
    } else {
      // Set default values if no settings are found
      fontSize = 18.0;
      lineHeight = 1.5;
      fontColor = 0; // Default to 0 if not set
    }
  }
}
