import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/food_provider.dart';
import 'add_food_screen.dart';
import 'edit_food_screen.dart';
import '../../Providers/group_id_provider.dart';

class FoodListScreen extends StatefulWidget {
  FoodListScreen({Key? key}) : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String? groupId;

  @override
  void initState() {
    super.initState();
    _loadGroupIdAndFetchFoods();
  }

  Future<void> _loadGroupIdAndFetchFoods() async {
    final id = await GroupIdProvider.getSelectedGroupId();
    setState(() {
      groupId = id;
    });
    if (groupId != null) {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      await foodProvider.fetchFoods(groupId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách thực phẩm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green, // Thay màu app bar sang xanh lá
      ),
      body: foodProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : foodProvider.foods.isEmpty
              ? const Center(
                  child: Text(
                    "Không có thực phẩm nào!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: foodProvider.foods.length,
                  itemBuilder: (context, index) {
                    final food = foodProvider.foods[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5, // Độ đậm cho shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Viền bo tròn
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: food['image_url'] != null && food['image_url']!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  food['image_url'], // Đường dẫn ảnh
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 60, color: Colors.grey), // Xử lý lỗi tải ảnh
                                ),
                              )
                            : Icon(Icons.fastfood, size: 50, color: Colors.green), // Icon thay thế nếu không có ảnh

                        title: Text(
                          food['name'] ?? 'Tên không xác định',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, // Màu chữ tối để dễ đọc
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ghi chú: ${food['note'] ?? 'Không có'}"),
                              Text("Loại: ${food['type'] ?? 'Không xác định'}"),
                              Text("Đơn vị: ${food['unit_name'] ?? 'Không xác định'}"),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                // Chuyển đến màn hình chỉnh sửa thực phẩm
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditFoodScreen(
                                      groupId: groupId!,
                                      food: food,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red), // Nút xóa màu đỏ
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Xóa thực phẩm"),
                                    content: const Text("Bạn có chắc muốn xóa thực phẩm này không?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("Hủy"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    await foodProvider.deleteFood(groupId!, food['name']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Xóa thành công!")),
                                    );
                                  } catch (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Xóa thất bại: $error")),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Hiển thị chi tiết thực phẩm nếu cần
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddFoodScreen(groupId: groupId!),
            ),
          );
        },
        backgroundColor: Colors.green, // Nút thêm thực phẩm màu xanh lá
        child: const Icon(Icons.add),
      ),
    );
  }
}
