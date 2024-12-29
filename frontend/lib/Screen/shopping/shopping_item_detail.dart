import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../Providers/shopping_provider.dart';
import '../../../Providers/token_storage.dart'; // Import TokenStorage

class ShoppingItemDetailsDialog extends StatefulWidget {
  final String shoppingItemId; // ID của shopping item để fetch task
  final String groupId = 'aa67b8a7-2608-4125-9676-9ba340bd5deb';

  ShoppingItemDetailsDialog({required this.shoppingItemId});

  @override
  _ShoppingItemDetailsDialogState createState() =>
      _ShoppingItemDetailsDialogState();
}

class _ShoppingItemDetailsDialogState extends State<ShoppingItemDetailsDialog> {
  bool isCompleted = false; // Trạng thái của checkbox

  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens(); // Đảm bảo đã chờ đợi kết quả
    return tokens['accessToken'] ?? ''; // Trả về access token
  }

  Future<List<Map<String, String>>> fetchTasks() async {
    final url = Uri.parse('http://127.0.0.1:5000/api/shopping/${widget.groupId}/task');
    final token = await _getAccessToken(); // Lấy token

    try {
      var request = http.Request('GET', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Authorization'] =
            'Bearer ${token}'; // Dùng token từ _getAccessToken

      request.body = json.encode({'list_id': widget.shoppingItemId.toString()});
      
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseBody);
        final List<dynamic> taskList =
            data['tasks']; // Giả sử tasks trả về trong key "tasks"

        List<Map<String, String>> formattedTasks = taskList.map((task) {
          return {
            'food_name': task['food_id']?.toString() ?? '',
            'quantity': task['quantity']?.toString() ?? '',
          };
        }).toList();

        return formattedTasks;
      } else {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        throw Exception('Failed to load tasks');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  Future<void> markTaskAsCompleted() async {
    final url = Uri.parse(
        'http://127.0.0.1:5000/shopping/${widget.groupId}/task/mark');
    final token = await _getAccessToken(); // Lấy token

    try {
      var request = http.Request('PUT', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Authorization'] =
            'Bearer ${token}'; // Dùng token từ _getAccessToken

      // Body cần truyền vào API
      request.body = json.encode({
        'list_id': widget.shoppingItemId,
        //'task_id': widget.task_id, // Giả sử bạn muốn dùng taskId cụ thể
      });

      // Gửi yêu cầu PUT
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Task marked as completed');
      } else {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        throw Exception('Failed to mark task as completed');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider =
        Provider.of<ShoppingProvider>(context, listen: false);
    final shoppingItem = shoppingProvider.shoppingList.firstWhere(
      (item) => item.id == widget.shoppingItemId,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shoppingItem.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.person, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Assigned to: ${shoppingItem.assignedTo ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Due time: ${shoppingItem.dueTime ?? 'No due date'}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, String>>>(
              future: fetchTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Failed to load tasks');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No tasks available', style: TextStyle(color: Colors.grey));
                } else {
                  final tasks = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(task['food_name']!, 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          subtitle: Text('Quantity: ${task['quantity']}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        ),
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      isCompleted = value ?? false;
                    });
                  },
                ),
                Text('Mark as completed'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút Hủy
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng popup mà không làm gì cả
                  },
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red, // Màu chữ đỏ để dễ phân biệt
                    ),
                  ),
                ),
                // Nút Xác nhận
                ElevatedButton(
                  onPressed: () {
                    if (isCompleted) {
                      markTaskAsCompleted(); // Giả sử bạn dùng taskId cụ thể
                    }
                    Navigator.of(context).pop(); // Đóng popup
                  },
                  child: Text(
                    'Xác nhận',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Chữ trắng cho nổi bật trên nền màu
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Màu nền nút Xác nhận
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
