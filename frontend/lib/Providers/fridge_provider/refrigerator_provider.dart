import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/fridge/fridge_item_model.dart';
import '../token_storage.dart';

class RefrigeratorProvider with ChangeNotifier {
  List<FridgeItem> _items = [];
  List<String> _foodNames = [];  // Store food names in a list

  List<FridgeItem> get items => _items;
  List<String> get foodNames => _foodNames;  // Add this getter

  // Hàm tải danh sách các thực phẩm từ backend
  Future<void> loadFridgeItemsFromApi(String groupId) async {
    final url =
        'http://localhost:5000/api/fridge/$groupId'; 
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      print('Loading food items from API ${url}');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Bearer ${tokenObject['accessToken']}'
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

  //hàm lấy danh sách tên thực phẩm từ api
  Future<void> fetchFoodNames(String groupId) async {
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/food/group/$groupId'),
        headers: {
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['foods'];
        if (data != null) {
          _foodNames = List<String>.from(data.map((food) => food['name']));  // Update the list
          notifyListeners();  // Notify listeners when the food names are updated
        } else {
          throw Exception('Không có thực phẩm trong nhóm');
        }
      } else {
        throw Exception('Failed to fetch food names');
      }
    } catch (e) {
      print(e);
      _foodNames = [];  // Set to empty list on error
      notifyListeners();  // Notify listeners even if the fetch failed
    }
  }


  // Hàm thêm thông tin thực phẩm chỉ định vào local
  Future<FridgeItem> addFridgeToLocal(String groupId, String fridgeId) async{
    final url =
        'http://localhost:5000/api/fridge/$groupId/$fridgeId'; // Thay thế với URL của bạn
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      print('Loading food items from API ${url}');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Bearer ${tokenObject['accessToken']}'
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
  Future<void> addItemToApi(BuildContext context, String groupId, FridgeItem item) async {
    final url =
        'http://localhost:5000/api/fridge/$groupId'; // Thay thế với URL của bạn
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      print("item $item");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${tokenObject['accessToken']}', // Thay 'YOUR_TOKEN' bằng token của người dùng
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
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tên thực phẩm chưa tồn tại')),
      );
      rethrow;
    }
  }

  // Hàm cập nhật thông tin thực phẩm trong tủ lạnh (PUT request)
  Future<void> updateItemInApi(BuildContext context, String groupId, FridgeItem updatedItem) async {
    final url =
        'http://localhost:5000/api/fridge/$groupId'; // Thay thế với URL của bạn
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    print('updateItem ${updatedItem.toDataForPut()}');
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${tokenObject['accessToken']}', // Thay 'YOUR_TOKEN' bằng token của người dùng
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tên thực phẩm chưa tồn tại')),
      );
      throw error;
    }
  }

  // Hàm xóa thực phẩm trong tủ lạnh (DELETE request)
  Future<void> deleteItemFromApi(String groupId, String itemId) async {
    final url =
        'http://localhost:5000/api/fridge/$groupId/$itemId'; // Thay thế với URL của bạn
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${tokenObject['accessToken']}'
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
