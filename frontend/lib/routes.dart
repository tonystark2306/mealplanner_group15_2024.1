import 'package:flutter/material.dart';
import 'Screen/bottom_navigation_screen.dart';
import 'Screen/reports/consumption_report_screen.dart';
// import 'Screen/refrigrator/refrigerator_management_screen.dart';
import 'Screen/auth/login.dart';
import 'Screen/auth/signupscreen.dart';
import 'Screen/homepage.dart';
import 'Screen/shopping_list/shopping_list_screen.dart';
import 'Screen/recipes/create_recipe_screen.dart';
import 'Screen/recipes/recipe_management_screen.dart';
import 'Screen/meal_planning/meal_planning_screen.dart';
import 'Screen/meal_planning/edit_meal_plan_screen.dart';
import 'Screen/auth/forgetpassword.dart';
import 'Screen/family_group/family_group_screen.dart';
import 'Screen/user_info/user_info_screen.dart';
import 'Screen/meal_planning/add_meal_plan_screen.dart';
import 'Screen/admin/admin_dashboard_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String bottomNav = '/bottomnav';
  static const String shoppingList = '/shopping-list';
  static const String report = '/report';
  static const String recipeManagement = '/recipe-management';
  static const String createRecipe = '/create-recipe';
  static const String mealPlanning = '/meal-planning';
  static const String editMealPlanning = '/edit-meal-plan';
  static const String forgetPassword = '/forget-password';
  static const String familyGroup = '/family-group';
  static const String userInfo = '/user-info';
  static const String adminDashboard = '/admin-dashboard';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const SimpleLoginScreen(),
      signup: (context) => const SignUpScreen(),
      home: (context) => HomeScreen(),
      bottomNav: (context) => const BottomNavigationScreen(),
      shoppingList: (context) => const ShoppingListScreen(),
      report: (context) => const ReportScreen(),
      recipeManagement: (context) => const RecipeManagementScreen(),
      createRecipe: (context) => const CreateRecipeScreen(),
      mealPlanning: (context) => const MealPlanManagementScreen(),
      forgetPassword: (context) => const ForgotPasswordScreen(),
      familyGroup: (context) => const FamilyGroupScreen(),
      userInfo: (context) => const ProfileScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
    };
  }
}
