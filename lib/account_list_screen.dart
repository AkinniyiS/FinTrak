import 'package:fintrak/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'add_account_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountListScreen extends StatefulWidget {
  final int userId;

  const AccountListScreen({super.key, required this.userId});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<dynamic> accounts = [];

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    final url = Uri.parse('http://10.0.2.2:4000/api/accounts/user/${widget.userId}');

    try {
      final response = await http.get(url);
      print('Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          accounts = data;
        });
      } else {
        print('Failed to load accounts');
      }
    } catch (e) {
      print('Error fetching accounts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Accounts"),
      ),
      body: Column(
        children: [
          Expanded(
            child: accounts.isEmpty
              ? Center(child: Text("No accounts found."))
              : ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return ListTile(
                      title: Text(account['account_name']),
                      subtitle: Text("Account ID: ${account['account_id']}"),
                      trailing: Text(account['account_type'] ?? ""),
                      onTap: () {
                        Navigator.push(
                          context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(
                            userId: widget.userId,
                           accountId: account['account_id'],
                         ),
                        ),
                      );
                      },
                    );
                  },
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 7, 89, 59),
                minimumSize: Size(double.infinity, 50),
              ),
              icon: Icon(Icons.add),
              label: Text("Add Account"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAccountScreen(userId: widget.userId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
