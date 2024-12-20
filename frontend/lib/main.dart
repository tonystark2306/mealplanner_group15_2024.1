import 'package:flutter/material.dart';
import 'package:meal_planner_app/Providers/recipe_provider.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'Providers/refrigerator_provider.dart';
import 'Providers/meal_planning_provider.dart';
import 'Screen/bottom_navigation_screen.dart';
import 'Screen/admin/admin_dashboard_screen.dart'; // Import màn hình Admin Dashboard

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RefrigeratorProvider()),
        ChangeNotifierProvider(create: (_) => MealPlanningProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        home: const BottomNavigationScreen(),
        //home: const AdminDashboardScreen(),
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes, // Sử dụng routes từ AppRoutes
      ),
    );
  }
}
