import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoveMemberService {
  static const String baseUrl = 'http://127.0.0.1:5000/api/user/group';

  static Future<void> removeMember(
      String accessToken, String groupId, String username) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$groupId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'username': username}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('Xóa thành viên thành công: $responseBody');
      } else {
        throw Exception('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa thành viên: $e');
    }
  }
}
