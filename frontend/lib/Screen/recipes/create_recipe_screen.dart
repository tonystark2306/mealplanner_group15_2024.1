import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import '../../Models/recipe_model.dart';
import '../../Providers/recipe_provider.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final List<TextEditingController> ingredientNameControllers = [];
  final List<TextEditingController> ingredientWeightControllers = [];
  final TextEditingController stepsController = TextEditingController();
  Uint8List? uploadedImage;

  @override
  void dispose() {
    nameController.dispose();
    timeController.dispose();
    for (var controller in ingredientNameControllers) {
      controller.dispose();
    }
    for (var controller in ingredientWeightControllers) {
      controller.dispose();
    }
    stepsController.dispose();
    super.dispose();
  }

  void addIngredientField() {
    setState(() {
      ingredientNameControllers.add(TextEditingController());
      ingredientWeightControllers.add(TextEditingController());
    });
  }

  Widget buildIngredientFields() {
    return Column(
      children: List.generate(ingredientNameControllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: ingredientNameControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Tên nguyên liệu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: ingredientWeightControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Khối lượng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    ingredientNameControllers.removeAt(index);
                    ingredientWeightControllers.removeAt(index);
                  });
                },
              )
            ],
          ),
        );
      }),
    );
  }

  Future<void> pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);

        reader.onLoadEnd.listen((event) {
          setState(() {
            uploadedImage = reader.result as Uint8List;
          });
        });
      }
    });
  }

  void saveRecipe() {
    final name = nameController.text;
    final time = timeController.text;
    final steps = stepsController.text;

    // Tạo danh sách Ingredient từ các controller
    final ingredients = List.generate(
      ingredientNameControllers.length,
      (index) => Ingredient(
        name: ingredientNameControllers[index].text,
        weight: ingredientWeightControllers[index].text,
      ),
    );

    // Kiểm tra tính hợp lệ
    if (name.isEmpty || time.isEmpty || steps.isEmpty || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    // Tạo RecipeItem mới
    final newRecipe = RecipeItem(
      id: DateTime.now().toString(),
      name: name,
      timeCooking: time,
      ingredients: ingredients,
      steps: steps,
      imagePath: uploadedImage != null ? 'Image Uploaded' : null,
    );

    // Thêm Recipe vào Provider
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.addRecipe(newRecipe);

    // Hiển thị thông báo và quay lại màn hình trước
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm công thức thành công!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm công thức mới'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết món ăn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên món ăn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Thời gian nấu (phút)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text(
              'Nguyên liệu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            buildIngredientFields(),
            Center(
              child: ElevatedButton.icon(
                onPressed: addIngredientField,
                icon: const Icon(Icons.add),
                label: const Text('Thêm nguyên liệu'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Các bước thực hiện',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: stepsController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ảnh món ăn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            if (uploadedImage != null)
              Column(
                children: [
                  Center(
                    child: Image.memory(
                      uploadedImage!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10), // Thêm khoảng cách
                ],
              ),
            Center(
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.upload),
                label: const Text('Tải ảnh lên'),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Center(
                child: Text(
                  'Thêm công thức',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
