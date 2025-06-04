import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String THEME_KEY = 'isDarkMode';
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    initializeTheme();
  }

  Future<void> initializeTheme() async {
    await _loadThemeFromPrefs();
    _isInitialized = true;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveThemeToPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(THEME_KEY) ?? false;
    } catch (e) {
      print('Error loading theme preferences: $e');
      _isDarkMode = false;
    }
  }

  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(THEME_KEY, _isDarkMode);
    } catch (e) {
      print('Error saving theme preferences: $e');
    }
  }
} 