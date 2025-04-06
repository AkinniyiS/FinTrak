import 'package:flutter/material.dart';

class InputTransactionScreen extends StatelessWidget {
  const InputTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Transaction'),
      ),
      body: Center(
        child: Text(
          'This is the Input Transaction Screen',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
