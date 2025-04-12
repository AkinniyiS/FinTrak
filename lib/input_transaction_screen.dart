import 'package:fintrak/gradient.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InputTransactionScreen extends StatefulWidget {
  final int accountId;

  const InputTransactionScreen({super.key, required this.accountId});

  @override
  State<InputTransactionScreen> createState() => _InputTransactionScreenState();
}

class _InputTransactionScreenState extends State<InputTransactionScreen> {
  
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String transactionType = 'Expense';
  String selectedCategory = 'Groceries';

  final List<String> categories = [
    'Groceries',
    'Transportation',
    'Utilities',
    'Insurance',
    'Education',
    'Shopping/Entertainment',
    'Dining'
  ];

  Future<void> addTransaction() async {
    final url = Uri.parse('http://10.0.2.2:4000/api/transactions/add');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": double.tryParse(amountController.text) ?? 0.0,
        "type": transactionType,
        "category": selectedCategory,
        "description": descriptionController.text,
        "account_id": widget.accountId 
      }),
    );

    if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Transaction added!')),
   );
    Navigator.pop(context, true); //Trigger dashboard refresh

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
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: transactionType,
                items: ['Income', 'Expense'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => transactionType = value!),
                decoration: InputDecoration(labelText: "Type"),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value!),
                decoration: InputDecoration(labelText: "Category"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
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
