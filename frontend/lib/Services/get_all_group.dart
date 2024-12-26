// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiGetAllGroup {
  static const String baseUrl = 'http://127.0.0.1:5000/api/user/group';

  static Future<Map<String, dynamic>> getFamilyGroups(String accessToken) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
  final body = json.decode(response.body);
  print('API Response: $body'); // In phản hồi từ API
  return body;
} else {
  throw Exception('Failed to fetch groups');
}
  }
}
