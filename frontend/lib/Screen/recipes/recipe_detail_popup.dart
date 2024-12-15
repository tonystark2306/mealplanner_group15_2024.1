import 'package:flutter/material.dart';
import '../../Models/recipe_model.dart';

class RecipeDetailPopup extends StatelessWidget {
  final RecipeItem recipe;

  const RecipeDetailPopup({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              recipe.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(
                        recipe.imagePath!,
                        width: double.infinity,
                        height: 500, // Chỉnh lại chiều cao ảnh
                        fit: BoxFit.contain,  // Giữ tỷ lệ gốc của ảnh
                      ),
                    )
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
              const SizedBox(height: 16),

              // Recipe Name
              Text(
                'Tên món ăn: ${recipe.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Text(
                'Thời gian nấu: ${recipe.timeCooking} phút',
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
                      '${ingredient.name}: ${ingredient.weight}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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

              // Close Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), backgroundColor: Colors.green[700],
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
  }
}
