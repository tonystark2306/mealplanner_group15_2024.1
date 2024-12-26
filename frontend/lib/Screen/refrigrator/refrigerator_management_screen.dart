import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/food_item_model.dart';
import '../../Providers/refrigerator_provider.dart';
import './add_food_item_screen.dart';
import './edit_food_item_screen.dart';

class RefrigeratorManagementScreen extends StatefulWidget {
  const RefrigeratorManagementScreen({super.key});

  @override
  _RefrigeratorManagementScreenState createState() =>
      _RefrigeratorManagementScreenState();
}

class _RefrigeratorManagementScreenState
    extends State<RefrigeratorManagementScreen> {
  // Biến để lưu trạng thái tải dữ liệu từ backend
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  // Hàm tải dữ liệu thực phẩm từ API
  Future<void> _loadFoodItems() async {
    try {
      await Provider.of<RefrigeratorProvider>(context, listen: false)
          .loadFoodItemsFromApi(
              '572ac983-195b-4029-803d-fb26e5a86b9b'); // Thay 'group_id' bằng ID nhóm thực tế
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      // Xử lý lỗi nếu có
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải dữ liệu')),
      );
    }
  }

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
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () {
            Navigator.pop(context); // Quay về màn hình trước đó
          },
        ),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : Consumer<RefrigeratorProvider>(
              builder: (context, refrigeratorProvider, child) {
                final foodItems = refrigeratorProvider.items;
                foodItems.sort((a, b) => a.expirationDate
                    .compareTo(b.expirationDate)); // Sắp xếp theo ngày hết hạn

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
                                    return _buildFoodItemTile(
                                        context, foodItem);
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

  // Hiển thị loading indicator khi đang tải dữ liệu
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.green[700],
      ),
    );
  }

  // Hiển thị thông báo nếu tủ lạnh không có thực phẩm
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

  // Hiển thị mỗi món ăn trong danh sách
  Widget _buildFoodItemTile(BuildContext context, FoodItem foodItem) {
    final expirationDate = foodItem.expirationDate;
    final now = DateTime.now();
    final isExpired = expirationDate.isBefore(now);
    final isExpiringSoon =
        expirationDate.isBefore(now.add(const Duration(days: 3))) && !isExpired;

    // Xác định màu nền theo trạng thái
    Color? backgroundColor;
    if (isExpired) {
      backgroundColor = Colors.red[100]; // Hết hạn
    } else if (isExpiringSoon) {
      backgroundColor = Colors.red[50]; // Sắp hết hạn
    } else {
      backgroundColor = Colors.green[50]; // Chưa hết hạn
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: backgroundColor,
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
          'Hết hạn: ${foodItem.expirationDate.toLocal().toString().split(' ')[0]}\n'
          'Số lượng: ${foodItem.quantity}', // Hiển thị thêm số lượng
          style: TextStyle(
            color: isExpired
                ? Colors.red[700]
                : isExpiringSoon
                    ? Colors.grey[600]
                    : Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue[300]),
              onPressed: () {
                // Chuyển đến màn hình chỉnh sửa thực phẩm
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditFoodItemScreen(foodItem: foodItem),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red[300]),
              onPressed: () {
                _confirmDelete(context, foodItem);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Xác nhận xóa thực phẩm
  void _confirmDelete(BuildContext context, FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa thực phẩm này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Đóng hộp thoại
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // Gọi provider để xóa thực phẩm từ API
              try {
                await Provider.of<RefrigeratorProvider>(context, listen: false)
                    .deleteItemFromApi('group_id',
                        foodItem.id); // Thay 'group_id' bằng ID thực tế
                Navigator.of(ctx).pop(); // Đóng hộp thoại
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa thực phẩm ${foodItem.name}')),
                );
              } catch (error) {
                Navigator.of(ctx).pop(); // Đóng hộp thoại
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lỗi khi xóa thực phẩm')),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
