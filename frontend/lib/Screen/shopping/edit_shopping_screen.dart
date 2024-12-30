import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Providers/shopping_provider.dart';
import '../../Models/shopping_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Providers/token_storage.dart'; // Import TokenStorage
import '../../../Providers/group_id_provider.dart'; // Import GroupIdProvider

class EditShoppingItemScreen extends StatefulWidget {
  final ShoppingItem shoppingItem;

  EditShoppingItemScreen({required this.shoppingItem});

  @override
  State<EditShoppingItemScreen> createState() => _EditShoppingItemScreenState();
}

class _EditShoppingItemScreenState extends State<EditShoppingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _assignedToController;
  late TextEditingController _notesController;
  DateTime? _dueTime;

  List<Map<String, dynamic>> _foodList = []; // Danh sách thực phẩm
  List<TaskItem> _taskList = []; // Danh sách task
  List<String> _userList = []; // Danh sách người dùng
  String? _selectedUser; // Người dùng đã chọn

  @override
  void dispose() {
    _nameController.dispose();
    _assignedToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<String> _getGroupId() async {
    final groupId = await GroupIdProvider.getSelectedGroupId();
    return groupId ?? ''; // Trả về group ID
  }

  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? ''; // Trả về access token
  }

  // Lấy danh sách thực phẩm từ API
  Future<void> _fetchFoodList() async {
    final groupId = await _getGroupId();
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
        final Map<String, dynamic> decodedJson = json.decode(response.body);
        final List<dynamic> foods = decodedJson['foods'];

        setState(() {
          _foodList = foods
              .map((item) => {
                    'name': item['name'],
                    'unitName': item['unit_name'],
                  })
              .toList();
        });
      } else {
        throw Exception('Không tải được danh sách thực phẩm');
      }
    } catch (error) {
      throw Exception('Lỗi khi tải danh sách thực phẩm: $error');
    }
  }

  // Lấy danh sách nhiệm vụ từ API
  Future<void> _fetchTasks() async {
    final groupId = await _getGroupId();
    final token = await _getAccessToken();
    final url = Uri.parse(
        'http://127.0.0.1:5000/api/shopping/$groupId/task?list_id=${widget.shoppingItem.id}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(response.body);
        final List<dynamic> tasks = decodedJson['tasks'];

        setState(() {
          _taskList = tasks.map((task) {
            final matchedFood = _foodList.firstWhere(
              (food) => food['name'] == task['food_name'],
              orElse: () => {'unitName': ''},
            );
            return TaskItem(
              id: task['id'].toString(),
              foodName: task['food_name'] ?? 'Unknown',
              title: task['food_name'] ?? 'Unknown',
              quanity: task['quantity'].split('.').first,
              unitName: matchedFood['unitName'] ?? '',
              isDone: task['status'] == 'Completed',
            );
          }).toList();
        });
      } else {
        throw Exception('Không tải được danh sách nhiệm vụ');
      }
    } catch (error) {
      throw Exception('Lỗi khi tải danh sách nhiệm vụ: $error');
    }
  }

  // Lấy danh sách người dùng từ API
  Future<void> _fetchUsers() async {
    final groupId = await _getGroupId();
    final token = await _getAccessToken();
    final url = Uri.parse('http://127.0.0.1:5000/api/user/group/$groupId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer $token', // Thêm token vào header Authorization
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(response.body);
        final List<dynamic> members = decodedJson['members'];

        setState(() {
          _userList =
              members.map((member) => member['username'] as String).toList();
        });
      } else {
        throw Exception('Không tải được danh sách người dùng');
      }
    } catch (error) {
      throw Exception('Lỗi khi tải danh sách người dùng: $error');
    }
  }

  void _pickDueDate(BuildContext context) async {
    // Chọn ngày
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    // Nếu người dùng đã chọn ngày, mặc định giờ là 00:00:00
    if (pickedDate != null) {
      setState(() {
        _dueTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          0, // Mặc định giờ là 00
          0, // Mặc định phút là 00
          0, // Mặc định giây là 00
        );
      });
    }
  }

  void _saveShoppingItem() {
    if (_formKey.currentState!.validate()) {
      final shoppingItem = ShoppingItem(
        id: widget.shoppingItem.id,
        name: _nameController.text,
        assignedTo: _selectedUser ?? '', // Lưu tên người dùng đã chọn
        notes: _notesController.text,
        dueTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(_dueTime ?? DateTime.now()),
        nameAssignedTo: _selectedUser ?? '', // Lưu tên người dùng đã chọn
        isDone: widget.shoppingItem.isDone,
        tasks: _taskList,
      );

      Provider.of<ShoppingProvider>(context, listen: false)
          .updateShoppingItem(shoppingItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật mục shopping!')),
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> _showAddTaskDialog() async {
    String? selectedFoodName;
    String? selectedUnitName;
    final quantityController =
        TextEditingController(text: '1'); // Giá trị mặc định là 1

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Thêm nhiệm vụ'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedFoodName,
                    hint: const Text('Chọn thực phẩm'),
                    items: _foodList.map((food) {
                      return DropdownMenuItem<String>(
                        value: food['name'],
                        child: Text(food['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFoodName = value;
                        selectedUnitName = _foodList.firstWhere(
                            (food) => food['name'] == value)['unitName'];
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Thực phẩm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(text: selectedUnitName),
                    enabled: false, // Không cho chỉnh sửa
                    decoration: const InputDecoration(
                      labelText: 'Đơn vị',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Số lượng',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.delete), // Icon delete
                        label: const Text('Hủy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Nền đỏ
                          foregroundColor: Colors.white, // Chữ trắng
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Khoảng cách giữa 2 nút
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (selectedFoodName != null &&
                              quantityController.text.isNotEmpty) {
                            setState(() {
                              _taskList.add(TaskItem(
                                id: DateTime.now().toString(),
                                foodName: selectedFoodName!,
                                title: selectedFoodName!,
                                quanity: quantityController.text,
                                unitName: selectedUnitName ?? '',
                                isDone: false,
                              ));
                            });

                            // Đảm bảo giao diện chính cập nhật
                            this.setState(() {});
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Vui lòng chọn thực phẩm và nhập số lượng'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add), // Icon cộng
                        label: const Text('Thêm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Nền xanh
                          foregroundColor: Colors.white, // Chữ trắng
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shoppingItem.name);
    _assignedToController =
        TextEditingController(text: widget.shoppingItem.assignedTo);
    _notesController = TextEditingController(text: widget.shoppingItem.notes);
    _selectedUser = widget.shoppingItem.nameAssignedTo;
    _dueTime =
        DateFormat('EEE, dd MMM yyyy').parse(widget.shoppingItem.dueTime, true);
    _fetchFoodList();
    _fetchUsers();
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa mục shopping',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
                    labelText: 'Tên mục',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tên mục không được để trống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUser,
                  hint: const Text('Chọn người giao'),
                  items: _userList.map((user) {
                    return DropdownMenuItem<String>(
                      value: user,
                      child: Text(user),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUser = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Giao cho',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Thời hạn'),
                  subtitle: Text(
                    _dueTime != null
                        ? DateFormat('yyyy-MM-dd').format(_dueTime!)
                        : 'Chưa chọn',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDueDate(context),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Danh sách nhiệm vụ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _taskList.map((task) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text(
                            'Số lượng: ${task.quanity} | Đơn vị: ${task.unitName}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditTaskDialog(
                                    task); // Gọi phương thức chỉnh sửa khi nhấn nút sửa
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _taskList.remove(task);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showAddTaskDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Thêm nhiệm vụ',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveShoppingItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Cập nhật',
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditTaskDialog(TaskItem task) async {
    String? selectedFoodName = task.foodName;
    String? selectedUnitName = task.unitName;
    final quantityController = TextEditingController(text: task.quanity);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Chỉnh sửa nhiệm vụ'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedFoodName,
                    hint: const Text('Chọn thực phẩm'),
                    items: _foodList.map((food) {
                      return DropdownMenuItem<String>(
                        value: food['name'],
                        child: Text(food['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFoodName = value;
                        selectedUnitName = _foodList.firstWhere(
                            (food) => food['name'] == value)['unitName'];
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Thực phẩm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(text: selectedUnitName),
                    enabled: false, // Không cho chỉnh sửa
                    decoration: const InputDecoration(
                      labelText: 'Đơn vị',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Số lượng',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.delete), // Icon delete
                        label: const Text('Hủy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Nền đỏ
                          foregroundColor: Colors.white, // Chữ trắng
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Khoảng cách giữa 2 nút
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (selectedFoodName != null &&
                              quantityController.text.isNotEmpty) {
                            setState(() {
                              task.foodName = selectedFoodName!;
                              task.unitName = selectedUnitName ?? '';
                              task.quanity = quantityController.text;
                            });

                            // Đảm bảo giao diện chính cập nhật
                            this.setState(() {});
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Vui lòng chọn thực phẩm và nhập số lượng'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save), // Icon save
                        label: const Text('Lưu chỉnh sửa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Nền xanh
                          foregroundColor: Colors.white, // Chữ trắng
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
