import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/recipe_model.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'token_storage.dart'; // Đảm bảo bạn đã import đúng nơi chứa hàm getTokens
import 'package:http_parser/http_parser.dart'; // Import the http_parser package
import 'group_id_provider.dart';

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
        id: 'system_recipe',
        name: 'Phở bò',
        timeCooking: '45 ',
        ingredients: [
          Ingredient(name: 'Bánh phở', unitName: 'g', weight: '200'),
          Ingredient(name: 'Thịt bò', unitName: 'g', weight: '300'),
          Ingredient(name: 'Hành lá', unitName: 'g', weight: '50g'),
          Ingredient(name: 'Gia vị phở', unitName: 'gói', weight: '1'),
          Ingredient(name: 'Nước dùng', unitName: 'L', weight: '1.5'),
        ],
        steps: '''
  1. Chuẩn bị nguyên liệu: rửa sạch rau thơm và hành lá.
  2. Sơ chế thịt bò và thái lát mỏng.
  3. Đun nước dùng, cho gói gia vị phở vào nồi.
  4. Nấu sôi, thêm thịt bò và các loại rau thơm vào.
  5. Bày bánh phở ra bát, chan nước dùng và thịt lên trên.
  6. Thêm hành lá và thưởng thức.
        ''',
        imageLink: 'https://tiki.vn/blog/wp-content/uploads/2023/07/thumb-12.jpg',
      ),
      RecipeItem(
        id: 'system_recipe',
        name: 'Bánh mì thịt nướng',
        timeCooking: '30 ',
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
        imageLink: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/B%C3%A1nh_m%C3%AC_th%E1%BB%8Bt_n%C6%B0%E1%BB%9Bng.png/330px-B%C3%A1nh_m%C3%AC_th%E1%BB%8Bt_n%C6%B0%E1%BB%9Bng.png',
      ),
      RecipeItem(
        id: 'system_recipe',
        name: 'Thịt bò xào sả ớt',
        timeCooking: '30 ',
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
        imageLink: 'https://cdn.tgdd.vn/2021/05/CookProduct/BoXaoSaOt1200-1200x675-1200x675.jpg'
        ),
      RecipeItem(
        id: 'system_recipe',
        name: 'Tôm hùm alaska nướng',
        timeCooking: '30 ',
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
        imageLink: 'https://tepbac.com/upload/species/ge_image/Tep-bac-nghe_Metapenaeus%20brevicornis.jpg',
      ),
    ];
    notifyListeners();
  }

  // Lấy danh sách công thức của người dùng
  List<RecipeItem> get recipes => _recipes;

  // Lấy danh sách công thức gợi ý
  List<RecipeItem> get suggestedRecipes => _suggestedRecipes;

  // Lấy access token từ TokenStorage
  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? '';
  }

  Future<String> _getGroupId() async {
    final groupId = await GroupIdProvider.getSelectedGroupId();
    return groupId ?? '';
  }

  // Lấy công thức từ server
  Future<void> getRecipes() async {
    final group_id = await _getGroupId();
    final url = Uri.parse('http://127.0.0.1:5000/api/recipe/$group_id');
    final accessToken = await _getAccessToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> recipeJson = data['recipes'] ?? [];

      _recipes.clear();

      for (var recipeData in recipeJson) {
        final id = recipeData['id'] ?? '';
        final urlDetail =
            'http://127.0.0.1:5000/api/recipe/$group_id/$id';

        final responseDetail = await http.get(
          Uri.parse(urlDetail),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (responseDetail.statusCode == 200) {
          final recipeDataDetail = json.decode(responseDetail.body);
          var field = recipeDataDetail['detail_recipe'];

          final recipe = RecipeItem(
            id: recipeData['id'] ?? '',
            name: recipeData['dish_name'] ?? '',
            timeCooking: recipeData['cooking_time'] ?? '',
            ingredients: (field['foods'] as List?)
                    ?.map((ingredient) => Ingredient(
                          name: ingredient['food_name'] ?? '',
                          weight: ingredient['quantity'].toString(),
                          unitName: ingredient['unit_name'] ?? '',
                        ))
                    .toList() ??
                [],
            steps: recipeData['description'] ?? '',
            imageLink: (field['images'] as List).isNotEmpty
                ? (field['images'] as List)[0]['image_url']
                : null,
          );
          _recipes.add(recipe);
        }
      }
      // Chỉ notifyListeners() 1 lần sau khi load xong
      notifyListeners();
    } else {
      print("Lỗi tải recipes: ${response.statusCode}");
    }
  }

  // Thêm công thức
  Future<void> addRecipe(RecipeItem recipe, Uint8List? uploadImage) async {
    final group_id = await _getGroupId();
    final url = Uri.parse('http://127.0.0.1:5000/api/recipe/$group_id');
    final accessToken = await _getAccessToken();

    var request = http.MultipartRequest('POST', url)
      ..headers['Content-Type'] = 'multipart/form-data'
      ..headers['Authorization'] = 'Bearer $accessToken';

    request.fields['name'] = recipe.name;
    request.fields['description'] = recipe.steps;
    request.fields['content_html'] = recipe.steps;
    request.fields['cooking_time'] = recipe.timeCooking;

    List<String> foodNames = [];
    List<String> quantities = [];
    List<String> unitNames = [];

    for (var ingredient in recipe.ingredients) {
      foodNames.add(ingredient.name);
      quantities.add(ingredient.weight);
      unitNames.add(ingredient.unitName);
    }

    request.fields['list[food_name]'] = json.encode(foodNames);
    request.fields['list[quantity]'] = json.encode(quantities);
    request.fields['list[unit_name]'] = json.encode(unitNames);

    if (uploadImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          uploadImage,
          filename: 'uploaded_image_${DateTime.now()}.png',
          contentType: MediaType('image', 'png'),
        ),
      );
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        // Trước đây ta có _recipes.add(recipe), gây trùng lặp 
        // => Bỏ đi, thay vào đó fetch lại toàn bộ danh sách từ server
        await getRecipes();
      } else {
        print('Failed to add recipe: ${response.statusCode} | $responseBody');
      }
    } catch (e) {
      print('Error occurred in addRecipe: $e');
    }
  }

  // Cập nhật công thức
  Future<void> updateRecipe(
      String id, RecipeItem updatedRecipe, Uint8List? uploadedImage) async {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);
    if (index != -1) {
      final group_id = await _getGroupId();
      final url = Uri.parse('http://127.0.0.1:5000/api/recipe/$group_id');
      final accessToken = await _getAccessToken();

      var request = http.MultipartRequest('PUT', url)
        ..headers['Content-Type'] = 'multipart/form-data'
        ..headers['Authorization'] = 'Bearer $accessToken';

      request.fields['recipe_id'] = id;
      request.fields['new_name'] = updatedRecipe.name;
      request.fields['new_description'] = updatedRecipe.steps;
      request.fields['new_content_html'] = updatedRecipe.steps;
      request.fields['new_cooking_time'] = updatedRecipe.timeCooking;

      List<String> foodNames = [];
      List<String> quantities = [];
      List<String> unitNames = [];

      for (var ingredient in updatedRecipe.ingredients) {
        foodNames.add(ingredient.name);
        quantities.add(ingredient.weight);
        unitNames.add(ingredient.unitName);
      }

      request.fields['list[new_food_name]'] = json.encode(foodNames);
      request.fields['list[new_quantity]'] = json.encode(quantities);
      request.fields['list[new_unit_name]'] = json.encode(unitNames);

      if (uploadedImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'new_images',
            uploadedImage,
            filename: 'uploaded_image_${DateTime.now().toIso8601String()}.png',
          ),
        );
      }
      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          // Xóa cập nhật cục bộ => thay bằng fetch lại
          await getRecipes();
        } else {
          print('Failed to update recipe: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }

  // Xóa công thức
  Future<void> deleteRecipe(String id) async {
    final group_id = await _getGroupId();
    final url = Uri.parse('http://127.0.0.1:5000/api/recipe/$group_id');
    final accessToken = await _getAccessToken();

    try {
      var request = http.Request('DELETE', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $accessToken';

      request.body = json.encode({'recipe_id': id});
      final response = await request.send();

      if (response.statusCode == 200) {
        // Thay vì remove cục bộ => fetch toàn bộ để đồng bộ với server
        await getRecipes();
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error: $responseBody');
        throw Exception('Failed to delete recipe');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  // Hàm tải ảnh từ tài nguyên
  Future<Uint8List> loadImageAsUint8List(String assetPath) async {
    final ByteData imageData = await rootBundle.load(assetPath);
    return imageData.buffer.asUint8List();
  }
}
