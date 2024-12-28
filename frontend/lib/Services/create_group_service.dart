import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meal_planner_app/Providers/token_storage.dart'; // Đảm bảo import đúng file chứa hàm getTokens

Future<bool> createGroupApi(String groupName, List<String> memberUsernames) async {
  const String apiUrl = 'http://127.0.0.1:5000/api/user/group'; // Thay URL API chính xác

  try {
    // Lấy access token từ TokenStorage
    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'];

    if (accessToken == null || accessToken.isEmpty) {
      print('Access token không tồn tại. Vui lòng đăng nhập lại.');
      return false;
    }

    // Tạo payload
    final Map<String, dynamic> payload = {
      "group_name": groupName,
      "memberUsernames": memberUsernames,
    };

    // Gửi yêu cầu POST
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      print('Tạo nhóm thành công');
      return true;
    } else {
      print('Lỗi tạo nhóm: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('Lỗi khi gọi API: $e');
    return false;
  }
}
