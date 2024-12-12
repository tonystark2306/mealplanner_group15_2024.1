import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './Screen/bottom_navigation_screen.dart';
import './Screen/reports/consumption_report_screen.dart'; // Import màn hình báo cáo
import 'Providers/refrigerator_provider.dart';
import 'Screen/refrigrator/refrigerator_management_screen.dart';
import 'Screen/auth/login.dart';
import 'Screen/auth/signupscreen.dart';
import 'Screen/homepage.dart';
import 'Screen/shopping_list/shopping_list_screen.dart';
import 'Screen/recipes/create_recipe_screen.dart';
import 'Screen/recipes/recipe_management_screen.dart';
import 'Providers/meal_planning_provider.dart';
import 'Providers/recipe_provider.dart';
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
        ChangeNotifierProvider(
            create: (_) => MealPlanningProvider()), // Thêm MealPlanningProvider
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(),
        )
      ],
      child: MaterialApp(
        home: const BottomNavigationScreen(), // Màn hình chính
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const SimpleLoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => HomeScreen(),
          '/refrigerator': (context) => const RefrigeratorManagementScreen(),
          '/bottomnav': (context) => const BottomNavigationScreen(),
          '/shopping-list': (context) => const ShoppingListScreen(),
          '/report': (context) =>
              const ReportScreen(), // Correct route to ReportScreen
          '/recipe-management': (context) => const RecipeManagementScreen(),
          '/create-recipe': (context) => const CreateRecipeScreen(),
        },
      ),
    );
  }
}
