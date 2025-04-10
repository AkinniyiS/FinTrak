import 'package:fintrak/gradient.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InputTransactionScreen extends StatefulWidget {
  const InputTransactionScreen({super.key});

  @override
  State<InputTransactionScreen> createState() => _InputTransactionScreenState();
}

class _InputTransactionScreenState extends State<InputTransactionScreen> {
  final TextEditingController amountController = TextEditingController();

  Future<void> addTransaction() async {
    final url = Uri.parse('http://10.0.2.2:4000/api/transactions/add');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"amount": amountController.text, }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction added!')),
      );
      amountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding transaction')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Input Transaction")),
      body: GradientBackground(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Transaction Cost"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addTransaction,
              child: Text("Add Transaction"),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
