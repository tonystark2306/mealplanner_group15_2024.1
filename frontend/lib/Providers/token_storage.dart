// lib/utils/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_planner_app/Services/refresh_token.dart';
class TokenStorage {
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    TokenRefresher.startAutoRefresh();
    //print('local storage: $refreshToken');
  }

  static Future<Map<String, String>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';
    final refreshToken = prefs.getString('refresh_token') ?? '';
    //print('local storage 22: $refreshToken');
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  static Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
  static Future<void> updateTokens(String accessToken, String refreshToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', accessToken);
  await prefs.setString('refresh_token', refreshToken);
}
}
