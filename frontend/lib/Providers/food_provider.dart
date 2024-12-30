import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Import to handle web-specific image data
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './token_storage.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';

class FoodProvider extends ChangeNotifier {
  List<dynamic> foods = [];
  bool isLoading = false;

  final String baseUrl = "http://localhost:5000";
  String generateUniqueFileName(String baseName) {
    final String timestamp =
        DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${baseName}_$timestamp.jpg';
  }

  // Lấy danh sách thực phẩm từ server
  Future<void> fetchFoods(String groupId) async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();

    isLoading = true;
    // notifyListeners();
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

  //Hàm lấy danh sách unit name
  Future<List<String>> fetchUnitNames() async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      print('Fetching unit names...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/unit'),
        headers: {
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
      );
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['units'];
        List<String> unitNames = [];
        for (var unit in data) {
          unitNames.add(unit['name']);
        }
        return unitNames;
      } else {
        throw Exception('Failed to fetch unit names');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  //Hàm lấy danh sách category name
  Future<List<String>> fetchCategoryNames() async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      print('Fetching category names...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/category'),
        headers: {
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
      );
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['categories'];
        List<String> categoryNames = [];
        for (var category in data) {
          categoryNames.add(category['name']);
        }
        return categoryNames;
      } else {
        throw Exception('Failed to fetch category names');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> addFood({
    required String groupId,
    required String name,
    required String type,
    required String categoryName,
    required String unitName,
    required String note,
    File? image,
    var imageWeb, // Thêm imageWeb cho web
  }) async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    print('Adding food...');
    print('name: $name');
    print('type: $type');
    print('categoryName: $categoryName');
    print('unitName: $unitName');
    print('note: $note');

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/food/group/$groupId'),
      );
      request.headers['Authorization'] = 'Bearer ${tokenObject['accessToken']}';

      request.fields['name'] = name;
      request.fields['type'] = type;
      request.fields['categoryName'] = categoryName;
      request.fields['unitName'] = unitName;
      request.fields['note'] = note;

      // Thêm ảnh vào multipart request tùy thuộc vào nền tảng
      if (kIsWeb && imageWeb != null) {
        // Đối với web, có thể dùng Uint8List hoặc base64
        request.files.add(await http.MultipartFile.fromBytes(
          'image', imageWeb,
          filename: generateUniqueFileName(
              'image.jpg'), // Có thể thay đổi theo yêu cầu
          contentType:
              MediaType('image', 'png'), // Có thể thay đổi theo yêu cầu
        ));
      } else if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send();
      print('response.statusCode: ${response.statusCode}');

      // Đọc body từ StreamedResponse
      final responseBody = await response.stream
          .bytesToString(); // Đọc dữ liệu từ stream và chuyển thành string
      if (response.statusCode == 201) {
        final newFood = jsonDecode(responseBody)['newFood']; // Refresh the list
        foods.add(newFood);
        notifyListeners();
      } else {
        throw Exception('Failed to add food');
      }
    } catch (e) {
      print("Error when adding food: $e");
    }
  }

  Future<void> updateFood({
    required String groupId,
    required String foodId,
    required String name,
    required String type,
    required String categoryName,
    required String unitName,
    required String note,
    File? image,
    var imageWeb,
  }) async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    print('Updating food...');
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/food/group/$groupId'),
      );
      request.headers['Authorization'] = 'Bearer ${tokenObject['accessToken']}';

      request.fields['name'] = name;
      request.fields['type'] = type;
      request.fields['categoryName'] = categoryName;
      request.fields['unitName'] = unitName;
      request.fields['note'] = note;

      // Thêm ảnh vào multipart request tùy thuộc vào nền tảng
      if (kIsWeb && imageWeb != null) {
        request.files.add(await http.MultipartFile.fromBytes(
          'image', imageWeb,
          filename: generateUniqueFileName('image.jpg'),
          contentType:
              MediaType('image', 'png'), // Có thể thay đổi theo yêu cầu
        ));
      } else if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send();
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        // Cập nhật thực phẩm thành công
        await fetchFoods(groupId);
        print("Food updated successfully.");
      } else {
        throw Exception('Failed to update food');
      }
    } catch (e) {
      print("Error when updating food: $e");
    }
  }

  Future<void> deleteFood(String groupId, String foodName) async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();

    try {
      print('Fetching foods...');
      print(jsonEncode({'name': foodName}));
      final response = await http.delete(
        Uri.parse('$baseUrl/api/food/group/$groupId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
        body: jsonEncode({'name': foodName}),
      );
      if (response.statusCode == 200) {
        foods.removeWhere((food) =>
            food['name'] ==
            foodName); // Cập nhật danh sách thực phẩm sau khi xóa
        notifyListeners();
      } else {
        throw Exception('Failed to delete food');
      }
    } catch (error) {
      throw Exception("Error deleting food: $error");
    }
  }
}