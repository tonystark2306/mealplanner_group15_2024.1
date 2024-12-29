import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiGetGroupDetails {
  static const String baseUrl = 'http://127.0.0.1:5000/api/user/group';

  static Future<Map<String, dynamic>> getGroupDetails(String accessToken, String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$groupId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return body;
      } else {
        throw Exception('Failed to fetch group details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching group details: $e');
    }
  }
}
