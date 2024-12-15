import 'package:flutter/material.dart';
import '../../Models/food_item_model.dart';
import '../../Providers/refrigerator_provider.dart';
import 'package:provider/provider.dart';
import './add_food_item_screen.dart'; // Adjust the path as necessary

class RefrigeratorManagementScreen extends StatelessWidget {
  const RefrigeratorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Quản lý tủ lạnh',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () {
            Navigator.pop(context); // Quay về màn hình trước đó
          },
        ),
      ),
      body: Consumer<RefrigeratorProvider>(
        builder: (context, refrigeratorProvider, child) {
          final foodItems = refrigeratorProvider.getFoodItems();
          foodItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate)); // Sắp xếp theo ngày hết hạn

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.kitchen, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Danh sách thực phẩm',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (foodItems.isEmpty)
                          _buildEmptyState()
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: foodItems.length,
                            itemBuilder: (context, index) {
                              final foodItem = foodItems[index];
                              return _buildFoodItemTile(context, foodItem);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFoodItemScreen()),
          );
        },

        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Chưa có thực phẩm nào trong tủ lạnh',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  
  Widget _buildFoodItemTile(BuildContext context, FoodItem foodItem) {
    final expiryDate = foodItem.expiryDate;
    final isExpiringSoon = foodItem.expiryDate.isBefore(DateTime.now().add(Duration(days: 3)));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isExpiringSoon ? Colors.red[50] : Colors.white,  // Thêm màu đỏ nếu sắp hết hạn
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[50],
          child: Icon(Icons.food_bank, color: Colors.green[700]),
        ),
        title: Text(
          foodItem.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Hết hạn: ${foodItem.expiryDate.toLocal().toString().split(' ')[0]}',
          style: TextStyle(color: isExpiringSoon ? Colors.red[700] : Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red[300]),
          onPressed: () {
            _confirmDelete(context, foodItem);
          },
        ),
      ),
    );
  }
  void _confirmDelete(BuildContext context, FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thực phẩm này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Đóng hộp thoại
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Gọi provider để xóa thực phẩm
              Provider.of<RefrigeratorProvider>(context, listen: false)
                  .deleteFoodItem(foodItem);
              Navigator.of(ctx).pop(); // Đóng hộp thoại
              // Hiển thị SnackBar sau khi xóa
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa thực phẩm ${foodItem.name}')),
              );
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }

}