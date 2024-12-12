// meal_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/meal_planning_provider.dart';

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({Key? key}) : super(key: key);

  @override
  _MealPlanningScreenState createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  DateTime selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanningProvider = Provider.of<MealPlanningProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch bữa ăn'),
      ),
      body: Column(
        children: [
          // Phần trên cùng: Chọn ngày
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Chọn ngày'),
                ),
              ],
            ),
          ),

          // Kế hoạch bữa sáng
          Expanded(
            child: MealPlanSection(
              title: 'Kế hoạch bữa sáng',
              meals: mealPlanningProvider.getMealsForDateAndType(selectedDate, 'breakfast'),
              onEdit: () {
                Navigator.pushNamed(context, '/edit-meal-plan',
                    arguments: {
                      'mealType': 'breakfast',
                      'date': selectedDate,
                      'meals': mealPlanningProvider.getMealsForDateAndType(selectedDate, 'breakfast'),
                    });
              },
            ),
          ),

          // Kế hoạch bữa trưa
          Expanded(
            child: MealPlanSection(
              title: 'Kế hoạch bữa trưa',
              meals: mealPlanningProvider.getMealsForDateAndType(selectedDate, 'lunch'),
              onEdit: () {
                Navigator.pushNamed(context, '/edit-meal-plan',
                    arguments: {
                      'mealType': 'lunch',
                      'date': selectedDate,
                      'meals': mealPlanningProvider.getMealsForDateAndType(selectedDate, 'lunch'),
                    });
              },
            ),
          ),

          // Kế hoạch bữa tối
          Expanded(
            child: MealPlanSection(
              title: 'Kế hoạch bữa tối',
              meals: mealPlanningProvider.getMealsForDateAndType(selectedDate, 'dinner'),
              onEdit: () {
                Navigator.pushNamed(context, '/edit-meal-plan',
                    arguments: {
                      'mealType': 'dinner',
                      'date': selectedDate,
                      'meals': mealPlanningProvider.getMealsForDateAndType(selectedDate, 'dinner'),
                    });
              },
            ),
          ),

          // Thêm bữa phụ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit-meal-plan',
                    arguments: {
                      'mealType': 'snack',
                      'date': selectedDate,
                      'meals': mealPlanningProvider.getMealsForDateAndType(selectedDate, 'snack'),
                    });
              },
              child: const Text('Thêm bữa phụ'),
            ),
          ),
        ],
      ),
    );
  }
}

class MealPlanSection extends StatelessWidget {
  final String title;
  final List<String> meals;
  final VoidCallback onEdit;

  const MealPlanSection({
    Key? key,
    required this.title,
    required this.meals,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Danh sách món dự kiến:'),
            const SizedBox(height: 8),
            meals.isEmpty
                ? const Text('Hiện tại chưa có món nào!')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meals
                        .map((meal) => Text('- $meal'))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
