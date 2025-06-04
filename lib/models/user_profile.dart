import 'package:flutter/foundation.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> savedLocations;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    List<String>? savedLocations,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLogin,
  })  : savedLocations = savedLocations ?? [],
        preferences = preferences ?? {},
        createdAt = createdAt ?? DateTime.now(),
        lastLogin = lastLogin ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      savedLocations: List<String>.from(json['savedLocations'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: DateTime.parse(json['lastLogin'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'savedLocations': savedLocations,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    List<String>? savedLocations,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      savedLocations: savedLocations ?? this.savedLocations,
      preferences: preferences ?? this.preferences,
      createdAt: this.createdAt,
      lastLogin: this.lastLogin,
    );
  }
} 