import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDsfLX_jEbwmBfHmYGm26VdnrTr0ju0lzM',
          appId: '1:954275998939:android:5c608fb6c1e0a25836f0fe',
          messagingSenderId: '954275998939',
          projectId: 'weatherapp-85a3f',
          storageBucket: 'weatherapp-85a3f.firebasestorage.app',
        ),
      );
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  }
} 