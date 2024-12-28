import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_planner_app/Providers/token_storage.dart';
import 'package:meal_planner_app/Services/refresh_token.dart';

Future<void> logoutUser() async {
  TokenRefresher.stopAutoRefresh();
  const logoutUrl = 'http://127.0.0.1:5000/api/user/logout'; // URL của API logout
  final tokens = await TokenStorage.getTokens();
  final accessToken = tokens['accessToken'];
  print('accessToken: $accessToken');
  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('Access token is missing. Please login again.');
  }

  try {
    final response = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 204) {
      print("Hello World");
      await TokenStorage.clearTokens();
    } else {
      final responseBody = json.decode(response.body);
      throw Exception(responseBody['resultMessage'] ?? 'Logout failed.');
    }
  } catch (e) {
    print('Error during logout: $e');
    throw Exception('Failed to logout. Please try again.');
  }
}
