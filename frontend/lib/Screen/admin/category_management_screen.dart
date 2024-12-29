import 'package:flutter/material.dart';
import 'package:meal_planner_app/Services/add_category_service.dart';
import 'package:meal_planner_app/Services/get_category_service.dart';
import 'package:meal_planner_app/Services/update_category_service.dart';
import 'package:meal_planner_app/Services/delete_category_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<Map<String, dynamic>> categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    setState(() => _isLoading = true);

    final fetchedCategories = await CategoryApiGet.fetchCategories();

    setState(() {
      _isLoading = false;
      categories = fetchedCategories;
    });
  }

  void _addCategory(String name) async {
    setState(() => _isLoading = true);

    final success = await CategoryApiAdd.addCategory(name);

    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        categories.add({'id': categories.length + 1, 'name': name});
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm danh mục thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể thêm danh mục, vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editCategory(String oldName, String newName) async {
    setState(() => _isLoading = true);

    // Debug: Kiểm tra dữ liệu trước khi gọi API
    print("Editing category: {old_name: $oldName, new_name: $newName}");

    final success = await CategoryApiEdit.editCategory(oldName, newName);

    setState(() => _isLoading = false);

    if (success) {
      // Đồng bộ danh sách danh mục sau khi chỉnh sửa
      _loadCategories();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉnh sửa danh mục thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể chỉnh sửa danh mục, vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }




  void _deleteCategory(String name) async {
    setState(() => _isLoading = true);

    final success = await CategoryApiDelete.deleteCategory(name);

    setState(() => _isLoading = false);

    if (success) {
      _loadCategories(); // Cập nhật danh sách danh mục
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa danh mục thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa danh mục, vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeleteCategory(String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa danh mục "$name" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Đóng dialog
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog trước khi xóa
                _deleteCategory(name); // Gọi hàm xóa
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm danh mục mới'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nhập tên danh mục'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addCategory(nameController.text);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(String oldName) {
    final TextEditingController nameController =
        TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa danh mục'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nhập tên mới'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _editCategory(oldName, nameController.text); // Gọi _editCategory
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý danh mục',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  child: ListTile(
                    title: Text(category['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditCategoryDialog(category['name']), // Truyền old_name
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteCategory(category['name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}
