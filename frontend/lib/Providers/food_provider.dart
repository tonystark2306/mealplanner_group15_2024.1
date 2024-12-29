import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './token_storage.dart';

class FoodProvider extends ChangeNotifier {
  List<dynamic> foods = [];
  bool isLoading = false;

  final String baseUrl = "http://localhost:5000";

  // Lấy danh sách thực phẩm từ server
  Future<void> fetchFoods(String groupId) async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();

    isLoading = true;
    notifyListeners();
    try {
      print('Fetching foods...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/food/group/$groupId'),
        headers: {
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
      );
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        foods = data['foods'];
        notifyListeners();
      } else {
        throw Exception('Failed to fetch foods');
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Thêm món ăn mới
  Future<void> addFood({
    required String groupId,
    required String name,
    required String type,
    required String categoryName,
    required String unitName,
    required String note,
    File? image,
  }) async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    print('Adding food...');
    try {
      // Tạo request multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/food/group/$groupId'),
      );

      // Thêm headers authorization
      request.headers['Authorization'] = 'Bearer ${tokenObject['accessToken']}';

      // Thêm các trường dữ liệu
      request.fields['name'] = name;
      request.fields['type'] = type;
      request.fields['categoryName'] = categoryName;
      request.fields['unitName'] = unitName;
      request.fields['note'] = note;

      // Kiểm tra và thêm ảnh vào multipart request (chỉ khi có ảnh)
      if (image != null && image.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      print('request.fields: ${request.fields}');
      
      // Gửi request và nhận response
      final response = await request.send();

      // Kiểm tra kết quả trả về từ API
      if (response.statusCode == 200) {
        // Lấy lại danh sách thực phẩm sau khi thêm
        await fetchFoods(groupId); // Refresh the list
      } else {
        throw Exception('Failed to add food');
      }
    } catch (e) {
      print("Error when adding food: $e");
    }
  }
}
