import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';  // Thêm import này để sử dụng kIsWeb
import '../../Providers/food_provider.dart';
import 'package:provider/provider.dart';

class AddFoodScreen extends StatefulWidget {
  final String groupId;

  AddFoodScreen({required this.groupId});

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String type = 'ingredient';
  String categoryName = '';
  String unitName = '';
  String note = '';
  File? image;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
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
                // Danh mục
                TextFormField(
                  decoration: InputDecoration(labelText: 'Danh mục'),
                  onSaved: (value) => categoryName = value!,
                ),
                // Đơn vị
                TextFormField(
                  decoration: InputDecoration(labelText: 'Đơn vị'),
                  onSaved: (value) => unitName = value!,
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
                
                // Hiển thị ảnh đã chọn với giao diện đẹp hơn
                if (image != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: kIsWeb
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),  // Bo góc ảnh
                            child: Image.network(
                              image!.path,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),  // Bo góc ảnh
                            child: Image.file(
                              image!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),

                // Thêm một SizedBox thay vì Spacer để không có vấn đề về layout
                SizedBox(height: 20),

                // Nút thêm thực phẩm
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                        foodProvider.addFood(
                          groupId: widget.groupId,
                          name: name,
                          type: type,
                          categoryName: categoryName,
                          unitName: unitName,
                          note: note,
                          image: image!,
                        );
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
