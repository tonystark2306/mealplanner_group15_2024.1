import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiGetAllGroup {
  static const String baseUrl = 'http://127.0.0.1:5000/api/user/group';

  static Future<Map<String, dynamic>> getFamilyGroups(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // Debug: In response body để kiểm tra
      //print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        //print('Parsed Response: $body'); // In phản hồi đã parse
        return body;
      } else {
        // Xử lý lỗi HTTP
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to fetch groups: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý các lỗi ngoại lệ
      print('Exception caught: $e');
      throw Exception('An error occurred while fetching groups: $e');
    }
  }
}
