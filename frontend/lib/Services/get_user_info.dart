import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_planner_app/Providers/token_storage.dart'; // Import file chứa hàm getTokens()

Future<Map<String, dynamic>?> fetchUserInfo() async {
  const String apiUrl = 'http://127.0.0.1:5000/api/user/'; // Thay URL API thực tế

  try {
    // Lấy access token từ local storage
    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'] ?? '';

    if (accessToken.isEmpty) {
      throw Exception('Access token không tồn tại.');
    }

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('API response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['resultCode'] == '00089') {
        return data['user'];
      } else {
        throw Exception(data['resultMessage']['vn']);
      }
    } else {
      throw Exception('Lỗi API: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user info: $e');
    return null;
  }
}
