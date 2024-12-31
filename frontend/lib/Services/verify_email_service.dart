import 'dart:convert';
import 'package:http/http.dart' as http;

class VerifyEmailApi {
  static Future<Map<String, dynamic>> verifyEmail({
    required String confirmToken,
    required String verificationCode,
  }) async {
    const String apiUrl = 'http://127.0.0.1:5000/api/user/verify-email';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "confirm_token": confirmToken,
          "verification_code": verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['resultCode'] == '00058') {
          return {
            'success': true,
            'message': responseData['resultMessage']['vn'],
            'accessToken': responseData['access_token'],
            'refreshToken': responseData['refresh_token'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['resultMessage']['vn'] ??
                'Đã xảy ra lỗi. Vui lòng thử lại.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Lỗi server. Vui lòng thử lại sau.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến server: $e',
      };
    }
  }
}
