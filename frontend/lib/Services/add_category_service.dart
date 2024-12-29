import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_planner_app/Providers/token_storage.dart';

class CategoryApiAdd {
  static const String baseUrl = "http://127.0.0.1:5000/api/admin/category";

  /// Hàm thêm danh mục mới
  static Future<bool> addCategory(String categoryName) async {
    final url = Uri.parse(baseUrl);
    
    // Lấy access token từ TokenStorage
    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'];

    // Kiểm tra nếu không có access token
    if (accessToken == null || accessToken.isEmpty) {
      //print("Access token is missing");
      return false;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': categoryName, // Dữ liệu gửi lên API
        }),
      );

      if (response.statusCode == 201) {
        //print("Category added successfully");
        return true;
      } else {
        //print("Failed to add category: ${response.body}");
        return false;
      }
    } catch (e) {
      //print("Error occurred while adding category: $e");
      return false;
    }
  }
}
