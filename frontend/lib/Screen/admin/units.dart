import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Providers/token_storage.dart'; // Import TokenStorage
class UnitsManagementScreen extends StatefulWidget {
  const UnitsManagementScreen({super.key});

  @override
  _UnitsManagementScreenState createState() => _UnitsManagementScreenState();
}

class _UnitsManagementScreenState extends State<UnitsManagementScreen> {
  final List<String> _units = [];
  final TextEditingController _unitController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

    Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? ''; // Trả về access token
  }

  Future<void> _fetchUnits() async {
    try {
      final accessToken = await _getAccessToken();
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/admin/unit'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Extract the list of units
        final List<dynamic> fetchedUnits = data['units'];

        // Map the list to extract 'name' field
        setState(() {
          _units.clear();
          _units.addAll(fetchedUnits.map((unit) => unit['name'].toString()));
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid access token');
      } else {
        throw Exception('Failed to load units: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải đơn vị: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addUnit() async {
    if (_unitController.text.isNotEmpty) {
      if (_units.contains(_unitController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đơn vị đã tồn tại!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        try {
          final accessToken = await _getAccessToken();
          final response = await http.post(
            Uri.parse('http://127.0.0.1:5000/api/admin/unit'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({'unitName': _unitController.text}),
          );

          if (response.statusCode == 201) {
            // Decode the response to extract the new unit
            final Map<String, dynamic> createdUnit = json.decode(response.body);
            print(response.body); // Debugging info
            // Add the newly created unit to the UI
            setState(() {
              _units.add(createdUnit['unit']['name']); // Ensure 'name' is the correct key from the API
            });

            _unitController.clear();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thêm đơn vị thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            print(response.body); // Debugging info
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi thêm đơn vị: ${response.statusCode}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi kết nối API: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteUnit(int index) async {
    final String unitName = _units[index];

    // Hiển thị hộp thoại xác nhận trước khi xóa
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa đơn vị "$unitName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        final accessToken = await _getAccessToken();
        // Gửi yêu cầu DELETE đến API với body JSON
        final response = await http.delete(
          Uri.parse('http://127.0.0.1:5000/api/admin/unit'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({'unitName': unitName}),
        );

        if (response.statusCode == 200) {
          setState(() {
            _units.removeAt(index); // Xóa đơn vị khỏi danh sách
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa đơn vị thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa đơn vị: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi kết nối API: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editUnit(int index) async {
    final String oldUnitName = _units[index];
    _unitController.text = oldUnitName;

    // Hiển thị hộp thoại chỉnh sửa đơn vị
    final bool? confirmEdit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa đơn vị'),
        content: TextField(
          controller: _unitController,
          decoration: const InputDecoration(
            labelText: 'Tên đơn vị mới',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );

    if (confirmEdit == true && _unitController.text.isNotEmpty) {
      final String newUnitName = _unitController.text;

      if (oldUnitName != newUnitName) {
        final accessToken = await _getAccessToken();
        try {
          final response = await http.put(
            Uri.parse('http://127.0.0.1:5000/api/admin/unit'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'oldName': oldUnitName,
              'newName': newUnitName,
            }),
          );

          if (response.statusCode == 200) {
            setState(() {
              _units[index] = newUnitName; // Cập nhật tên đơn vị trong danh sách
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật đơn vị thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi cập nhật đơn vị: ${response.statusCode}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi kết nối API: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tên đơn vị không thay đổi!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý đơn vị đo lường',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                labelText: 'Thêm đơn vị đo lường',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addUnit,
                            child: const Icon(Icons.add, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              minimumSize: const Size(50, 56),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _units.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            title: Text(
                              _units[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editUnit(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteUnit(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
