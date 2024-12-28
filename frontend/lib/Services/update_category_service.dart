import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_planner_app/Providers/token_storage.dart';

class CategoryApiEdit {
  static const String baseUrl = "http://127.0.0.1:5000/api/admin/category";

  static Future<bool> editCategory(String oldName, String newName) async {
    final url = Uri.parse(baseUrl);

    // Lấy Access Token từ TokenStorage
    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'];

    if (accessToken == null || accessToken.isEmpty) {
      print("Access token is missing");
      return false;
    }

    final requestBody = json.encode({
      'newName': newName,
      'oldName': oldName,
      
    });

    print("Request Body: $requestBody");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        print("Category updated successfully");
        return true;
      } else {
        print("Failed to update category: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error occurred while updating category: $e");
      return false;
    }
  }
}
