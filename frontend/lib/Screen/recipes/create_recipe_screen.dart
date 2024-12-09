import 'package:flutter/material.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final List<Map<String, String>> ingredients = [];
  final List<TextEditingController> ingredientNameControllers = [];
  final List<TextEditingController> ingredientWeightControllers = [];
  final TextEditingController stepsController = TextEditingController();
  String? uploadedImagePath;

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
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: ingredientNameControllers[index],
                decoration: const InputDecoration(labelText: 'Tên nguyên liệu'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: ingredientWeightControllers[index],
                decoration: const InputDecoration(labelText: 'Khối lượng'),
              ),
            ),
          ],
        );
      }),
    );
  }

  void saveRecipe() {
    // Logic lưu công thức
    final name = nameController.text;
    final time = timeController.text;
    final steps = stepsController.text;
    for (int i = 0; i < ingredientNameControllers.length; i++) {
      ingredients.add({
        'name': ingredientNameControllers[i].text,
        'weight': ingredientWeightControllers[i].text,
      });
    }
    print('Recipe Saved: $name, $time, $ingredients, $steps');
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên món ăn'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Thời gian nấu (phút)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text('Nguyên liệu:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            buildIngredientFields(),
            TextButton.icon(
              onPressed: addIngredientField,
              icon: const Icon(Icons.add),
              label: const Text('Thêm nguyên liệu'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: stepsController,
              decoration: const InputDecoration(labelText: 'Các bước thực hiện'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Logic chọn ảnh
              },
              icon: const Icon(Icons.upload),
              label: const Text('Tải ảnh món ăn'),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: saveRecipe,
                child: const Text('Lưu công thức'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
