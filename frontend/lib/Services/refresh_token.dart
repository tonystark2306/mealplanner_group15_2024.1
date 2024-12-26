import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_planner_app/Providers/token_storage.dart';

class TokenRefresher {
  static const int refreshInterval =  30; // 8 phút (tính bằng giây)
  static Timer? _timer;

  /// Khởi động quá trình tự động refresh token
  static Future<void> startAutoRefresh() async {
    // Làm mới token ngay lập tức trước khi bắt đầu
    // final refreshed = await refreshToken();
    // if (!refreshed) {
    //   print('Không thể làm mới token. Hệ thống sẽ không tự động làm mới.');
    //   return;
    // }

    // Bắt đầu Timer định kỳ
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: refreshInterval), (timer) async {
      final success = await refreshToken();
      if (!success) {
        print('Lỗi làm mới token trong Timer.');
        timer.cancel();
      }
    });

    print('Hệ thống đã bắt đầu làm mới token.');
  }

  /// Dừng quá trình tự động refresh token
  static void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
    print('Hệ thống đã dừng làm mới token tự động.');
  }

  /// Hàm gọi API refresh token
  static Future<bool> refreshToken() async {
    const refreshTokenUrl = 'http://127.0.0.1:5000/api/user/refresh-token';
    final tokens = await TokenStorage.getTokens();
    final refreshToken = tokens['refreshToken'];
    print(refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      print('Refresh token không tồn tại.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(refreshTokenUrl),
        body: json.encode({"refresh_token": refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newAccessToken = responseData['access_token'];
        final newRefreshToken = responseData['refresh_token'];

        // Cập nhật token mới vào bộ nhớ
        await TokenStorage.saveTokens(newAccessToken, newRefreshToken);
        print('Token đã được làm mới thành công.');
        return true;
      } else {
        print('Làm mới token thất bại: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi khi làm mới token: $e');
      return false;
    }
  }
}
