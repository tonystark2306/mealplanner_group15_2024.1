import 'package:flutter/material.dart';
import 'package:meal_planner_app/Providers/recipe_provider.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'Providers/fridge_provider/refrigerator_provider.dart';
import 'Providers/meal_planning_provider.dart';
import "Screen/auth/login.dart";
import 'Providers/food_provider.dart';
import 'Providers/shopping_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => RefrigeratorProvider()),
        ChangeNotifierProvider(create: (_) => MealPlanProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
      ],
      child: MaterialApp(
        home: const SimpleLoginScreen(),
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes, // Sử dụng routes từ AppRoutes
      ),
    );
  }
}
