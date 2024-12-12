import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các màn hình liên quan
import './Screen/bottom_navigation_screen.dart';
import './Screen/reports/consumption_report_screen.dart';
import './Screen/refrigrator/refrigerator_management_screen.dart';
import './Screen/auth/login.dart';
import './Screen/auth/signupscreen.dart';
import './Screen/homepage.dart';
import './Screen/shopping_list/shopping_list_screen.dart';
import './Screen/recipes/create_recipe_screen.dart';
import './Screen/recipes/recipe_management_screen.dart';
import './Providers/refrigerator_provider.dart';
import './Providers/meal_planning_provider.dart';
import './Screen/family_group/family_group_list_screen.dart';
import './Screen/family_group/family_group_detail_screen.dart'; // Màn hình chi tiết nhóm gia đình
import './Screen/family_group/create_family_group_screen.dart'; // Màn hình tạo nhóm gia đình

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RefrigeratorProvider(),
        ),
        ChangeNotifierProvider(create: (_) => MealPlanningProvider()),
      ],
      child: MaterialApp(
        home: const BottomNavigationScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const SimpleLoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => HomeScreen(),
          '/refrigerator': (context) => const RefrigeratorManagementScreen(),
          '/bottomnav': (context) => const BottomNavigationScreen(),
          '/shopping-list': (context) => const ShoppingListScreen(),
          '/report': (context) => const ReportScreen(),
          '/recipe-management': (context) => const RecipeManagementScreen(),
          '/create-recipe': (context) => const CreateRecipeScreen(),
          '/family-group': (context) => FamilyGroupListScreen(), // Đường dẫn danh sách nhóm
          '/family-group-detail': (context) => FamilyGroupDetailScreen(), // Đường dẫn chi tiết nhóm gia đình
          '/create-family-group': (context) => CreateFamilyGroupScreen(), // Đường dẫn tạo nhóm gia đình
        },
      ),
    );
  }
}
