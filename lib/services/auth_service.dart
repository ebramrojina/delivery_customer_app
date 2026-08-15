import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_exception.dart';

class AuthResult {
  final String token;
  final AppUser user;
  AuthResult({required this.token, required this.user});
}

class AuthService {
  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone, 'password': password}),
          )
          .timeout(ApiConfig.requestTimeout, onTimeout: () { throw ApiException('The server is waking up, please try again in a few seconds.'); });

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw ApiException(
          body['message'] as String? ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }

      final user = AppUser.fromJson(body['user'] as Map<String, dynamic>);

      if (user.role != 'customer') {
        throw ApiException(
          'This account is registered as "${user.role}", not "customer". '
          'Please use a customer account to log in to this app.',
        );
      }

      return AuthResult(token: body['token'] as String, user: user);
    } on SocketException {
      throw ApiException('Could not reach the server. Check your connection.');
    } on FormatException {
      throw ApiException('Received an unexpected response from the server.');
    }
  }

  Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'phone': phone,
              'password': password,
              'role': 'customer',
            }),
          )
          .timeout(ApiConfig.requestTimeout, onTimeout: () { throw ApiException('The server is waking up, please try again in a few seconds.'); });

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 201) {
        throw ApiException(
          body['message'] as String? ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }

      final user = AppUser.fromJson(body['user'] as Map<String, dynamic>);
      return AuthResult(token: body['token'] as String, user: user);
    } on SocketException {
      throw ApiException('Could not reach the server. Check your connection.');
    } on FormatException {
      throw ApiException('Received an unexpected response from the server.');
    }
  }
}
