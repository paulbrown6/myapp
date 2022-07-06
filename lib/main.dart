import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MainPage();
}

class _MainPage extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    initFirebase();
    return MaterialApp(
      routes: {
        '/': (context) => AuthPage(),
        '/home': (context) => HomePage(),
      },
    );
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
