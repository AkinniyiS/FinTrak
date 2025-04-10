import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'input_transaction_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gradient.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin{
  double balance = 0.00;
  bool showBalance = false;

  @override
  void initState(){
  super.initState();
  fetchBalance();
}

Future<void> fetchBalance() async {
  final url =Uri.parse('http://10.0.2.2:4000/api/user/${widget.userId}/balance');

  try{
    final response = await http.get(url);
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      print('Fetched balance: ${data['balance']}');

      setState(() {
        balance = (data['balance'] as num).toDouble();
        showBalance = true;
      });
    }else{
      print('Error fetching balance');
    }
  } catch (e) {
    print('Error: $e');
  }
}
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
      body: GradientBackground(
        child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: AnimatedOpacity(
                opacity: showBalance ? 1.0 : 0.0,
                duration: Duration(seconds: 2),
                child: Text(
                  '\$${balance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 7, 89, 59)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InputTransactionScreen()),
                    );
                  },
                  child: Text('Input Transaction'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 7, 89, 59)),
                  onPressed: () {
                   //empty for now
                  },
                  child: Text('Report'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}