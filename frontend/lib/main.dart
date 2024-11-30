import 'package:flutter/material.dart';
import 'Screen/auth/login.dart';
import 'Screen/auth/signupscreen.dart';
import 'Screen/homepage.dart';  // Import trang chủ

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),  // Đặt trang chủ làm màn hình mặc định
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const SimpleLoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => HomeScreen(),  // Thêm route cho trang chủ
      },
    );
  }
}