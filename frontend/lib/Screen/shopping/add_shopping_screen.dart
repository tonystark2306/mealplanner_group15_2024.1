import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/shopping_provider.dart';
import '../../Models/shopping_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Providers/token_storage.dart'; // Import TokenStorage
class AddShoppingItemScreen extends StatefulWidget {
  @override
  State<AddShoppingItemScreen> createState() => _AddShoppingItemScreenState();
}

class _AddShoppingItemScreenState extends State<AddShoppingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _assignedToController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _dueTime;

  List<Map<String, dynamic>> _foodList = []; // Danh sách thực phẩm
  String? _selectedFoodName;
  String? _selectedUnitName;
  List<TaskItem> _taskList = []; // Danh sách task

  @override
  void dispose() {
    _nameController.dispose();
    _assignedToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? ''; // Trả về access token
  }

  // Lấy danh sách thực phẩm từ API
  Future<void> _fetchFoodList() async {
    final groupId =
        'aa67b8a7-2608-4125-9676-9ba340bd5deb'; // Lấy từ nơi bạn cần
    final token = await _getAccessToken();
    final url = Uri.parse('http://127.0.0.1:5000/api/food/group/$groupId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer $token', // Thêm token vào header Authorization
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _foodList = data
              .map((item) =>
                  {'name': item['name'], 'unitName': item['unit_name']})
              .toList();
        });
      } else {
        throw Exception('Failed to load food list');
      }
    } catch (error) {
      throw Exception('Error fetching food list: $error');
    }
  }

  void _pickDueDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dueTime = pickedDate;
      });
    }
  }

  void _saveShoppingItem() {
    if (_formKey.currentState!.validate()) {
      final shoppingItem = ShoppingItem(
        id: DateTime.now().toString(),
        name: _nameController.text,
        assignedTo: _assignedToController.text,
        notes: _notesController.text,
        dueTime: _dueTime.toString() ?? DateTime.now().toString(),
        isDone: false,
        tasks: _taskList,
      );

      Provider.of<ShoppingProvider>(context, listen: false)
          .addShoppingItem(shoppingItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shopping item added!')),
      );

      Navigator.of(context).pop();
    }
  }

  void _addTask() {
    setState(() {
      _taskList.add(TaskItem(
        id: DateTime.now().toString(),
        title: _selectedFoodName ?? '',
        quanity: "1", // Số lượng mặc định là 1
        unitName: _selectedUnitName ?? '',
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFoodList(); // Gọi API khi màn hình được tải
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tạo shopping',
          style:
              TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _assignedToController,
                  decoration: const InputDecoration(
                    labelText: 'Assigned To',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dueTime != null
                            ? 'Due Date: ${_dueTime!.toLocal()}'
                            : 'No due date selected',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDueDate(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Phần thêm task
                const Text(
                  'Add Tasks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _taskList.map((task) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text(
                            'Quantity: ${task.quanity} | Unit: ${task.unitName}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _taskList.remove(task);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Add Task'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveShoppingItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
