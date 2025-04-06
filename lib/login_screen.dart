import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import 'add_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

late AnimationController _controller;
late Animation<double> _fadeAnimation;

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Check if user is logged in
  void checkUserStatus() async {
    User? user = _auth.currentUser;
    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
  }

  // Login function to authenticate user
  Future<void> login() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/auth/login'), // Your login API endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String? idToken = responseData['token'];
        String? userId = responseData['userId']; // Get userId from response

        if (idToken != null && userId != null) {
          await sendTokenToBackend(idToken, userId);
        }
      } else {
        setState(() {
          errorMessage = responseData['error'] ?? "Login failed. Please try again.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  // Send Firebase token to backend
  Future<void> sendTokenToBackend(String idToken, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/auth/firebase'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      if (response.statusCode == 200) {
        // After successful response, check for user accounts
        Future.delayed(Duration.zero, () {
          checkUserAccounts(userId);
        });
      } else {
        setState(() {
          errorMessage = jsonDecode(response.body)['error'] ?? "Unknown error";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  // Check if the user has any accounts
  Future<void> checkUserAccounts(String userId) async {
  try {
    final int userIdInt = int.parse(userId);  // Convert String to int
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/api/accounts/user/$userIdInt'),  // Pass the integer userId
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.isEmpty) {
        // Redirect to Add Account screen if no accounts are found
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddAccountScreen(userId: userIdInt)),
        );
      } else {
        // Proceed to dashboard if accounts are found
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    } else {
      setState(() {
        errorMessage = "Failed to check accounts";
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = "Network error: $e";
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome To FinTrak",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    letterSpacing: 1.5,
                  ),
                ),
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
        ),
      ),
    );
  }
}
