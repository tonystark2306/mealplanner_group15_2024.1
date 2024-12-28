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

  // Thêm món ăn vào danh sách
  void _addDish() {
    // Mở màn hình nhập tên món ăn và khẩu phần
    showDialog(
      context: context,
      builder: (context) {
        final _dishNameController = TextEditingController();
        final _servingsController = TextEditingController();

        return AlertDialog(
          title: const Text('Nhập thông tin món ăn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nhập tên món ăn
              TextField(
                controller: _dishNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên món ăn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              
              // Nhập số phần khẩu phần
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final dishName = _dishNameController.text;
                final servings = double.tryParse(_servingsController.text) ?? 1;

                if (dishName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên món ăn')),
                  );
                  return;
                }

                setState(() {
                  _dishes.add(Dish(
                    recipeId: 'dish_${_dishes.length + 1}',
                    recipeName: dishName,
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
