import 'package:flutter/material.dart';
import '../Models/recipe_model.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class RecipeProvider with ChangeNotifier {
  // Danh sách công thức của người dùng
  final List<RecipeItem> _recipes = [];

  // Danh sách công thức gợi ý
  List<RecipeItem> _suggestedRecipes = [];

  RecipeProvider() {
    _initializeSuggestedRecipes();
  }

  Future<void> _initializeSuggestedRecipes() async {
    _suggestedRecipes = [
      RecipeItem(
        id: '1',
        name: 'Phở bò',
        timeCooking: '45 phút',
        ingredients: [
          Ingredient(name: 'Bánh phở', weight: '200g'),
          Ingredient(name: 'Thịt bò', weight: '300g'),
          Ingredient(name: 'Hành lá', weight: '50g'),
          Ingredient(name: 'Gia vị phở', weight: '1 gói'),
          Ingredient(name: 'Nước dùng', weight: '1.5L'),
        ],
        steps: '''
  1. Chuẩn bị nguyên liệu: rửa sạch rau thơm và hành lá.
  2. Sơ chế thịt bò và thái lát mỏng.
  3. Đun nước dùng, cho gói gia vị phở vào nồi.
  4. Nấu sôi, thêm thịt bò và các loại rau thơm vào.
  5. Bày bánh phở ra bát, chan nước dùng và thịt lên trên.
  6. Thêm hành lá và thưởng thức.
          ''',
        imagePath: await loadImageAsUint8List(
            '../../ImageRecipeSuggest/phobo.jpg'), // Thay bằng ảnh Uint8List nếu có
      ),
      RecipeItem(
        id: '2',
        name: 'Bánh mì thịt nướng',
        timeCooking: '30 phút',
        ingredients: [
          Ingredient(name: 'Bánh mì', weight: '1 ổ'),
          Ingredient(name: 'Thịt heo nướng', weight: '150g'),
          Ingredient(name: 'Dưa leo', weight: '50g'),
          Ingredient(name: 'Rau thơm', weight: '10g'),
          Ingredient(name: 'Tương ớt', weight: '20ml'),
        ],
        steps: '''
  1. Chuẩn bị nguyên liệu: rửa rau và thái dưa leo.
  2. Nướng thịt heo đến khi chín đều.
  3. Bổ đôi bánh mì, phết tương ớt vào hai mặt.
  4. Thêm thịt, rau và dưa leo vào trong bánh.
  5. Ép nhẹ bánh mì và thưởng thức.
          ''',
        imagePath: await loadImageAsUint8List(
            '../../ImageRecipeSuggest/banhmi.png'), // Thay bằng ảnh Uint8List nếu có
      ),
    ];
    notifyListeners();
  }

  // Lấy danh sách công thức của người dùng
  List<RecipeItem> get recipes => _recipes;

  // Lấy danh sách công thức gợi ý
  List<RecipeItem> get suggestedRecipes => _suggestedRecipes;

  // Thêm công thức mới
  void addRecipe(RecipeItem recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  // Cập nhật công thức
  void updateRecipe(String id, RecipeItem updatedRecipe) {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      notifyListeners();
    }
  }

  // Xóa công thức
  void deleteRecipe(String id) {
    _recipes.removeWhere((recipe) => recipe.id == id);
    notifyListeners();
  }

  // Lấy công thức theo ID
  RecipeItem? getRecipeById(String id) {
    return _recipes.firstWhere((recipe) => recipe.id == id);
  }

  // Lấy công thức gợi ý theo ID
  RecipeItem? getSuggestedRecipeById(String id) {
    return _suggestedRecipes.firstWhere((recipe) => recipe.id == id);
  }

  Future<Uint8List> loadImageAsUint8List(String assetPath) async {
    final ByteData imageData = await rootBundle.load(assetPath);
    return imageData.buffer.asUint8List();
  }
}
