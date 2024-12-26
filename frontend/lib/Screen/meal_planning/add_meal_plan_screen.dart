import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/meal_planning_provider.dart';
import '../../Models/meal_plan_model.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({Key? key}) : super(key: key);

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQ1MDFhZDgtNWE0ZS00OTI5LWE3YzItYjhhMjU1OTU2NDE1IiwiZXhwIjoxNzM1MjY1Mjk1fQ.dPCZzsbJBS0oO-ky5NajGn1vRMNmllzVT6p7_vZJ92w";
  final String groupId = "a05ac307-ae58-47cb-9c0d-d90e8bf2fd36";
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  final List<Dish> _dishes = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addDish() {
    showDialog(
      context: context,
      builder: (context) {
        final _recipeNameController = TextEditingController();
        final _servingsController = TextEditingController();

        return AlertDialog(
          title: const Text('Thêm món ăn'),
          content: Column(
            children: [
              TextField(
                controller: _recipeNameController,
                decoration: const InputDecoration(labelText: 'Tên món ăn'),
              ),
              TextField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số phần ăn'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final recipeName = _recipeNameController.text;
                final servings = int.tryParse(_servingsController.text) ?? 1;
                if (recipeName.isNotEmpty) {
                  setState(() {
                    _dishes.add(Dish(
                      recipeId: DateTime.now().toString(),
                      recipeName: recipeName,
                      servings: servings,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Thêm món'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _saveMeal() {
    if (_formKey.currentState?.validate() ?? false) {
      final mealPlan = MealPlanModel(
        id: DateTime.now().toString(),
        name: _nameController.text,
        scheduleTime: _selectedTime,
        description: _descriptionController.text,
        dishes: _dishes,
      );

      // Lưu thông tin bữa ăn vào provider hoặc backend (API)
      Provider.of<MealPlanProvider>(context, listen: false).addMealPlan(mealPlan, token, groupId);
      Navigator.of(context).pop(); // Quay lại màn hình trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm bữa ăn'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên bữa ăn'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên bữa ăn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Thời gian: ${_selectedTime.toLocal().toString().split(' ')[1]}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedTime) {
                        setState(() {
                          _selectedTime = pickedDate;
                        });
                      }
                    },
                    child: const Text('Chọn thời gian'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _dishes.isEmpty
                  ? const Text('Chưa có món ăn nào')
                  : Column(
                      children: _dishes
                          .map((dish) => ListTile(
                                title: Text(dish.recipeName),
                                subtitle: Text('Số phần: ${dish.servings}'),
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addDish,
                child: const Text('Thêm món ăn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  child: const Text('Lưu bữa ăn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
