import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'input_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final int accountId;

  const TransactionHistoryScreen({super.key, required this.accountId});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  Future<void> fetchTransactions() async {
    final url = Uri.parse("http://10.0.2.2:4000/api/transactions/account/${widget.accountId}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          transactions = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        print("Failed to load transactions");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  String formatDate(String rawDate) {
    final dateTime = DateTime.parse(rawDate);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaction History")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? Center(child: Text("No transactions found."))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    final isIncome = txn['type'].toString().toLowerCase() == 'income';

                    return ListTile(
                      leading: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                      title: Text(txn['category']),
                      subtitle: Text("${txn['description'] ?? ""}\n${formatDate(txn['date'])}"),
                      isThreeLine: true,
                      trailing: Text(
                        "\$${(txn['amount'] is num ? txn['amount'].toDouble() : double.tryParse(txn['amount']) ?? 0.0).toStringAsFixed(2)}",
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputTransactionScreen(accountId: widget.accountId),
            ),
          );

          if (result == true) {
            fetchTransactions(); // refresh transactions after new input
          }
        },
        backgroundColor: Color.fromARGB(255, 7, 89, 59),
        child: Icon(Icons.add),
      ),
    );
  }
}
