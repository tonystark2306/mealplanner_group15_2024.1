import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../Providers/shopping_provider.dart';
import '../../../Providers/token_storage.dart';
import '../../../Providers/group_id_provider.dart';

class ShoppingItemDetailsDialog extends StatefulWidget {
  final String shoppingItemId;
  ShoppingItemDetailsDialog({required this.shoppingItemId});

  @override
  _ShoppingItemDetailsDialogState createState() =>
      _ShoppingItemDetailsDialogState();
}

class _ShoppingItemDetailsDialogState extends State<ShoppingItemDetailsDialog> {
  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? '';
  }

  Future<String> _getGroupId() async {
    final groupId = await GroupIdProvider.getSelectedGroupId();
    return groupId ?? '';
  }

  late Future<List<Map<String, dynamic>>> _tasksFuture;
  late List<Map<String, dynamic>> tasks;
  late Future<String> groupId;

  @override
  void initState() {
    super.initState();
    _tasksFuture = fetchTasks();
  }

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final group_Id = await _getGroupId();
    final url = Uri.parse(
        'http://127.0.0.1:5000/api/shopping/${group_Id}/task?list_id=${widget.shoppingItemId}');
    final token = await _getAccessToken();

    try {
      var request = http.Request('GET', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseBody);
        final List<dynamic> taskList = data['tasks'];

        tasks = taskList.map((task) {
          return {
            'id': task['id'],
            'food_name': task['food_name']?.toString() ?? '',
            'quantity': task['quantity']?.toString() ?? '',
            'status': task['status'] ?? 'Pending',
            'firstStatus': task['status'] ?? 'Pending',
          };
        }).toList();
        return tasks;
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

  Future<void> markTasksAsDone() async {
    final group_id = await _getGroupId();
    final token = await _getAccessToken();
    final url =
        Uri.parse('http://127.0.0.1:5000/api/shopping/${group_id}/task/mark');

    // Lọc các task đã được tick (status = 'Completed')
    final completedTasks = tasks
        .where((task) => (task['status'] == 'Completed' &&
            task['firstStatus'] != 'Completed'))
        .toList();

    try {
      for (var task in completedTasks) {
        final body = json.encode({
          'list_id': widget.shoppingItemId,
          'task_id': task['id'],
        });

        var request = http.Request('PUT', url)
          ..headers['Content-Type'] = 'application/json'
          ..headers['Authorization'] = 'Bearer $token'
          ..body = body;

        final response = await request.send();

        if (response.statusCode == 200) {
          print('Task ${task['id']} marked as completed');
        } else {
          final responseBody = await response.stream.bytesToString();
          print('Failed to mark task: ${responseBody}');
          print(responseBody);
        }
      }

      if (completedTasks.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tasks marked as completed!')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark tasks!')),
      );
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
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.person, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Giao cho: ${shoppingItem.nameAssignedTo ?? 'N/A'}',
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
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.person, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Ghi chú: ${shoppingItem.notes ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Failed to load tasks');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No tasks available',
                      style: TextStyle(color: Colors.grey));
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: task['status'] == 'Completed'
                                ? Colors.green[100]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            title: Text(
                              task['food_name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: task['status'] == 'Completed'
                                    ? Colors.green
                                    : Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Khối lượng: ${task['quantity'].toString().split('.')[0]}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                if (task['status'] == 'Completed')
                                  Text(
                                    'Task Completed',
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Kiểm tra trạng thái task, nếu "Completed" thì chỉ hiển thị icon tick xanh
                                if (task['firstStatus'] == 'Completed')
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                if (task['firstStatus'] != 'Completed')
                                  Checkbox(
                                    value: task['status'] == 'Completed',
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        setState(() {
                                          // Thay đổi trạng thái của task
                                          tasks[index]['status'] =
                                              value ? 'Completed' : 'Pending';
                                        });
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các nút
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete), // Icon delete
                    label: const Text('Đóng'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Nền đỏ
                      foregroundColor: Colors.white, // Chữ trắng
                    ),
                  ),
                ),
                const SizedBox(width: 30), // Khoảng cách giữa 2 nút
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await markTasksAsDone(); // Gửi các task đã được tick lên server
                    },
                    icon: const Icon(Icons.save), // Icon save
                    label: const Text('Xác nhận'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Nền xanh
                      foregroundColor: Colors.white, // Chữ trắng
                    ),
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
