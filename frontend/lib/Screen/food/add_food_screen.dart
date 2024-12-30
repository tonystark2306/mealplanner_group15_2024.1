import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';  // Thêm import này để sử dụng kIsWeb
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
  var imageWeb;  // Biến cho ảnh web

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
            imageWeb = reader.result as Uint8List;  // Lưu trữ ảnh cho web dưới dạng Uint8List
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
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Thêm thực phẩm")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên thực phẩm
                TextFormField(
                  decoration: InputDecoration(labelText: 'Tên thực phẩm'),
                  onSaved: (value) => name = value!,
                  validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                ),
                
                // Loại thực phẩm
                TextFormField(
                  decoration: InputDecoration(labelText: 'Loại thực phẩm'),
                  onSaved: (value) => type = value!,
                  validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                ),
                
                // Danh mục
                FutureBuilder<List<String>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Không thể tải danh mục");
                    } else {
                      final categories = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Danh mục'),
                        value: selectedCategory,
                        onChanged: (value) => setState(() => selectedCategory = value),
                        items: categories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
                      );
                    }
                  },
                ),
                
                // Đơn vị
                FutureBuilder<List<String>>(
                  future: _unitsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Không thể tải đơn vị");
                    } else {
                      final units = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Đơn vị'),
                        value: selectedUnit,
                        onChanged: (value) => setState(() => selectedUnit = value),
                        items: units
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ))
                            .toList(),
                        validator: (value) => value == null ? 'Vui lòng chọn đơn vị' : null,
                      );
                    }
                  },
                ),
                
                // Ghi chú
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ghi chú'),
                  onSaved: (value) => note = value!,
                ),
                SizedBox(height: 16),

                // Chọn ảnh
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Chọn ảnh"),
                ),
                
                // Hiển thị ảnh đã chọn
                if (image != null || imageWeb != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: kIsWeb
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.memory(
                              imageWeb,  // Hiển thị ảnh cho web (dùng Image.memory cho Uint8List)
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.file(
                              image!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),

                SizedBox(height: 20),

                // Nút thêm thực phẩm
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
                          imageWeb: imageWeb,  // Pass imageWeb for web
                        );
                      } else {
                        foodProvider.addFood(
                          groupId: widget.groupId,
                          name: name,
                          type: type,
                          categoryName: selectedCategory!,
                          unitName: selectedUnit!,
                          note: note,
                          image: image!,  // Pass image for mobile
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Thêm"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
