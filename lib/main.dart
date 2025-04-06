import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //  Ensures all plugins are initialized
  await Firebase.initializeApp(); //  Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 2, 75, 20), // Color for AppBar and other elements
        scaffoldBackgroundColor: const Color.fromARGB(255, 84, 226, 18), // Background color for screens
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color.fromARGB(255, 63, 23, 205)), // Accent color
      ),
      home: LoginScreen(),
    );
  }
}

