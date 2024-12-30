import 'dart:convert';
import 'package:http/http.dart' as http;

class VerifyEmailApi {
  static const String apiUrl = 'http://127.0.0.1:5000/api/user/verify-email';

  static Future<Map<String, dynamic>> verifyEmail({
    required String confirmToken,
    required String verificationCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'confirm_token': confirmToken,
          'verification_code': verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['resultCode'] == '00058') {
          return {
            'success': true,
            'message': responseBody['resultMessage']['vn'],
          };
        } else {
          return {
            'success': false,
            'message': responseBody['resultMessage']['vn'],
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Lỗi ${response.statusCode}: Không thể xác thực email.',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${error.toString()}',
      };
    }
  }
}
