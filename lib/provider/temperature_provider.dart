import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemperatureProvider with ChangeNotifier {
  static const String _tempUnitKey = 'temperature_unit';
  String _unit = '°C';

  TemperatureProvider() {
    _loadPreference();
  }

  String get unit => _unit;

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _unit = prefs.getString(_tempUnitKey) ?? '°C';
    notifyListeners();
  }

  Future<void> setUnit(String unit) async {
    if (unit != _unit) {
      _unit = unit;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tempUnitKey, unit);
      notifyListeners();
    }
  }

  double convertTemperature(double celsius) {
    if (_unit == '°F') {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  String formatTemperature(double celsius) {
    double temp = convertTemperature(celsius);
    return '${temp.round()}$_unit';
  }
} 