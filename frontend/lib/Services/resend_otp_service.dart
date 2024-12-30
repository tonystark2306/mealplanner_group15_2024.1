import 'dart:convert';
import 'package:http/http.dart' as http;

class ResendOtpApi {
  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    const String apiUrl = 'http://127.0.0.1:5000/api/user/send-verification-code';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "email": email,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['resultCode'] == '00048') {
          return {
            'success': true,
            'message': responseData['resultMessage']['vn'],
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
