import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api/auth';
  // For Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:5000/api/auth';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  String? get token => _token;

  // Initialize SharedPreferences asynchronously
  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    print('Loaded token from storage: $_token');
  }

  // Load token from storage (call this on app start or page load)
  Future<void> loadToken() async {
    await _initPrefs();
  }

  // Save token to storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
    print('Saved token to storage: $token');
  }

  // Clear token from storage
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    print('Logged out and cleared token');
  }

  // Check if user is authenticated
  bool isAuthenticated() => _token != null;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Login response status: ${response.statusCode}');
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']); // Save token on successful login
      return data;
    } else {
      try {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['msg'] ?? 'Login failed');
      } catch (e) {
        throw Exception('Server returned an unexpected response: ${response.body}');
      }
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    print('Register response status: ${response.statusCode}');
    print('Register response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']); // Save token on successful registration
      return data;
    } else {
      try {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['msg'] ?? 'Registration failed');
      } catch (e) {
        throw Exception('Server returned an unexpected response: ${response.body}');
      }
    }
  }
}