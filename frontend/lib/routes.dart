import 'package:flutter/material.dart';
import 'Screen/bottom_navigation_screen.dart';
import 'Screen/reports/consumption_report_screen.dart';
import 'Screen/refrigrator/refrigerator_management_screen.dart';
import 'Screen/auth/login.dart';
import 'Screen/auth/signupscreen.dart';
import 'Screen/homepage.dart';
import 'Screen/shopping_list/shopping_list_screen.dart';
import 'Screen/recipes/create_recipe_screen.dart';
import 'Screen/recipes/recipe_management_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String refrigerator = '/refrigerator';
  static const String bottomNav = '/bottomnav';
  static const String shoppingList = '/shopping-list';
  static const String report = '/report';
  static const String recipeManagement = '/recipe-management';
  static const String createRecipe = '/create-recipe';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const SimpleLoginScreen(),
      signup: (context) => const SignUpScreen(),
      home: (context) => HomeScreen(),
      refrigerator: (context) => const RefrigeratorManagementScreen(),
      bottomNav: (context) => const BottomNavigationScreen(),
      shoppingList: (context) => const ShoppingListScreen(),
      report: (context) => const ReportScreen(),
      recipeManagement: (context) => const RecipeManagementScreen(),
      createRecipe: (context) => const CreateRecipeScreen(),
    };
  }
}
