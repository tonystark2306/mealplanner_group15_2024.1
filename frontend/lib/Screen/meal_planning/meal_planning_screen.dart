import 'package:flutter/material.dart';
import './add_meal_plan_screen.dart';
import 'package:provider/provider.dart';
import '../../Providers/meal_planning_provider.dart';
import '../../Models/meal_plan_model.dart';

class MealPlanManagementScreen extends StatefulWidget {
  const MealPlanManagementScreen({Key? key}) : super(key: key);
  @override
  _MealPlanManagementScreenState createState() =>
      _MealPlanManagementScreenState();
}

class _MealPlanManagementScreenState extends State<MealPlanManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  final String groupId = "a05ac307-ae58-47cb-9c0d-d90e8bf2fd36";
  final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQ1MDFhZDgtNWE0ZS00OTI5LWE3YzItYjhhMjU1OTU2NDE1IiwiZXhwIjoxNzM1MjY1Mjk1fQ.dPCZzsbJBS0oO-ky5NajGn1vRMNmllzVT6p7_vZJ92w";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ gọi _fetchMealPlans() sau khi BuildContext sẵn sàng
    _fetchMealPlans();
  }

  Future<void> _fetchMealPlans() async {
    
    final provider = Provider.of<MealPlanProvider>(context, listen: false);
    
    // Hiển thị thông báo "Đang tải"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang tải bữa ăn...')),
    );

    try {
      await provider.fetchMealPlansByDate(_selectedDate, groupId, token);
      // Sau khi tải thành công, thông báo "Tải dữ liệu thành công"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tải dữ liệu thành công!')),
      );
    } catch (error) {
      // Nếu có lỗi, thông báo "Lỗi khi tải dữ liệu"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealPlans = Provider.of<MealPlanProvider>(context).mealPlans;
    final isLoading = Provider.of<MealPlanProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        centerTitle: true,
        title: const Text(
          'Kế hoạch bữa ăn',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? _buildLoadingIndicator()
          : RefreshIndicator(
              onRefresh: _fetchMealPlans,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    mealPlans.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Chưa có bữa ăn nào trong ngày',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          )
                        : _buildMealList(mealPlans),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddMealScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(color: Colors.green[700]),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        Text(
          'Ngày: ${_selectedDate.toLocal().toString().split(' ')[0]}',
          style: TextStyle(fontSize: 16, color: Colors.green[700]),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null && pickedDate != _selectedDate) {
              setState(() {
                _selectedDate = pickedDate;
              });
              await _fetchMealPlans();
            }
          },
          child: const Text('Chọn ngày', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildMealList(List<MealPlanModel> mealPlans) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mealPlans.length,
      itemBuilder: (context, index) {
        final meal = mealPlans[index];
        return _buildMealTile(meal);
      },
    );
  }

  Widget _buildMealTile(MealPlanModel meal) {
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
                  child: Icon(Icons.restaurant_menu,
                      color: Colors.green[700], size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            meal.scheduleTime.toLocal().toString().split(' ')[1],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.pushNamed(context, '/edit-meal');
                    } else if (value == 'delete') {
                      await _deleteMeal(context, meal.id);
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
            const Divider(height: 16, thickness: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: meal.dishes
                  .map((dish) => Text(
                        '${dish.recipeName} - ${dish.servings} phần',
                        style: const TextStyle(fontSize: 14),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMeal(BuildContext context, String mealId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bữa ăn này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      Provider.of<MealPlanProvider>(context, listen: false)
          // .deleteMealPlan(mealId, token);
          .deleteMealPlanState(mealId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bữa ăn')),
      );
    }
  }
}
