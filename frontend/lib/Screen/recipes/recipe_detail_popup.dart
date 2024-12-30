import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../Models/recipe_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Providers/token_storage.dart'; // Import TokenStorage
import '../../../Providers/group_id_provider.dart'; // Import TokenStorage
import 'package:cached_network_image/cached_network_image.dart';

class RecipeDetailPopup extends StatelessWidget {
  final RecipeItem recipeItem;
  const RecipeDetailPopup({super.key, required this.recipeItem});

  // Lấy token từ TokenStorage
  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? ''; // Trả về access token
  }

  Future<String> _getGroupId() async {
    final groupId = await GroupIdProvider.getSelectedGroupId();
    return groupId ?? ''; // Trả về access token
  }

  Future<RecipeItem> fetchRecipeDetail() async {
    final id = recipeItem.id;
    final groupId = await _getGroupId();
    final url = 'http://127.0.0.1:5000/api/recipe/$groupId/$id';
    final token = await _getAccessToken(); // Lấy token từ TokenStorage

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final recipeData = json.decode(response.body);
      Uint8List imageBytes = response.bodyBytes;
      var field = recipeData['detail_recipe'];
      print(field);
      return RecipeItem(
        id: field['id'] ?? '',
        name: field['dish_name'] ?? '',
        timeCooking: field['cooking_time'] ?? '',
        ingredients: (field['foods'] as List?)
                ?.map((ingredient) => Ingredient(
                      name: ingredient['food_name'] ?? '',
                      weight: ingredient['quantity'].toString() ?? '',
                      unitName: ingredient['unit_name'] ?? '',
                    ))
                .toList() ??
            [],
        steps: field['description'] ?? '',
        image:
            imageBytes, // Assuming RecipeItem has a fromJson factory constructor.
      );
    } else {
      final responseBody = await response.body;
      print('Error: $responseBody');
      throw Exception('Failed to load recipe details');
    }
  }

  Widget _buildImage(RecipeItem recipe) {
    if (recipe.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );
    } else if (recipe.image != null) {
      return Image.memory(
        recipe.image!,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(Icons.image, size: 100, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecipeItem>(
      future: fetchRecipeDetail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load recipe: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        } else if (snapshot.hasData) {
          final recipe = snapshot.data!;
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 16,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe Name Section
                    Center(
                      child: Text(
                        recipe.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.green[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Image Section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildImage(recipe),
                    ),
                    const SizedBox(height: 16),

                    // Time Cooking Section
                    Text(
                      'Thời gian nấu: ${recipe.timeCooking.split('.')[0]} phút',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),

                    // Ingredients Section
                    Text(
                      'Nguyên liệu:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            '${ingredient.name}: ${ingredient.weight} ${ingredient.unitName}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Steps Section
                    Text(
                      'Các bước thực hiện:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.steps,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),

                    // Close Button Section
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          backgroundColor: Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
