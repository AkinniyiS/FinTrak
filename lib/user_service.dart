import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  final String baseUrl = 'http://localhost:3000';
  http.Client _client;
  bool _isLoggedIn = false;

  UserService({http.Client? client}) : _client = client ?? http.Client();

  bool isLoggedIn() => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        _isLoggedIn = true;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addExpense(double amount, String category) async {
    if (!_isLoggedIn) return false;
    if (amount <= 0 || category.isEmpty) return false;
    // Simulate saving expense (e.g., to SQLite or server)
    return true;
  }
}