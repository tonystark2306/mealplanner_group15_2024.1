import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_planner_app/Providers/token_storage.dart';

class CategoryApiDelete {
  static const String baseUrl = "http://127.0.0.1:5000/api/admin/category";

  static Future<bool> deleteCategory(String name) async {
    final url = Uri.parse(baseUrl);
    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'];

    if (accessToken == null || accessToken.isEmpty) {
      print("Access token is missing.");
      return false;
    }

    final requestBody = {'name': name.trim()};

    // In dữ liệu gửi trước khi gọi API
    print("========== START REQUEST ==========");
    print("Endpoint: $url");
    print("Request Body: ${json.encode(requestBody)}");
    print("========== END REQUEST ==========");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print("API Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error occurred while sending request: $e");
      return false;
    }
  }
}
