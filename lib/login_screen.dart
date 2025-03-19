import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, checkUserStatus);
  }

  void checkUserStatus() async {
    User? user = _auth.currentUser;
    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
  }

  Future<void> login() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        String? idToken = await user.getIdToken();
        print("Firebase ID Token: $idToken");

        if (idToken != null) {
          await sendTokenToBackend(idToken);
        }
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = "Login failed. Please try again.";
          isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    }
  }

  Future<void> sendTokenToBackend(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/auth/firebase'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      print("Backend Response: ${response.statusCode} - ${response.body}");

      if (!mounted) return;
      if (response.statusCode == 200) {
        Future.delayed(Duration.zero, () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          }
        });
      } else {
        setState(() {
          errorMessage = jsonDecode(response.body)['error'] ?? "Unknown error";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Network error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text("Login"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text("Don't have an account? Register here"),
            ),
          ],
        ),
      ),
    );
  }
}
