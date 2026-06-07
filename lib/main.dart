import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myexpense/data/services/auth_service.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣  Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2️⃣  Local storage (used by AuthController for credential caching)
  await GetStorage.init();

  // 3️⃣  Register AuthService as a PERMANENT service so it is always findable
  //     via Get.find<AuthService>() — including inside SplashController.onReady.
  await Get.putAsync<AuthService>(() async {
    final svc = AuthService();
    return svc;
  }, permanent: true);

  runApp(const MyExpenseApp());
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyCq6lRxKLi8GyjhMwrjTgGv8h0CFtC3170",
      authDomain: "myexpense-43bec.firebaseapp.com",
      projectId: "myexpense-43bec",
      storageBucket: "myexpense-43bec.firebasestorage.app",
      messagingSenderId: "462337591823",
      appId: "1:462337591823:web:9c64b41bb1acd09779717a",
      measurementId: "G-8PCWW64CRH",
    );
  }
}

class MyExpenseApp extends StatelessWidget {
  const MyExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyExpense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter', // add Inter to pubspec if desired
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D35C4),
        ),
      ),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
    );
  }
}