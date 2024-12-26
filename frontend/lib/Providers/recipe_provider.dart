import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/recipe_model.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
          Ingredient(name: 'Bánh phở', unitName: 'g', weight: '200'),
          Ingredient(name: 'Thịt bò', unitName: 'g', weight: '300'),
          Ingredient(name: 'Hành lá', unitName: 'g', weight: '50g'),
          Ingredient(name: 'Gia vị phở', unitName: 'gói', weight: '1'),
          Ingredient(name: 'Nước dùng', unitName: 'L',weight: '1.5'),
        ],
        steps: '''
  1. Chuẩn bị nguyên liệu: rửa sạch rau thơm và hành lá.
  2. Sơ chế thịt bò và thái lát mỏng.
  3. Đun nước dùng, cho gói gia vị phở vào nồi.
  4. Nấu sôi, thêm thịt bò và các loại rau thơm vào.
  5. Bày bánh phở ra bát, chan nước dùng và thịt lên trên.
  6. Thêm hành lá và thưởng thức.
          ''',
        image: await loadImageAsUint8List(
            '../../ImageRecipeSuggest/phobo.jpg'), // Thay bằng ảnh Uint8List nếu có
      ),
      RecipeItem(
        id: '2',
        name: 'Bánh mì thịt nướng',
        timeCooking: '30 phút',
        ingredients: [
          Ingredient(name: 'Bánh mì', unitName: 'cái', weight: '1'),
          Ingredient(name: 'Thịt heo nướng', unitName: 'g', weight: '150'),
          Ingredient(name: 'Dưa leo', unitName: 'g', weight: '50'),
          Ingredient(name: 'Rau thơm', unitName: 'g', weight: '10'),
          Ingredient(name: 'Tương ớt', unitName: 'ml', weight: '20ml'),
        ],
        steps: '''
  1. Chuẩn bị nguyên liệu: rửa rau và thái dưa leo.
  2. Nướng thịt heo đến khi chín đều.
  3. Bổ đôi bánh mì, phết tương ớt vào hai mặt.
  4. Thêm thịt, rau và dưa leo vào trong bánh.
  5. Ép nhẹ bánh mì và thưởng thức.
          ''',
        image: await loadImageAsUint8List(
            '../../ImageRecipeSuggest/banhmi.png'), // Thay bằng ảnh Uint8List nếu có
      ),
    ];
    notifyListeners();
  }

  // Lấy danh sách công thức của người dùng
  List<RecipeItem> get recipes => _recipes;

  // Lấy danh sách công thức gợi ý
  List<RecipeItem> get suggestedRecipes => _suggestedRecipes;

  final String group_id = "7b95381b-dc40-460a-981e-5c04d3053e38";
  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTlhMDZlOWItNzE2ZC00ODc4LThjZTEtMDdiM2RjYjY4YTdmIiwiZXhwIjoxNzM1MTk3ODE1fQ.LhZW6Uj686Iq58AupB5hyPrLVjOIIdR0rzatW4omo20";
  Future<void> getRecipes() async {
    final url = Uri.parse('http://127.0.0.1:5000/api/recipe/$group_id');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> recipeJson = data['recipes'] ?? [];

        _recipes.clear(); // Clear the previous recipes

        for (var recipeData in recipeJson) {
          print(recipeData);
          Uint8List imageBytes = response.bodyBytes;
          RecipeItem recipe = RecipeItem(
              id: recipeData['id'] ?? '',
              name: recipeData['dish_name'] ?? '',
              timeCooking: recipeData['timeCooking'] ?? '',
              ingredients: (recipeData['ingredients'] as List?)
                      ?.map((ingredient) => Ingredient(
                            name: ingredient['food_name'] ?? '',
                            weight: ingredient['quantity'] ?? '',
                            unitName: ingredient['unit_name'] ?? '',
                          ))
                      .toList() ??
                  [],
              steps: recipeData['description'] ?? '',
              image: imageBytes);
          _recipes.add(recipe);
          notifyListeners();
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  Future<void> addRecipe(RecipeItem recipe) async {
    final url = Uri.parse('http://127.0.0.1:5000/api/recipe/$group_id');
    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Content-Type'] = 'multipart/form-data'
        ..headers['Authorization'] = 'Bearer $token';
      // Thêm các trường vào form-data
      request.fields['name'] = recipe.name;
      request.fields['description'] = recipe.steps;
      request.fields['content_html'] = recipe.steps;

      // Thêm danh sách nguyên liệu
      for (var ingredient in recipe.ingredients) {
        request.fields.addAll({
          'list[food_name]': ingredient.name,
          'list[quantity]': ingredient.weight,
        });
      }

      print(request.fields);

      // Thêm hình ảnh vào form-data nếu có
      if (recipe.image != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'images',
          recipe.image!,
          filename: 'recipe_image.jpg',
        ));
      }

      // Gửi yêu cầu và nhận phản hồi
      final response = await request.send();

      if (response.statusCode == 201) {
        // Thành công, thêm vào danh sách cục bộ
        _recipes.add(recipe);
        notifyListeners();
      } else {
        // Đọc và in chi tiết lỗi từ response
        final responseBody = await response.stream.bytesToString();
        print('Error: $responseBody');
        throw Exception('Failed to add recipe');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  // Cập nhật công thức
  void updateRecipe(String id, RecipeItem updatedRecipe) {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String id) async {
    final url = Uri.parse('http://127.0.0.1:5000/api/recipe/$group_id');

    try {
      var request = http.Request('DELETE', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token';

      // Thêm các trường vào form-data
      request.body = json.encode({'recipe_id': id});
      // Gửi yêu cầu và nhận phản hồi
      final response = await request.send();

      if (response.statusCode == 200) {
        // Xóa công thức khỏi danh sách cục bộ
        _recipes.removeWhere((recipe) => recipe.id == id);
        notifyListeners();
      } else {
        // Đọc và in chi tiết lỗi từ response
        final responseBody = await response.stream.bytesToString();
        print('Error: $responseBody');
        throw Exception('Failed to delete recipe');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
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
