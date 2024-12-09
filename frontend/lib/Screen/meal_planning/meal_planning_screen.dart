import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/meal_planning_provider.dart';
import 'package:intl/intl.dart';
import '../../Models/meal_plan_model.dart';

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  _MealPlanningScreenState createState() => _MealPlanningScreenState();
}

void _navigateToAddMealPlan(BuildContext context, DateTime selectedDate) {
  Navigator.pushNamed(context, '/add-meal-plan', arguments: selectedDate);
}


class _MealPlanningScreenState extends State<MealPlanningScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final mealPlans = Provider.of<MealPlanningProvider>(context).getMealPlansByDate(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Kế hoạch bữa ăn',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatePicker(),
          const SizedBox(height: 20),
          if (mealPlans.isEmpty)
            Column(
              children: [
                Center(child: Text('Không có kế hoạch bữa ăn cho ngày này')),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _navigateToAddMealPlan(context, _selectedDate); // Điều hướng để thêm bữa ăn mới
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Thêm bữa ăn mới', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          else
            ...mealPlans.map((meal) => _buildMealPlanCard(context, meal)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _navigateToAddMealPlan(context, _selectedDate); // Điều hướng để thêm bữa ăn mới
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Thêm bữa ăn mới', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null && pickedDate != _selectedDate) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
          child: const Text('Chọn ngày', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildMealPlanCard(BuildContext context, MealPlan meal) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fastfood, color: Colors.green[700]),
                const SizedBox(width: 10),
                Text(
                  meal.mealTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal.dish,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-meal-plan');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
