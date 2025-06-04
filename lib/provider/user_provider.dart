import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = false;
  final String _userKey = 'user_profile';

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initializeUser() async {
    print('Starting user initialization...');
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      print('Retrieved user data from SharedPreferences: ${userData != null}');
      
      if (userData != null) {
        _currentUser = UserProfile.fromJson(json.decode(userData));
        await _updateLastLogin();
        print('User initialized successfully: ${_currentUser?.name}');
      } else {
        print('No stored user data found');
      }
    } catch (e) {
      print('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('User initialization completed. isLoading: $_isLoading, hasUser: ${_currentUser != null}');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        photoUrl: photoUrl,
      );
      await _saveToPrefs();
    } catch (e) {
      print('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSavedLocation(String location) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedLocations = List<String>.from(_currentUser!.savedLocations);
      if (!updatedLocations.contains(location)) {
        updatedLocations.add(location);
        _currentUser = _currentUser!.copyWith(savedLocations: updatedLocations);
        await _saveToPrefs();
      }
    } catch (e) {
      print('Error adding saved location: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSavedLocation(String location) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedLocations = List<String>.from(_currentUser!.savedLocations)
        ..remove(location);
      _currentUser = _currentUser!.copyWith(savedLocations: updatedLocations);
      await _saveToPrefs();
    } catch (e) {
      print('Error removing saved location: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreference(String key, dynamic value) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedPreferences = Map<String, dynamic>.from(_currentUser!.preferences);
      updatedPreferences[key] = value;
      _currentUser = _currentUser!.copyWith(preferences: updatedPreferences);
      await _saveToPrefs();
    } catch (e) {
      print('Error updating preference: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String name, String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        lastLogin: DateTime.now(),
      );
      await _saveToPrefs();
    } catch (e) {
      print('Error logging in: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      _currentUser = null;
    } catch (e) {
      print('Error logging out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateLastLogin() async {
    if (_currentUser == null) return;
    
    try {
      _currentUser = UserProfile(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        photoUrl: _currentUser!.photoUrl,
        savedLocations: _currentUser!.savedLocations,
        preferences: _currentUser!.preferences,
        createdAt: _currentUser!.createdAt,
        lastLogin: DateTime.now(),
      );
      await _saveToPrefs();
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    if (_currentUser == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
    } catch (e) {
      print('Error saving to preferences: $e');
    }
  }
} 