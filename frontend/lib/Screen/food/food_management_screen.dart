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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có thực phẩm nào!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hãy thêm thực phẩm mới bằng cách nhấn nút + bên trên góc phải',
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

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Đổi màu nút back thành trắng
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Danh sách thực phẩm",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddFoodScreen(groupId: groupId!),
                  ),
                );
              },
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green[600]!,
                Colors.green[800]!,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: foodProvider.isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đang tải danh sách...',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : foodProvider.foods.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: foodProvider.foods.length,
                    itemBuilder: (context, index) {
                      final food = foodProvider.foods[index];
                      return Hero(
                        tag: 'food-${food['name']}',
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 8,
                          shadowColor: Colors.green.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              // Hiển thị chi tiết thực phẩm nếu cần
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: food['image_url'] != null &&
                                            food['image_url']!.isNotEmpty
                                        ? Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Image.network(
                                              food['image_url'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                color: Colors.green[50],
                                                child: Icon(
                                                  Icons.restaurant,
                                                  size: 50,
                                                  color: Colors.green[300],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Icon(
                                              Icons.restaurant,
                                              size: 50,
                                              color: Colors.green[300],
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          food['name'] ?? 'Tên không xác định',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(Icons.notes,
                                            food['note'] ?? 'Không có ghi chú'),
                                        const SizedBox(height: 4),
                                        _buildInfoRow(Icons.category,
                                            'Loại: ${food['type'] ?? 'Không xác định'}'),
                                        const SizedBox(height: 4),
                                        _buildInfoRow(Icons.straighten,
                                            'Đơn vị: ${food['unit_name'] ?? 'Không xác định'}'),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      _buildActionButton(
                                        icon: Icons.edit,
                                        color: Colors.blue,
                                        onPressed: () {
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
                                      const SizedBox(height: 8),
                                      _buildActionButton(
                                        icon: Icons.delete,
                                        color: Colors.red,
                                        onPressed: () async {
                                          final confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              title:
                                                  const Text("Xóa thực phẩm"),
                                              content: const Text(
                                                  "Bạn có chắc muốn xóa thực phẩm này không?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text("Hủy"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text("Xóa",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await foodProvider.deleteFood(
                                                  groupId!, food['name']);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Xóa thực phẩm thành công!"),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Xóa thất bại: thực phẩm đang được sử dụng"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      // Remove the FloatingActionButton since we moved the add button to AppBar
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}
