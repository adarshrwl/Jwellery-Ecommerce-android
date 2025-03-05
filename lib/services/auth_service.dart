import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // If using an Android emulator, replace localhost with 10.0.2.2
  static const String baseUrl = 'http://localhost:5000/api/auth';
  // For Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:5000/api/auth';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    // Debug logging
    print('Login response status: ${response.statusCode}');
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Attempt to parse server error
      try {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['msg'] ?? 'Login failed');
      } catch (e) {
        throw Exception(
            'Server returned an unexpected response: ${response.body}');
      }
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    // Debug logging
    print('Register response status: ${response.statusCode}');
    print('Register response body: ${response.body}');

    if (response.statusCode == 201) {
      // The server sends { message, token, user: { ... } }
      return jsonDecode(response.body);
    } else {
      // Attempt to parse server error
      try {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['msg'] ?? 'Registration failed');
      } catch (e) {
        throw Exception(
            'Server returned an unexpected response: ${response.body}');
      }
    }
  }
}
