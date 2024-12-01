import 'package:flutter/material.dart';
import './Screen/bottom_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'Providers/refrigerator_provider.dart'; // Import Provider của bạn
import 'Screen/refrigrator/refrigerator_management_screen.dart'; 
import 'Screen/auth/login.dart';
import 'Screen/auth/signupscreen.dart';
import 'Screen/homepage.dart';
import 'Screen/shopping_list/shopping_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RefrigeratorProvider(),
        ),
      ],
      child: MaterialApp(
        home: BottomNavigationScreen(), // Đặt màn hình chính
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const SimpleLoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => HomeScreen(),
          '/refrigerator': (context) => RefrigeratorManagementScreen(),
          '/bottomnav': (context) => BottomNavigationScreen(),
          '/shopping-list': (context) => const ShoppingListScreen(),
        },
      ),
    );
  }
}
