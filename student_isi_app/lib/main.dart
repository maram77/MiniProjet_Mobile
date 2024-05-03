import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_isi_app/api/firebase_api.dart';
import 'package:student_isi_app/firebase_options.dart';
import 'package:student_isi_app/splash_screen/splash_screen.dart';
import 'package:student_isi_app/student_auth/home.dart';
import 'package:student_isi_app/student_auth/login.dart';
import 'package:student_isi_app/student_auth/signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase notifications
  FirebaseApi().initNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISI App',
      initialRoute: '/',
      routes: {
        '/': (context) => AnimatedSplashScreen(
          duration: 4000,
          splash: Image.asset(
            'assets/logo.png',
            height: 100,
            width: 100,
          ),
          nextScreen: SplashScreen(),
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.white,
        ),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
      },
    );
  }
}
