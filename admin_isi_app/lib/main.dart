import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/admin_auth/pages/home.dart';

import 'package:namer_app/admin_auth/pages/login.dart';
import 'package:namer_app/admin_auth/pages/signup.dart';
import 'package:namer_app/firebase_options.dart';
import 'package:namer_app/splash_screen/splash_screen.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if the user is already signed in
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  Widget initialRoute = (user != null) ? Home() : Login();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final Widget initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISI App',
      initialRoute: '/',
      routes: {
        '/': (context) =>  AnimatedSplashScreen(
          splash: Image.asset('assets/logo.png'),
          nextScreen: initialRoute,
          splashTransition: SplashTransition.fadeTransition,
          duration: 3000,
        ),
        '/login': (context) => Login(),
        '/signUp': (context) => SignUp(),
        '/home': (context) => Home(),
      },
    );
  }
}
