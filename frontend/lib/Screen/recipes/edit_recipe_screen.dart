import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';  // Thêm thư viện image_picker

import '../../Models/recipe_model.dart';
import '../../Providers/recipe_provider.dart';

class EditRecipeScreen extends StatefulWidget {
  final RecipeItem recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late TextEditingController nameController;
  late TextEditingController timeController;
  late List<TextEditingController> ingredientNameControllers;
  late List<TextEditingController> ingredientWeightControllers;
  late TextEditingController stepsController;
  Uint8List? uploadedImage;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với dữ liệu hiện tại của công thức
    nameController = TextEditingController(text: widget.recipe.name);
    timeController = TextEditingController(text: widget.recipe.timeCooking);
    ingredientNameControllers = widget.recipe.ingredients
        .map((ingredient) => TextEditingController(text: ingredient.name))
        .toList();
    ingredientWeightControllers = widget.recipe.ingredients
        .map((ingredient) => TextEditingController(text: ingredient.weight))
        .toList();
    stepsController = TextEditingController(text: widget.recipe.steps);
    uploadedImage = widget.recipe.image;
  }

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
                child: buildTextField(
                  controller: ingredientNameControllers[index],
                  label: 'Tên nguyên liệu',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: buildTextField(
                  controller: ingredientWeightControllers[index],
                  label: 'Khối lượng',
                  keyboardType: TextInputType.number,
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
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  // Sửa lại hàm pickImage để sử dụng image_picker
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);  // Chọn ảnh từ thư viện

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        uploadedImage = imageBytes;  // Cập nhật ảnh chọn
      });
    }
  }

  void saveRecipe() {
    final name = nameController.text;
    final time = timeController.text;
    final steps = stepsController.text;

    final ingredients = List.generate(
      ingredientNameControllers.length,
      (index) => Ingredient(
        name: ingredientNameControllers[index].text,
        weight: ingredientWeightControllers[index].text,
      ),
    );

    if (name.isEmpty || time.isEmpty || steps.isEmpty || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    final updatedRecipe = RecipeItem(
      id: widget.recipe.id,
      name: name,
      timeCooking: time,
      ingredients: ingredients,
      steps: steps,
      image: uploadedImage, // Lưu trực tiếp ảnh dưới dạng Uint8List
    );

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.updateRecipe(updatedRecipe.id, updatedRecipe);  // Cập nhật công thức

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã chỉnh sửa công thức thành công!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa công thức',
          style:
              TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[700]),
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
            buildTextField(controller: nameController, label: 'Tên món ăn'),
            const SizedBox(height: 10),
            buildTextField(
              controller: timeController,
              label: 'Thời gian nấu (phút)',
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
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text('Thêm nguyên liệu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Các bước thực hiện',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            buildTextField(
              controller: stepsController,
              label: 'Các bước thực hiện',
              keyboardType: TextInputType.multiline,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(
                        uploadedImage!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(
                Icons.upload_file,
                color: Colors.white,
              ),
              label: const Text('Chọn ảnh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: saveRecipe,
                icon: const Icon(
                  Icons.save_alt, // Đây là icon save file
                  color: Colors.white,
                ),
                label: const Text('Lưu công thức'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
