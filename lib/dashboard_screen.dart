import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'input_transaction_screen.dart';

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
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 7, 89, 59)),
                onPressed: () {},
                child: Text('Budget'),
              ),
            ),
            Positioned(
              bottom: 150,
              
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 7, 89, 59)),
                onPressed: () {},
                child: Text('Report'),
              ),
            ),
            Positioned(
              bottom: 400,
              
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 7, 89, 59)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InputTransactionScreen())
                  );
                },
                child: Text('Input Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
