import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Logout the user using FirebaseAuth
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Sign out using FirebaseAuth
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(child: Text("Welcome to your Dashboard!")),
    );
  }
}
