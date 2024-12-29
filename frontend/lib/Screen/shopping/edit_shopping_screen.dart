import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Providers/shopping_provider.dart';
import '../../Models/shopping_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Providers/token_storage.dart'; // Import TokenStorage
import '../../../Providers/group_id_provider.dart'; // Import TokenStorage

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
        dueTime: DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(_dueTime ?? DateTime.now()),
        nameAssignedTo: _selectedUser ?? '', // Lưu tên người dùng đã chọn
        isDone: widget.shoppingItem.isDone,
        tasks: _taskList,
      );

      Provider.of<ShoppingProvider>(context, listen: false)
          .updateShoppingItem(shoppingItem.id, shoppingItem);

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
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
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
                          content:
                              Text('Vui lòng chọn thực phẩm và nhập số lượng'),
                        ),
                      );
                    }
                  },
                  child: const Text('Thêm nhiệm vụ'),
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

    // Điền sẵn giá trị của mục shopping đã chọn
    _nameController = TextEditingController(text: widget.shoppingItem.name);
    _assignedToController =
        TextEditingController(text: widget.shoppingItem.nameAssignedTo);
    _notesController = TextEditingController(text: widget.shoppingItem.notes);
    // = DateTime.parse(widget.shoppingItem.dueTime);
    _selectedUser = widget.shoppingItem.nameAssignedTo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa shopping',
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
                // Render các task từ taskList
                Column(
                  children: _taskList.map((task) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text(
                            'Số lượng: ${task.quanity}, Đơn vị: ${task.unitName}'),
                        trailing: Checkbox(
                          value: task.isDone,
                          onChanged: (value) {
                            setState(() {
                              task.isDone = value!;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showAddTaskDialog,
                  child: const Text('Thêm nhiệm vụ'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveShoppingItem,
                    child: const Text('Lưu'),
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
