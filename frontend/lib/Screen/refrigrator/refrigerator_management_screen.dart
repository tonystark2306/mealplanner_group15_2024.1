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
    extends State<RefrigeratorManagementScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    try {
      await Provider.of<RefrigeratorProvider>(context, listen: false)
          .loadFoodItemsFromApi('572ac983-195b-4029-803d-fb26e5a86b9b');
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
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
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Center(
          child: Text(
            'Tủ lạnh',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green[700],
          labelColor: Colors.green[700],
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Còn hạn'),
            Tab(text: 'Hết hạn'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : Consumer<RefrigeratorProvider>(
              builder: (context, refrigeratorProvider, child) {
                final foodItems = refrigeratorProvider.items;
                final now = DateTime.now();

                // Phân loại thực phẩm
                final expiringSoon = foodItems
                    .where((item) =>
                        item.expirationDate.isAfter(now) &&
                        item.expirationDate
                            .isBefore(now.add(const Duration(days: 3))))
                    .toList();

                final validItems = foodItems
                    .where((item) => item.expirationDate.isAfter(now))
                    .toList();

                final expiredItems = foodItems
                    .where((item) => item.expirationDate.isBefore(now))
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFoodList(context, [...expiringSoon, ...validItems]),
                    _buildFoodList(context, expiredItems, isExpired: true),
                  ],
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.green[700],
      ),
    );
  }

  Widget _buildFoodList(BuildContext context, List<FoodItem> foodItems,
      {bool isExpired = false}) {
    if (foodItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            isExpired
                ? 'Không có thực phẩm đã hết hạn'
                : 'Không có thực phẩm còn hạn',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final foodItem = foodItems[index];
        final now = DateTime.now();
        final isExpiringSoon = foodItem.expirationDate
                .isBefore(now.add(const Duration(days: 3))) &&
            foodItem.expirationDate.isAfter(now);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isExpired
              ? Colors.red[50]
              : (isExpiringSoon ? Colors.yellow[50] : Colors.white),
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
              'Số lượng: ${foodItem.quantity}',
              style: TextStyle(
                color: isExpired
                    ? Colors.red[700]
                    : (isExpiringSoon ? Colors.orange[700] : Colors.grey[600]),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey[1000]),
                  onPressed: () {
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
      },
    );
  }

  void _confirmDelete(BuildContext context, FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa thực phẩm này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<RefrigeratorProvider>(context, listen: false)
                    .deleteItemFromApi('group_id', foodItem.id);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa thực phẩm ${foodItem.name}')),
                );
              } catch (error) {
                Navigator.of(ctx).pop();
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
