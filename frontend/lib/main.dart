import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'Providers/refrigerator_provider.dart';
import 'Providers/meal_planning_provider.dart';
import 'Screen/bottom_navigation_screen.dart';

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
      ],
      child: MaterialApp(
        home: const BottomNavigationScreen(),
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes, // Sử dụng routes từ AppRoutes
      ),
    );
  }
}
