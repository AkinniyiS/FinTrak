import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:fintrak/user_service.dart';
import 'user_service_test.mocks.dart';
import 'dart:convert';

@GenerateMocks([http.Client])
void main() {
  late UserService userService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    userService = UserService(client: mockClient);
  });

  group('Login Tests', () {
    test('Login succeeds with valid email and password', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: jsonEncode({'email': 'user1@example.com', 'password': 'pass123'}),
      )).thenAnswer((_) async => http.Response('{"success": true}', 200));

      final result = await userService.login('user1@example.com', 'pass123');
      expect(result, isTrue, reason: 'Login should succeed with valid credentials');
      expect(userService.isLoggedIn(), isTrue);
    });

    test('Login fails with valid email and invalid password', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: jsonEncode({'email': 'user1@example.com', 'password': 'wrong'}),
      )).thenAnswer((_) async => http.Response('{"error": "Invalid password"}', 401));

      final result = await userService.login('user1@example.com', 'wrong');
      expect(result, isFalse, reason: 'Login should fail with invalid password');
      expect(userService.isLoggedIn(), isFalse);
    });

    test('Login fails with invalid email and valid password', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: jsonEncode({'email': 'invalid', 'password': 'pass123'}),
      )).thenAnswer((_) async => http.Response('{"error": "User not found"}', 404));

      final result = await userService.login('invalid', 'pass123');
      expect(result, isFalse, reason: 'Login should fail with invalid email');
      expect(userService.isLoggedIn(), isFalse);
    });

    test('Login fails with invalid email and invalid password', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: jsonEncode({'email': 'invalid', 'password': 'wrong'}),
      )).thenAnswer((_) async => http.Response('{"error": "User not found"}', 404));

      final result = await userService.login('invalid', 'wrong');
      expect(result, isFalse, reason: 'Login should fail with all invalid inputs');
      expect(userService.isLoggedIn(), isFalse);
    });

    test('Login fails when server is down', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: jsonEncode({'email': 'user1@example.com', 'password': 'pass123'}),
      )).thenThrow(Exception('Server unavailable'));

      final result = await userService.login('user1@example.com', 'pass123');
      expect(result, isFalse, reason: 'Login should fail when server is down');
      expect(userService.isLoggedIn(), isFalse);
    });
  });

}