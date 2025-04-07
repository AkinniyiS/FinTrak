import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddAccountScreen extends StatefulWidget {
  final int userId;
  const AddAccountScreen({required this.userId, super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
  }

  class _AddAccountScreenState extends State<AddAccountScreen> {
    final _formKey = GlobalKey<FormState>();
    String accountName = '';
    String accountType = 'savings';
    double balance = 0.00;
    bool isSubmitting = false;

    final List<String> accountTypes = ['savings', 'checking', 'investement', 'credit'];

    Future<void> _submitAccount() async {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();

      setState(()=> isSubmitting = true);

      try{
        final response = await http.post(
          Uri.parse('http://10.0.2.2:4000/api/accounts'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': widget.userId,
            'account_name': accountName,
            'account_type': accountType,
            'balance': balance,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account created!')),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['error']}')),
          );
        }
      }catch (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }finally{
        setState(()=> isSubmitting = false);
      }
    }

    @override
    Widget build(BuildContext context){
      return Scaffold(
        appBar: AppBar(title: Text('Add New Account')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Account Name'),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => accountName = val!,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: accountType,
                  items: accountTypes
                      .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() + type.substring(1)),
                      ))
                    .toList(),
                  onChanged: (val) => setState(() => accountType = val!),
                  decoration: InputDecoration(labelText: 'Account Type'),
                ),
                SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Initial Balance'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
                onSaved: (val) => balance = double.tryParse(val!) ?? 0,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isSubmitting ? null : _submitAccount,
                  child: isSubmitting
                  ? CircularProgressIndicator(color:Colors.green[800])
                  : Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }