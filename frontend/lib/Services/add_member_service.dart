import 'dart:convert';
import 'package:http/http.dart' as http;

class AddMemberService {
  static const String baseUrl = 'http://127.0.0.1:5000/api/user/group';

  static Future<void> addMember(
      String accessToken, String groupId, List<String> memberUsernames) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$groupId/add'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'memberUsernames': memberUsernames,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('Thêm thành viên thành công: $responseBody');
      } else {
        throw Exception('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm thành viên: $e');
    }
  }
}
