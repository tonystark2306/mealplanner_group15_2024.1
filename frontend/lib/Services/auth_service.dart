// lib/api/auth_api.dart
import 'package:http/http.dart' as http;
import 'dart:convert';


class AuthApi {
  static const String _baseUrl = 'http://127.0.0.1:5000/api/user';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      

      return json.decode(response.body); // decode response data
    } else {
      throw Exception('Failed to login'); // Handle errors
    }
  }
}
