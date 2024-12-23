import 'package:flutter/material.dart';

class UnitsManagementScreen extends StatefulWidget {
  const UnitsManagementScreen({super.key});

  @override
  _UnitsManagementScreenState createState() => _UnitsManagementScreenState();
}

class _UnitsManagementScreenState extends State<UnitsManagementScreen> {
  final List<String> _units = [
    'kg',
    'g',
    'l',
    'ml'
  ]; // Danh sách đơn vị đo lường
  final TextEditingController _unitController = TextEditingController();

  void _addUnit() {
    if (_unitController.text.isNotEmpty) {
      if (_units.contains(_unitController.text)) {
        // Show a message if the unit already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đơn vị đã tồn tại!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          _units.add(_unitController.text);
        });
        _unitController.clear();
      }
    }
  }

  void _editUnit(int index) {
    _unitController.text = _units[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa đơn vị đo lường'),
        content: TextField(
          controller: _unitController,
          decoration: const InputDecoration(hintText: 'Nhập đơn vị đo lường'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _units[index] = _unitController.text;
              });
              _unitController.clear();
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUnit(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc chắn muốn xoá đơn vị này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without deleting
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _units.removeAt(index);
              });
              Navigator.pop(context); // Close the dialog after deletion
            },
            child: const Text('Xoá'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý đơn vị đo lường',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay về màn hình trước đó
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
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
                      child: const Icon(
                        Icons.add,
                        color: Colors.white, // White color for the icon
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(50, 56), // Set a height for the button to match the TextField height
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
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editUnit(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
