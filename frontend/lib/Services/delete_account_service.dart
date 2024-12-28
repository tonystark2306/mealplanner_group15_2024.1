import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_planner_app/Providers/token_storage.dart';

class DeleteUserApi {
  static const String baseUrl = "http://127.0.0.1:5000/api/user/";

  /// Gọi API xóa tài khoản user
  static Future<bool> deleteUser() async {
    final url = Uri.parse(baseUrl);

    try {
      // Lấy accessToken từ TokenStorage
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];

      if (accessToken == null || accessToken.isEmpty) {
        print("Không tìm thấy accessToken. Vui lòng đăng nhập lại.");
        return false;
      }

      // Gửi yêu cầu DELETE với accessToken trong header
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('API Response: ${response.body}');

      // Xử lý phản hồi từ API
      if (response.statusCode == 200) {
        print("Xóa tài khoản thành công.");
        await TokenStorage.clearTokens(); // Xóa token khỏi local
        return true;
      } else if (response.statusCode == 401) {
        print("AccessToken hết hạn hoặc không hợp lệ.");
        return false;
      } else {
        print("Lỗi khi xóa tài khoản: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return false;
    }
  }
}
