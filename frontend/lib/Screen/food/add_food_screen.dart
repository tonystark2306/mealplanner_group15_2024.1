import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Thêm import này để sử dụng kIsWeb
import '../../Providers/food_provider.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class AddFoodScreen extends StatefulWidget {
  final String groupId;

  AddFoodScreen({required this.groupId});

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String type = '';
  String? selectedCategory;
  String? selectedUnit;
  String note = '';
  File? image;
  var imageWeb; // Biến cho ảnh web

  final _picker = ImagePicker();
  late Future<List<String>> _categoriesFuture;
  late Future<List<String>> _unitsFuture;

  @override
  void initState() {
    super.initState();
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    _categoriesFuture = foodProvider.fetchCategoryNames();
    _unitsFuture = foodProvider.fetchUnitNames();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Chọn ảnh từ gallery trên web
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          setState(() {
            imageWeb = reader.result
                as Uint8List; // Lưu trữ ảnh cho web dưới dạng Uint8List
          });
        });
      });
    } else {
      // Chọn ảnh cho mobile
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
      }
    }
  }

  @override
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.green[700]),
      prefixIcon: Icon(icon, color: Colors.green[700]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.green.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.green.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.green.shade500, width: 2),
      ),
      filled: true,
      fillColor: Colors.green[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Thêm thực phẩm",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green[600]!,
                Colors.green[800]!,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker Section
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200, width: 2),
                  ),
                  child: image != null || imageWeb != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: kIsWeb
                              ? Image.memory(imageWeb, fit: BoxFit.cover)
                              : Image.file(image!, fit: BoxFit.cover),
                        )
                      : InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 64,
                                color: Colors.green[700],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Thêm ảnh thực phẩm",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                // Form Fields
                TextFormField(
                  decoration: _buildInputDecoration(
                      'Tên thực phẩm', Icons.restaurant_menu),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên thực phẩm' : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration:
                      _buildInputDecoration('Loại thực phẩm', Icons.category),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập loại thực phẩm' : null,
                  onSaved: (value) => type = value!,
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                FutureBuilder<List<String>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration:
                            _buildInputDecoration('Danh mục', Icons.list_alt),
                        value: selectedCategory,
                        items: snapshot.data?.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedCategory = value),
                        validator: (value) =>
                            value == null ? 'Vui lòng chọn danh mục' : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Unit Dropdown
                FutureBuilder<List<String>>(
                  future: _unitsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration:
                            _buildInputDecoration('Đơn vị', Icons.straighten),
                        value: selectedUnit,
                        items: snapshot.data?.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedUnit = value),
                        validator: (value) =>
                            value == null ? 'Vui lòng chọn đơn vị' : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: _buildInputDecoration('Ghi chú', Icons.note),
                  maxLines: 3,
                  onSaved: (value) => note = value!,
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (kIsWeb) {
                        foodProvider.addFood(
                          groupId: widget.groupId,
                          name: name,
                          type: type,
                          categoryName: selectedCategory!,
                          unitName: selectedUnit!,
                          note: note,
                          imageWeb: imageWeb,
                        );
                      } else {
                        foodProvider.addFood(
                          groupId: widget.groupId,
                          name: name,
                          type: type,
                          categoryName: selectedCategory!,
                          unitName: selectedUnit!,
                          note: note,
                          image: image!,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Thêm thực phẩm",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
