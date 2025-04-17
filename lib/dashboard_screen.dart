import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'input_transaction_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gradient.dart';
import 'account_list_screen.dart';
import 'package:fintrak/transaction_history_screen.dart'; 
import 'report_screen.dart';


class DashboardScreen extends StatefulWidget {
  final int userId;
  final int accountId;
  const DashboardScreen({super.key, required this.userId, required this.accountId});

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
    final url = Uri.parse('http://10.0.2.2:4000/api/accounts/${widget.accountId}/balance');

    try{
      final response = await http.get(url);
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        print('Fetched balance: ${data['balance']}');

        setState(() {
          balance = (data['balance'] as num).toDouble();
          showBalance = true;
        });
      } else {
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
                    'Balance: \$${balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionHistoryScreen(accountId: widget.accountId),
                        ),
                      );

                      if (result == true) {
                        fetchBalance(); // Refresh balance after transaction
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 7, 89, 59), // Background color
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Transactions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 0),
                  GestureDetector(
                    onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportScreen(
                 accountId: widget.accountId,
                  userId: widget.userId,
                ),
              ),
           );
          },

                    child: Container(
                      width: 150,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 7, 89, 59), // Background color
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Financial Report',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 7, 89, 59),
                  minimumSize: Size(double.infinity, 50),
                ),
                icon: Icon(Icons.list),
                label: Text("View Accounts"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountListScreen(userId: widget.userId), 
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
