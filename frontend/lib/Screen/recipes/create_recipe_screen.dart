import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import '../../Models/recipe_model.dart';
import '../../Providers/recipe_provider.dart';
import '../../../Providers/token_storage.dart'; // Import TokenStorage
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
  final List<String?> selectedUnits = [];
  final TextEditingController stepsController = TextEditingController();
  Uint8List? uploadedImage;
  List<String> availableUnits = []; // List of units fetched from API

  @override
  void initState() {
    super.initState();
    fetchUnits();
  }

Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? ''; // Trả về access token
  }


  Future<void> fetchUnits() async {
    final token = await _getAccessToken(); // Use the dynamic token

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/admin/unit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['units'] is List) {
          setState(() {
            // Extract the `name` field from each unit object
            availableUnits = (data['units'] as List)
                .map((unit) => unit['name'] as String)
                .toList();
          });
        } else {
          throw Exception('Invalid data structure');
        }
      } else {
        throw Exception('Failed to fetch units');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching units: $error')),
      );
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
      selectedUnits.add(null);
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
                  value: selectedUnits[index],
                  items: availableUnits
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUnits[index] = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Đơn vị',
                    labelStyle: TextStyle(
                        color: Colors
                            .green[700]), // Màu xanh giống các trường khác
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    // Xóa lớp nền xám
                    filled: false, // Bỏ lớp nền màu xám
                    isDense: true, // Tối ưu không gian
                  ),
                  dropdownColor: Colors.white, // Đặt màu nền cho dropdown
                  focusColor:
                      Colors.transparent, // Không hiển thị lớp màu khi focus
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

  Future<void> pickImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      
      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          setState(() {
            uploadedImage = reader.result as Uint8List;  // Lưu trữ ảnh cho web dưới dạng Uint8List
          });
        });
      });
  }

  void saveRecipe() {
    final name = nameController.text;
    final time = timeController.text;
    final steps = stepsController.text;

    final ingredients = List.generate(
      ingredientNameControllers.length,
      (index) {
        final unit = selectedUnits[index];
        if (unit == null) {
          throw Exception('All ingredients must have a unit selected');
        }
        return Ingredient(
          name: ingredientNameControllers[index].text,
          weight: ingredientWeightControllers[index].text,
          unitName: unit,
        );
      },
    );

    if (name.isEmpty || time.isEmpty || steps.isEmpty || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    final newRecipe = RecipeItem(
      id: DateTime.now().toString(),
      name: name,
      timeCooking: time,
      ingredients: ingredients,
      steps: steps,
      imageLink: '',
    );
  
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.addRecipe(newRecipe, uploadedImage);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm công thức thành công!')),
    );

    Navigator.of(context).pop();
    recipeProvider.getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm công thức mới',
          style:
              TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[700]),
      ),
      body: availableUnits.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      controller: nameController, label: 'Tên món ăn'),
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
                    icon: const Icon(Icons.upload_file, color: Colors.white),
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
                      icon: const Icon(Icons.save_alt, color: Colors.white),
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
