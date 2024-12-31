import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/fridge/fridge_item_model.dart';
import '../../Providers/fridge_provider/refrigerator_provider.dart';
import './add_food_item_screen.dart';
import './edit_food_item_screen.dart';
import './fridge_item_screen.dart';
import '../../Providers/group_id_provider.dart';
import '../app_drawer.dart';

class RefrigeratorManagementScreen extends StatefulWidget {
  const RefrigeratorManagementScreen({super.key});

  @override
  _RefrigeratorManagementScreenState createState() =>
      _RefrigeratorManagementScreenState();
}

class _RefrigeratorManagementScreenState
    extends State<RefrigeratorManagementScreen> {
  String? groupId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFridgeItems();
  }

  Future<void> _loadFridgeItems() async {
    final id = await GroupIdProvider.getSelectedGroupId();
    setState(() {
      groupId = id;
    });

    try {
      await Provider.of<RefrigeratorProvider>(context, listen: false)
          .loadFridgeItemsFromApi(groupId!);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
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
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green[700], // Màu xanh cho AppBar
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tủ lạnh',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Mở Drawer
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddFridgeItemScreen(
                          groupId: groupId!,
                        )),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : Consumer<RefrigeratorProvider>(
              builder: (context, refrigeratorProvider, child) {
                final fridgeItems = refrigeratorProvider.items;
                fridgeItems.sort(
                    (a, b) => a.expirationDate.compareTo(b.expirationDate));

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fridgeItems.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: fridgeItems.length,
                          itemBuilder: (context, index) {
                            final fridgeItem = fridgeItems[index];
                            return _buildFridgeItemTile(context, fridgeItem);
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.green[700],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag,
              size: 50,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có thực phẩm trong tủ lạnh',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm thực phẩm mới bằng cách nhấn vào nút + ở góc phải',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFridgeItemTile(BuildContext context, FridgeItem fridgeItem) {
    final expirationDate = fridgeItem.expirationDate;
    final now = DateTime.now();
    final isExpired = expirationDate.isBefore(now);
    final isExpiringSoon =
        expirationDate.isBefore(now.add(Duration(days: 3))) && !isExpired;

    // Color? backgroundColor;
    // if (isExpired) {
    //   backgroundColor = Colors.red[50];
    // } else if (isExpiringSoon) {
    //   backgroundColor = Colors.white;
    // } else {
    //   backgroundColor = Colors.white;
    // }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.white,
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
                  child:
                      Icon(Icons.food_bank, color: Colors.green[700], size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fridgeItem.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
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
                          builder: (context) => EditFridgeItemScreen(
                              groupId: groupId!, fridgeItem: fridgeItem),
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
                            FridgeItemDetailScreen(fridgeItem: fridgeItem),
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

  void _confirmDelete(BuildContext context, FridgeItem fridgeItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thực phẩm này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Provider.of<RefrigeratorProvider>(context, listen: false)
                    .deleteItemFromApi(groupId!, fridgeItem.id);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Đã xóa thực phẩm ${fridgeItem.name}')),
                );
              } catch (error) {
                Navigator.of(ctx).pop();
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
