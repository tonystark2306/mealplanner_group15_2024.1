import 'package:flutter/material.dart';
import 'package:meal_planner_app/Screen/admin/units.dart';
import 'Screen/bottom_navigation_screen.dart';
import 'Screen/reports/consumption_report_screen.dart';
// import 'Screen/refrigrator/refrigerator_management_screen.dart';
import 'Screen/auth/login.dart';
import 'Screen/auth/signupscreen.dart';
import 'Screen/homepage.dart';
import 'Screen/shopping/shopping_screen.dart';
import 'Screen/recipes/create_recipe_screen.dart';
import 'Screen/recipes/recipe_management_screen.dart';
import 'Screen/meal_planning/meal_planning_screen.dart';
import 'Screen/meal_planning/edit_meal_plan_screen.dart';
import 'Screen/auth/forgetpassword.dart';
import 'Screen/family_group/family_group_screen.dart';
import 'Screen/user_info/user_info_screen.dart';
import 'Screen/meal_planning/add_meal_plan_screen.dart';
import 'Screen/admin/admin_dashboard_screen.dart';
import 'Screen/admin/category_management_screen.dart';
import 'Screen/food/food_management_screen.dart';
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
  static const String foodManagement = '/food-management';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminCategories = '/admin-categories';
  static const String adminUnit = '/admin-unit';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const SimpleLoginScreen(),
      signup: (context) => const SignUpScreen(),
      home: (context) => HomeScreen(),
      bottomNav: (context) => const BottomNavigationScreen(),
      shoppingList: (context) => ShoppingListScreen(),
      report: (context) => const ReportScreen(),
      recipeManagement: (context) => const RecipeManagementScreen(),
      createRecipe: (context) => const CreateRecipeScreen(),
      mealPlanning: (context) => const MealPlanManagementScreen(),
      forgetPassword: (context) => const ForgotPasswordScreen(),
      familyGroup: (context) => const FamilyGroupScreen(),
      userInfo: (context) => const ProfileScreen(),
      foodManagement: (context) => FoodListScreen(),

      adminDashboard: (context) => const AdminDashboardScreen(),
      adminCategories: (context) => const CategoryManagementScreen(),
      adminUnit: (context) => const UnitsManagementScreen(),
    };
  }
}
