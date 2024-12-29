import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/meal_planning_provider.dart';
import '../../Models/meal_plan/meal_plan_model.dart';
import '../../Models/meal_plan/dish_model.dart';

class AddMealScreen extends StatefulWidget {
  final String groupId;
  const AddMealScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  final List<Dish> _dishes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        centerTitle: true,
        title: const Text('Thêm Bữa Ăn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên bữa ăn
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên bữa ăn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Mô tả bữa ăn
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Chọn thời gian bữa ăn
            Row(
              children: [
                Text(
                  'Thời gian: ${_selectedTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
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
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = DateTime(
                          _selectedTime.year,
                          _selectedTime.month,
                          _selectedTime.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  },
                  child: const Text('Chọn thời gian', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Thêm món ăn mới
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              onPressed: _addDish,
              child: const Text('Thêm món ăn'),
            ),
            const SizedBox(height: 16),

            // Danh sách món ăn đã thêm
            Expanded(
              child: ListView.builder(
                itemCount: _dishes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(_dishes[index].recipeName),
                      subtitle: Text('Số phần: ${_dishes[index].servings}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeDish(index),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Lưu bữa ăn
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              onPressed: _submitMealPlan,
              child: const Text('Lưu bữa ăn'),
            ),
          ],
        ),
      ),
    );
  }

  void _addDish() {
    // Gọi API để lấy danh sách món ăn
    showDialog(
      context: context,
      builder: (context) {
        final _servingsController = TextEditingController();
        Dish? selectedDish;
        List<Dish> dishesList = [];
        bool isLoading = true;

        // Gọi API lấy danh sách món ăn
        Future<void> fetchDishes() async {
          try {
            final provider = Provider.of<MealPlanProvider>(context, listen: false);
            dishesList = await provider.fetchAllRecipes(widget.groupId);
          } catch (e) {
            print('Error fetching dishes: $e');
          } finally {
            setState(() {
              isLoading = false; // Cập nhật đúng trạng thái trong dialog
            });
          }
        }

        // Gọi hàm fetch ngay khi dialog được tạo
        fetchDishes();

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Thêm món ăn'),
              content: isLoading
                  ? const Center(child: CircularProgressIndicator()) // Hiển thị khi loading
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<Dish>(
                          decoration: const InputDecoration(
                            labelText: 'Chọn món ăn',
                            border: OutlineInputBorder(),
                          ),
                          items: dishesList.map((dish) {
                            return DropdownMenuItem<Dish>(
                              value: dish,
                              child: Text(dish.recipeName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            dialogSetState(() {
                              selectedDish = value;
                            });
                          },
                          value: selectedDish,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _servingsController,
                          decoration: const InputDecoration(
                            labelText: 'Số phần',
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
                    if (selectedDish == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn món ăn')),
                      );
                      return;
                    }

                    final servings =
                        double.tryParse(_servingsController.text) ?? 1;

                    setState(() {
                      _dishes.add(Dish(
                        recipeId: selectedDish!.recipeId,
                        recipeName: selectedDish!.recipeName,
                        servings: servings,
                      ));
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Thêm món ăn'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // Xóa món ăn khỏi danh sách
  void _removeDish(int index) {
    setState(() {
      _dishes.removeAt(index);
    });
  }

  // Lưu bữa ăn và gửi tới API
  void _submitMealPlan() async {
    if (_nameController.text.isEmpty || _dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final newMealPlan = MealPlanModel(
      id: DateTime.now().toString(),
      name: _nameController.text,
      scheduleTime: _selectedTime,
      description: _descriptionController.text,
      dishes: _dishes,
    );

    try {
      final provider = Provider.of<MealPlanProvider>(context, listen: false);
      await provider.addMealPlan(newMealPlan,widget.groupId );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm bữa ăn')),
      );
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi khi thêm bữa ăn')),
      );
    }
  }
}
