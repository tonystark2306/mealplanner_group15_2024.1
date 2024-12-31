import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/meal_planning_provider.dart';
import '../../Models/meal_plan/meal_plan_model.dart';
import '../../Models/meal_plan/dish_model.dart';

class AddMealPlanScreen extends StatefulWidget {
  final String groupId;

  const AddMealPlanScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AddMealPlanScreen> createState() => _AddMealPlanScreenState();
}

class _AddMealPlanScreenState extends State<AddMealPlanScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  final List<Dish> _selectedDishes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Kế Hoạch Bữa Ăn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 6.0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Tên Bữa Ăn',
              hintText: 'Nhập tên bữa ăn',
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Mô Tả',
              hintText: 'Mô tả bữa ăn (không bắt buộc)',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  'Thời gian: ${_selectedTime.toLocal().toString().substring(11, 16)}',
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text('Chọn Thời Gian', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _addDish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text('Thêm Món Ăn', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),

            _selectedDishes.isEmpty
                ? const Text('Chưa có món ăn nào được thêm.', style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _selectedDishes.length,
                    itemBuilder: (context, index) {
                      final dish = _selectedDishes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.green.withOpacity(0.2)),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          title: Text(
                            dish.recipeName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Khẩu phần: ${dish.servings}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() {
                              _selectedDishes.removeAt(index);
                            }),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _submitMealPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text('Lưu Kế Hoạch', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.green),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
      maxLines: maxLines,
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _addDish() async {
    final provider = Provider.of<MealPlanProvider>(context, listen: false);
    try {
      final dishes = await provider.fetchAllRecipes(widget.groupId);
      Dish? selectedDish;
      final servingsController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Thêm Món Ăn'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Dish>(
                  items: dishes.map((dish) {
                    return DropdownMenuItem<Dish>(
                      value: dish,
                      child: Text(dish.recipeName),
                    );
                  }).toList(),
                  onChanged: (value) => selectedDish = value,
                  decoration: const InputDecoration(
                    labelText: 'Chọn Món',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: servingsController,
                  decoration: const InputDecoration(
                    labelText: 'Khẩu Phần',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedDish != null && servingsController.text.isNotEmpty) {
                    setState(() {
                      _selectedDishes.add(Dish(
                        recipeId: selectedDish!.recipeId,
                        recipeName: selectedDish!.recipeName,
                        servings: double.parse(servingsController.text),
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _submitMealPlan() async {
    if (_nameController.text.isEmpty || _selectedDishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng hoàn thành tất cả các trường.')),
      );
      return;
    }

    final mealPlan = MealPlanModel(
      id: DateTime.now().toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      scheduleTime: _selectedTime,
      dishes: _selectedDishes,
    );

    final provider = Provider.of<MealPlanProvider>(context, listen: false);
    try {
      await provider.addMealPlan(mealPlan, widget.groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm Kế Hoạch Bữa Ăn Thành Công')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}
