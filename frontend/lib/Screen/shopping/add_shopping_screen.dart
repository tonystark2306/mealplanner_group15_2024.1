import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Providers/shopping_provider.dart';
import '../../Models/shopping_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Providers/token_storage.dart'; // Import TokenStorage
import '../../../Providers/group_id_provider.dart'; // Import TokenStorage

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
    print(groupId);
    return groupId ?? ''; // Trả về access token
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
      initialDate: DateTime.now(),
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
        id: DateTime.now().toString(),
        name: _nameController.text,
        assignedTo: _selectedUser ?? '', // Lưu tên người dùng đã chọn
        notes: _notesController.text,
        dueTime: DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(_dueTime ?? DateTime.now()),
        nameAssignedTo: _selectedUser ?? '', // Lưu tên người dùng đã chọn
        isDone: false,
        tasks: _taskList,
      );

      Provider.of<ShoppingProvider>(context, listen: false)
          .addShoppingItem(shoppingItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm mục shopping!')),
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
    _fetchFoodList(); // Gọi API khi màn hình được tải
    _fetchUsers(); // Gọi API để tải danh sách người dùng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tạo shopping',
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
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown for selecting user
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
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
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
                            ? 'Hạn: ${_dueTime!.toLocal().toString().split(' ')[0]}' // Hiển thị chỉ ngày, không giờ
                            : 'Chưa chọn hạn',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () =>
                          _pickDueDate(context), // Gọi phương thức chọn ngày
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nhiệm vụ: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    label: const Text('Lưu shopping',
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
