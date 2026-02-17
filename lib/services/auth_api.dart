import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthApi {
  final String baseUrl;

  AuthApi({this.baseUrl = 'http://localhost:3000'});

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': idToken}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to log in with Google');
    }
  }

  Future<User> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      return response.statusCode == 200 && response.body == 'Hello World!';
    } catch (_) {
      return false;
    }
  }
}
