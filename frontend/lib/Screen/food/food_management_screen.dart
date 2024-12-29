import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/food_provider.dart';
import 'add_food_screen.dart';

class FoodListScreen extends StatefulWidget {
  FoodListScreen({Key? key}) : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final String groupId = "1366e289-e787-459f-896e-5c2a5df5c69f";

  @override
  void initState() {
    super.initState();
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    foodProvider.fetchFoods(groupId); // Fetch data
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
                        leading: food['image_url'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8), // Bo tròn hình ảnh
                                child: Image.network(
                                        food['image_url'], // Đảm bảo URL là một chuỗi hợp lệ
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                              )
                            : const Icon(Icons.fastfood, size: 50, color: Colors.green),
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
                              Text("Đơn vị: ${food['unit'] ?? 'Không xác định'}"),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black), // Nút chỉnh sửa màu đen
                              onPressed: () {
                                // Chuyển đến màn hình chỉnh sửa
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red), // Nút xóa màu đỏ
                              onPressed: () {
                                // Xử lý xóa thực phẩm
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
              builder: (_) => AddFoodScreen(groupId: groupId),
            ),
          );
        },
        backgroundColor: Colors.green, // Nút thêm thực phẩm màu xanh lá
        child: const Icon(Icons.add),
      ),
    );
  }
}
