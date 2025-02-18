import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gover_driver_app/pages/dashboard.dart';
import 'package:gover_driver_app/pages/home_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'appInfo/app_info.dart';
import 'auth/signin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tentative d'initialisation de Firebase
  try {
    await Firebase.initializeApp(
      options: Platform.isAndroid
          ? const FirebaseOptions(
        apiKey: "AIzaSyDTIBk3SMHGCMw_HqPABfBxgBembUumYfg",
        authDomain: "gover-flutter-driver.firebaseapp.com",
        projectId: "gover-flutter-driver",
        storageBucket: "gover-flutter-driver.firebasestorage.app",
        messagingSenderId: "1049060303792",
        appId: "1:1049060303792:web:229218a86c89946b522c75",
        measurementId: "G-D1RH7RK62S",
        databaseURL:
        "https://gover-flutter-driver-default-rtdb.europe-west1.firebasedatabase.app",
      )
          : null,
    );

    // 🔥 Configuration de la connexion Firebase Database
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.goOnline();

    // 🔥 Forcer la persistance de l'authentification Firebase
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

    // 🔥 Vérifier si l'utilisateur reste connecté
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print("🔥 Firebase a déconnecté l'utilisateur !");
      } else {
        print("✅ L'utilisateur est toujours connecté : \${user.uid}");
      }
    });
  } catch (e) {
    print("Firebase déjà initialisé: \$e");
  }

  await Permission.locationWhenInUse.isDenied.then((value) {
    if(value) {
      Permission.locationWhenInUse.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=> AppInfo(),
      child: MaterialApp(
        title: 'Users App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              print("✅ Redirection vers HomePage");
              return const Dashboard();
            }
            print("🔥 Redirection vers SigninPage");
            return const SigninPage();
          },
        ),
      ),
    );
  }
}
