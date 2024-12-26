import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/fridge/fridge_item_model.dart';

class RefrigeratorProvider with ChangeNotifier {
  List<FridgeItem> _items = [];

  List<FridgeItem> get items => _items;

  // Hàm tải danh sách các thực phẩm từ backend
  Future<void> loadFridgeItemsFromApi(String groupId) async {
    final url =
        'http://localhost:5000/api/fridge/$groupId'; // Thay thế với URL của bạn
    try {
      print('Loading food items from API ${url}');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQ1MDFhZDgtNWE0ZS00OTI5LWE3YzItYjhhMjU1OTU2NDE1IiwiZXhwIjoxNzM1MjUzOTEwfQ.k8tA_PALC9TDSNOse9Vzsplm5FJkFSfB5uuX-nkJEOY'
        }, // Thay 'YOUR_TOKEN' bằng token của người dùng
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        final data = json.decode(response.body); // Parse JSON trả về
        final fridgeItems = (data['fridgeItems'] as List)
            .map((item) => FridgeItem.fromJson(item))
            .toList(); // Chuyển đổi từng phần tử thành FridgeItem
        print("object");
        print(fridgeItems);
        _items = fridgeItems; // Gán danh sách cho _items
        notifyListeners(); // Cập nhật UI
        print('Loaded food items');
      } else {
        throw Exception('Failed to load food items');
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Hàm thêm thông tin thực phẩm chỉ định vào local
  Future<FridgeItem> addFridgeToLocal(String groupId, String fridgeId) async{
    final url =
        'http://localhost:5000/api/fridge/$groupId/$fridgeId'; // Thay thế với URL của bạn
    try {
      print('Loading food items from API ${url}');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQ1MDFhZDgtNWE0ZS00OTI5LWE3YzItYjhhMjU1OTU2NDE1IiwiZXhwIjoxNzM1MjUzOTEwfQ.k8tA_PALC9TDSNOse9Vzsplm5FJkFSfB5uuX-nkJEOY'
        }, // Thay 'YOUR_TOKEN' bằng token của người dùng
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        final data = json.decode(response.body); // Parse JSON trả về
        final item = FridgeItem.fromJson(data['fridgeItem']); // Chuyển đổi từng phần tử thành FridgeItem
        return item;
      } else {
        throw Exception('Failed to load food items');
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Hàm thêm thực phẩm vào tủ lạnh (POST request)
  Future<void> addItemToApi(String groupId, FridgeItem item) async {
    final url =
        'http://localhost:5000/api/fridge/$groupId'; // Thay thế với URL của bạn
    try {
      print("item $item");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQ1MDFhZDgtNWE0ZS00OTI5LWE3YzItYjhhMjU1OTU2NDE1IiwiZXhwIjoxNzM1MjgwOTI3fQ.T_08nBTPupJM4PIlQ8z2cBSU8992SZ-fMF3lTDP3K3o', // Thay 'YOUR_TOKEN' bằng token của người dùng
        },
        body: json.encode(item.toJson()),
      );
      print("body ${item.toJson()}");
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newItemId = data['fridge_item']['id'];
        print("newItemId $newItemId");
        FridgeItem item = await addFridgeToLocal(groupId, newItemId);
        addItem(item);
      } else {
        throw Exception('Failed to add food item');
      }
    } catch (error) {
      throw error;
    }
  }

  // Hàm cập nhật thông tin thực phẩm trong tủ lạnh (PUT request)
  Future<void> updateItemInApi(String groupId, FridgeItem updatedItem) async {
    final url =
        'http://localhost:5000/api/fridge/$groupId'; // Thay thế với URL của bạn
    print('updateItem ${updatedItem.toDataForPut()}');
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQ1MDFhZDgtNWE0ZS00OTI5LWE3YzItYjhhMjU1OTU2NDE1IiwiZXhwIjoxNzM1MjUzOTEwfQ.k8tA_PALC9TDSNOse9Vzsplm5FJkFSfB5uuX-nkJEOY', // Thay 'YOUR_TOKEN' bằng token của người dùng
        },
        body: json.encode(updatedItem.toDataForPut()),
      );
      print('updateItem ${updatedItem.toDataForPut()}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedFridgeItemId = data['updated_fridge_item']['id'];
        final FridgeItem item = await addFridgeToLocal(groupId, updatedFridgeItemId);
        updateItem(item);
      } else {
        throw Exception('Failed to update food item');
      }
    } catch (error) {
      print('error $error');
      throw error;
    }
  }

  // Hàm xóa thực phẩm trong tủ lạnh (DELETE request)
  Future<void> deleteItemFromApi(String groupId, String itemId) async {
    final url =
        'http://localhost:5000/$groupId/$itemId'; // Thay thế với URL của bạn
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN'
        }, // Thay 'YOUR_TOKEN' bằng token của người dùng
      );
      if (response.statusCode == 200) {
        removeItem(itemId);
      } else {
        throw Exception('Failed to delete food item');
      }
    } catch (error) {
      throw error;
    }
  }

  // Hàm thêm thực phẩm vào danh sách local
  void addItem(FridgeItem item) {
    _items.add(item);
    notifyListeners();
  }

  // Hàm xóa thực phẩm khỏi danh sách local
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Hàm cập nhật thông tin thực phẩm trong danh sách local
  void updateItem(FridgeItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  // // Hàm xóa thực phẩm khỏi danh sách local
  // void deleteFridgeItem(FridgeItem fridgeItem) {
  //   _items.remove(fridgeItem);
  //   notifyListeners();
  // }
}
