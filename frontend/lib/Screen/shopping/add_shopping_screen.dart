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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Tạo Đơn Mua Sắm Mới',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Hướng dẫn'),
                  content: Text('Điền thông tin chi tiết về đơn mua sắm của bạn. Đảm bảo thêm đầy đủ các mặt hàng cần mua.'),
                  actions: [
                    TextButton(
                      child: Text('Đã hiểu'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.grey[100]!],
            stops: [0.0, 0.3],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin cơ bản',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tiêu đề',
                              prefixIcon: Icon(Icons.shopping_cart, color: Colors.green[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập tiêu đề';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedUser,
                            decoration: InputDecoration(
                              labelText: 'Người thực hiện',
                              prefixIcon: Icon(Icons.person, color: Colors.green[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: _userList.map((user) {
                              return DropdownMenuItem(
                                value: user,
                                child: Text(user),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUser = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chi tiết bổ sung',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Ghi chú',
                              prefixIcon: Icon(Icons.note, color: Colors.green[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          InkWell(
                            onTap: () => _pickDueDate(context),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.green[700]),
                                  SizedBox(width: 16),
                                  Text(
                                    _dueTime != null
                                        ? DateFormat('dd/MM/yyyy').format(_dueTime!)
                                        : 'Chọn ngày hết hạn',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Danh sách mua sắm',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle, color: Colors.green[700]),
                                onPressed: _showAddTaskDialog,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ..._taskList.map((task) => Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.shopping_basket, color: Colors.green[700]),
                                  title: Text(task.title),
                                  subtitle: Text('${task.quanity} ${task.unitName}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditTaskDialog(task),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _taskList.remove(task);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveShoppingItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Lưu đơn mua sắm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
