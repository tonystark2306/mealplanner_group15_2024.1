import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_planner_app/Providers/token_storage.dart';

class CategoryApiGet {
  static const String baseUrl = "http://127.0.0.1:5000/api/admin/category";

  /// Hàm lấy danh sách tất cả danh mục
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
  final url = Uri.parse(baseUrl);

  final tokens = await TokenStorage.getTokens();
  final accessToken = tokens['accessToken'];

  if (accessToken == null || accessToken.isEmpty) {
    print("Access token is missing");
    return [];
  }

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Lấy danh sách từ trường `categories`
      final List categories = responseData['categories'] ?? [];
      return categories.cast<Map<String, dynamic>>();
    } else {
      print("Failed to fetch categories: ${response.body}");
      return [];
    }
  } catch (e) {
    print("Error occurred while fetching categories: $e");
    return [];
  }
}
}
