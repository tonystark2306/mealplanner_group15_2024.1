import 'package:flutter/material.dart';
import './homepage.dart';
import './refrigrator/list_fridge.dart';
import './meal_planning/meal_planning_screen.dart';
import './recipes/recipe_management_screen.dart';
import 'shopping/shopping_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình cho từng tab
  final List<Widget> _screens = [
    HomeScreen(), // Trang chủ
    const MealPlanManagementScreen(), // Kế hoạch bữa ăn
    ShoppingListScreen(), // Danh sách mua sắm
    const GroupListScreen(), // Quản lý tủ lạnh
    const RecipeManagementScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Hiển thị màn hình theo chỉ số
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex, // Tab hiện tại
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped, // Chuyển tab khi nhấn
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Bữa ăn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Mua sắm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Tủ lạnh',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Công thức',
          ),
        ],
      ),
    );
  }
}
