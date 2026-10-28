import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Values come from --dart-define-from-file=config.json when given; the
// defaults are project myexpense-43bec (same keys as google-services.json).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: String.fromEnvironment(
          'FIREBASE_API_KEY_WEB',
          defaultValue: 'AIzaSyBS4myon4VIyjulRiHoSSISh9pRabw9avI',
        ),
        authDomain: String.fromEnvironment(
          'FIREBASE_AUTH_DOMAIN',
          defaultValue: 'myexpense-43bec.firebaseapp.com',
        ),
        projectId: String.fromEnvironment(
          'FIREBASE_PROJECT_ID',
          defaultValue: 'myexpense-43bec',
        ),
        storageBucket: String.fromEnvironment(
          'FIREBASE_STORAGE_BUCKET',
          defaultValue: 'myexpense-43bec.firebasestorage.app',
        ),
        messagingSenderId: String.fromEnvironment(
          'FIREBASE_MESSAGING_SENDER_ID',
          defaultValue: '462337591823',
        ),
        appId: String.fromEnvironment(
          'FIREBASE_APP_ID_WEB',
          defaultValue: '1:462337591823:android:cea223d5800124e379717a',
        ),
        measurementId: String.fromEnvironment(
          'FIREBASE_MEASUREMENT_ID',
          defaultValue: '',
        ),
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment(
            'FIREBASE_API_KEY_ANDROID',
            defaultValue: 'AIzaSyBS4myon4VIyjulRiHoSSISh9pRabw9avI',
          ),
          appId: String.fromEnvironment(
            'FIREBASE_APP_ID_ANDROID',
            defaultValue: '1:462337591823:android:cea223d5800124e379717a',
          ),
          messagingSenderId: String.fromEnvironment(
            'FIREBASE_MESSAGING_SENDER_ID',
            defaultValue: '462337591823',
          ),
          projectId: String.fromEnvironment(
            'FIREBASE_PROJECT_ID',
            defaultValue: 'myexpense-43bec',
          ),
          storageBucket: String.fromEnvironment(
            'FIREBASE_STORAGE_BUCKET',
            defaultValue: 'myexpense-43bec.firebasestorage.app',
          ),
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
