import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // These options should be replaced with your actual Firebase configuration
    // You can get these values from your google-services.json file
    return const FirebaseOptions(
      apiKey: 'AIzaSyDsfLX_jEbwmBfHmYGm26VdnrTr0ju0lzM',
      appId: '1:954275998939:android:5c608fb6c1e0a25836f0fe',
      messagingSenderId: '954275998939',
      projectId: 'weatherapp-85a3f',
      storageBucket: 'weatherapp-85a3f.firebasestorage.app',
      androidClientId: '',
      iosClientId: '',
    );
  }
} 