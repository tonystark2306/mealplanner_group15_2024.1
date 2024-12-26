import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/fridge_item_model.dart';
import '../../Providers/refrigerator_provider.dart';
import './add_food_item_screen.dart';
import './edit_food_item_screen.dart';
import './fridge_item_screen.dart';

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
    _loadFridgeItems();
  }

  // Hàm tải dữ liệu thực phẩm từ API
  Future<void> _loadFridgeItems() async {
    try {
      await Provider.of<RefrigeratorProvider>(context, listen: false)
          .loadFridgeItemsFromApi(
              'a05ac307-ae58-47cb-9c0d-d90e8bf2fd36'); // Thay 'group_id' bằng ID nhóm thực tế
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      // Xử lý lỗi nếu có
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu')),
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
        centerTitle: true,
        title: Text(
          'Quản lý tủ lạnh',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : Consumer<RefrigeratorProvider>(
              builder: (context, refrigeratorProvider, child) {
                final fridgeItems = refrigeratorProvider.items;
                fridgeItems.sort((a, b) => a.expirationDate
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
                              if (fridgeItems.isEmpty)
                                _buildEmptyState()
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: fridgeItems.length,
                                  itemBuilder: (context, index) {
                                    final fridgeItem = fridgeItems[index];
                                    return _buildFridgeItemTile(
                                        context, fridgeItem);
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
            MaterialPageRoute(
                builder: (context) => const AddFridgeItemScreen()),
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
  Widget _buildFridgeItemTile(BuildContext context, FridgeItem fridgeItem) {
    final expirationDate = fridgeItem.expirationDate;
    final now = DateTime.now();
    final isExpired = expirationDate.isBefore(now);
    final isExpiringSoon =
        expirationDate.isBefore(now.add(Duration(days: 3))) && !isExpired;

    // Xác định màu nền theo trạng thái
    Color? backgroundColor;
    if (isExpired) {
      backgroundColor = Colors.red[50]; // Hết hạn
    } else if (isExpiringSoon) {
      backgroundColor = Colors.white; // Sắp hết hạn
    } else {
      backgroundColor = Colors.white; // Chưa hết hạn
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.green[50],
                  child: Icon(Icons.food_bank, color: Colors.green[700], size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fridgeItem.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: isExpired
                                ? Colors.red
                                : isExpiringSoon
                                    ? Colors.orange
                                    : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hết hạn: ${fridgeItem.expirationDate.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isExpired
                                  ? Colors.red
                                  : isExpiringSoon
                                      ? Colors.orange
                                      : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditFridgeItemScreen(fridgeItem: fridgeItem),
                        ),
                      );
                    } else if (value == 'delete') {
                      _confirmDelete(context, fridgeItem);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Chỉnh sửa'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Xóa'),
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.storage, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  'Số lượng: ${fridgeItem.quantity}',
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
              ],
            ),
            const Divider(height: 16, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FridgeItemDetailScreen(fridgeItemId: fridgeItem.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info),
                  label: const Text('Xem chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  // Xác nhận xóa thực phẩm
  void _confirmDelete(BuildContext context, FridgeItem fridgeItem) {
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
            onPressed: () async {
              // Gọi provider để xóa thực phẩm từ API
              try {
                Provider.of<RefrigeratorProvider>(context, listen: false)
                    .removeItem(fridgeItem.id);
                Navigator.of(ctx).pop(); // Đóng hộp thoại
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Đã xóa thực phẩm ${fridgeItem.name}')),
                );
              } catch (error) {
                Navigator.of(ctx).pop(); // Đóng hộp thoại
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi xóa thực phẩm')),
                );
              }
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
