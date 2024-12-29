import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/shopping_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage.dart';
import 'group_id_provider.dart';

class ShoppingProvider with ChangeNotifier {
  final List<ShoppingItem> _shoppingList = [];

  List<ShoppingItem> get shoppingList => _shoppingList;
  Future<String> _getGroupId() async {
    final groupId = await GroupIdProvider.getSelectedGroupId();
    print(groupId);
    return groupId ?? ''; // Trả về access token
  }

  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? ''; // Trả về access token
  }

  String formatDueTime(String dueTime) {
    // Chuyển chuỗi thành đối tượng DateTime
    try {
      // Cắt bớt phần '00:00:00 GMT' ở cuối chuỗi
      String formattedDueTime = dueTime.split(' ')[0] +
          ' ' +
          dueTime.split(' ')[1] +
          ' ' +
          dueTime.split(' ')[2] +
          ' ' +
          dueTime.split(' ')[3];

      return formattedDueTime;
    } catch (error) {
      return 'No due date';
    }
  }

  Future<void> fetchShoppingList() async {
    final groupId = await _getGroupId();
    final url = Uri.parse('http://127.0.0.1:5000/api/shopping/$groupId');
    final token = await _getAccessToken();
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer $token', // Thêm token vào header Authorization
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        final List<dynamic> shoppingLists = decodedResponse['shopping_lists'];
        _shoppingList.clear();
        _shoppingList.addAll(shoppingLists.map((item) {
          //print(item['tasks']);
          ShoppingItem newShopingItem = ShoppingItem(
            id: item['id'] ?? '',
            name: item['name'] ?? '',
            assignedTo: item['assigned_to'] ?? '',
            notes: item['notes'] ?? '',
            dueTime: formatDueTime(item['due_time'] ?? ''),
            nameAssignedTo: item['assigned_to_username'] ?? '',
            isDone:
                (item['status'] ?? '') == 'Completed', // Kiểm tra trạng thái
          );
          return newShopingItem;
        }).toList());

        notifyListeners();
      } else {
        throw Exception('Failed to load shopping list');
      }
    } catch (error) {
      throw Exception('Error fetching shopping list: $error');
    }
  }

  Future<void> addShoppingItem(ShoppingItem item) async {
    final groupId = await _getGroupId();
    final String url = 'http://127.0.0.1:5000/api/shopping/$groupId'; // API URL
    final token = await _getAccessToken();
    // Chuyển đối tượng ShoppingItem thành JSON
    final Map<String, dynamic> body = {
      "name": item.name,
      "assigned_to": item.nameAssignedTo,
      "notes": item.notes,
      "due_time": item.dueTime, // Đảm bảo định dạng đúng 'yyyy-MM-dd HH:mm:ss'
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Nếu cần token thì thêm ở đây
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body), // Chuyển body thành JSON
      );

      if (response.statusCode == 201) {
        // Thành công, có thể thực hiện thêm hành động
        item.id = json.decode(response.body)['created_shopping_list']
            ['id']; // Lấy id từ phản hồi
        item.dueTime = formatDueTime(
            json.decode(response.body)['created_shopping_list']['due_time']);
        _shoppingList.add(item); // Thêm vào danh sách local
        addTaskToShopping(
            item.id,
            item.tasks
                .map((task) => {
                      'food_name': task.title,
                      'quantity': task.quanity,
                    })
                .toList()); // Thêm tasks nếu có
        notifyListeners(); // Cập nhật UI
        print('Shopping item added successfully');
      } else {
        throw Exception('Failed to add shopping item: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error when posting shopping item: $error');
    }
  }

  Future<void> addTaskToShopping(
      String shoppingId, List<Map<String, String>> tasks) async {
    final groupId = await _getGroupId();
    final String url =
        'http://127.0.0.1:5000/api/shopping/$groupId/task'; // API URL
    final token = await _getAccessToken();

    // Tạo body dữ liệu JSON cho request
    final Map<String, dynamic> body = {
      "list_id": shoppingId, // groupId từ phản hồi của shopping item
      "tasks": tasks, // Danh sách tasks mà bạn muốn gửi
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Thêm token nếu cần
    };

    try {
      // Gửi POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body), // Chuyển body thành JSON
      );

      if (response.statusCode == 201) {
        print('Tasks added to shopping list successfully');
      } else {
        throw Exception(
            'Failed to add tasks to shopping list: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error when posting tasks to shopping list: $error');
    }
  }

  void updateShoppingItem(String id, ShoppingItem updatedItem) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index] = updatedItem;
      notifyListeners();
    }
  }

  Future<void> deleteShoppingItem(String id) async {
    final groupId = await _getGroupId();
    final url = Uri.parse('http://127.0.0.1:5000/api/shopping/$groupId');
    final token = await _getAccessToken();

    // Tạo body cho request DELETE
    final Map<String, dynamic> body = {
      'list_id': id, // Truyền id vào body
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Thêm token nếu cần
    };

    try {
      // Gửi DELETE request
      final response = await http.delete(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Xóa thành công, cập nhật danh sách local
        _shoppingList.removeWhere((item) => item.id == id);
        notifyListeners(); // Cập nhật UI
        print('Shopping item deleted successfully');
      } else {
        throw Exception(
            'Failed to delete shopping item: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error when deleting shopping item: $error');
    }
  }

  void toggleShoppingItemDone(String id) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index].isDone = !_shoppingList[index].isDone;
      notifyListeners();
    }
  }

  void addTaskToShoppingItem(String shoppingItemId, TaskItem task) {
    final index = _shoppingList.indexWhere((item) => item.id == shoppingItemId);
    if (index != -1) {
      _shoppingList[index].tasks.add(task);
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String shoppingItemId, String taskId) {
    final shoppingIndex =
        _shoppingList.indexWhere((item) => item.id == shoppingItemId);
    if (shoppingIndex != -1) {
      final taskIndex = _shoppingList[shoppingIndex]
          .tasks
          .indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        notifyListeners();
      }
    }
  }
}
