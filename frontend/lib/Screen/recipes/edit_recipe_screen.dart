import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../Models/recipe_model.dart';
import '../../Providers/recipe_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Providers/token_storage.dart'; // Import TokenStorage

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
  late List<String> selectedUnits;
  late TextEditingController stepsController;
  Uint8List? uploadedImage;
  List<String> unitOptions = [];
  late String? imageLinkController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.recipe.name);
    timeController =
        TextEditingController(text: widget.recipe.timeCooking.split('.').first);

    ingredientNameControllers = widget.recipe.ingredients
        .map((ingredient) => TextEditingController(text: ingredient.name))
        .toList();

    ingredientWeightControllers = widget.recipe.ingredients
        .map((ingredient) => TextEditingController(text: ingredient.weight))
        .toList();

    selectedUnits = widget.recipe.ingredients
        .map((ingredient) => ingredient.unitName)
        .toList();

    stepsController = TextEditingController(text: widget.recipe.steps);
    imageLinkController = widget.recipe.imageLink;
    print('imageLinkController: $imageLinkController');
    fetchUnits();
  }

  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? ''; // Trả về access token
  }

  Future<void> fetchUnits() async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/api/admin/unit'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('units')) {
        setState(() {
          unitOptions = (jsonResponse['units'] as List<dynamic>)
              .map((unit) => unit['name'] as String)
              .toList();
        });
      } else {
        throw Exception('Invalid response format: missing "units" key');
      }
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Không thể tải danh sách đơn vị')),
      // );
    }
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
      selectedUnits.add('');
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
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: selectedUnits[index].isNotEmpty
                      ? selectedUnits[index]
                      : null,
                  items: unitOptions
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUnits[index] = value ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Đơn vị',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
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
                    selectedUnits.removeAt(index);
                  });
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  // Hàm buildTextField có thêm tham số minLines, maxLines
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int? minLines,
    int? maxLines,
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
      minLines: minLines,
      maxLines: maxLines,
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        uploadedImage = Uint8List.fromList(bytes);
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
        unitName: selectedUnits[index],
      ),
    );

    // Kiểm tra dữ liệu
    if (name.isEmpty ||
        time.isEmpty ||
        steps.isEmpty ||
        ingredients.any((ingredient) =>
            ingredient.name.isEmpty ||
            ingredient.weight.isEmpty ||
            ingredient.unitName.isEmpty)) {
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
      imageLink: widget.recipe.imageLink,
    );

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.updateRecipe(updatedRecipe.id, updatedRecipe, uploadedImage);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Đã chỉnh sửa công thức thành công!')),
    // );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa công thức',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
            buildTextField(
              controller: nameController,
              label: 'Tên món ăn',
            ),
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
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Thêm nguyên liệu',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Các bước thực hiện',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Tăng chiều cao ô nhập bằng cách truyền minLines và maxLines
            buildTextField(
              controller: stepsController,
              label: 'Các bước thực hiện',
              keyboardType: TextInputType.multiline,
              minLines: 5, // số dòng tối thiểu
              maxLines: 10, // số dòng tối đa
            ),
            const SizedBox(height: 20),
            const Text(
              'Ảnh món ăn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: uploadedImage != null
                        ? Image.memory(
                            uploadedImage!,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: imageLinkController!,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text(
                'Chọn ảnh',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: saveRecipe,
                icon: const Icon(Icons.save_alt, color: Colors.white),
                label: const Text(
                  'Lưu công thức',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
