import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';  // Import this to use kIsWeb
import '../../Providers/food_provider.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class EditFoodScreen extends StatefulWidget {
  final String groupId;
  final Map<String, dynamic> food;

  EditFoodScreen({required this.groupId, required this.food});

  @override
  _EditFoodScreenState createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String type;
  late String categoryName;
  late String unitName;
  late String note;
  File? image;
  var imageWeb;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Khởi tạo các giá trị ban đầu từ dữ liệu thực phẩm
    name = widget.food['name'] ?? '';
    type = widget.food['type'] ?? '';
    categoryName = widget.food['category_name'] ?? '';
    unitName = widget.food['unit_name'] ?? '';
    note = widget.food['note'] ?? '';
    // Nếu có ảnh, bạn có thể tải ảnh từ URL hoặc xử lý theo cách khác
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
            imageWeb = reader.result as Uint8List;
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
      appBar: AppBar(title: Text("Chỉnh sửa thực phẩm")),
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
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'Tên thực phẩm'),
                  onSaved: (value) => name = value!,
                  validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                ),
                
                // Loại thực phẩm
                TextFormField(
                  initialValue: type,
                  decoration: InputDecoration(labelText: 'Loại thực phẩm'),
                  onSaved: (value) => type = value!,
                  validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                ),
                
                // Danh mục
                TextFormField(
                  initialValue: categoryName,
                  decoration: InputDecoration(labelText: 'Danh mục'),
                  onSaved: (value) => categoryName = value!,
                ),
                
                // Đơn vị
                TextFormField(
                  initialValue: unitName,
                  decoration: InputDecoration(labelText: 'Đơn vị'),
                  onSaved: (value) => unitName = value!,
                ),
                
                // Ghi chú
                TextFormField(
                  initialValue: note,
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
                              imageWeb,
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

                // Nút lưu chỉnh sửa
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (kIsWeb) {
                        foodProvider.updateFood(
                          groupId: widget.groupId,
                          foodId: widget.food['id'],
                          name: name,
                          type: type,
                          categoryName: categoryName,
                          unitName: unitName,
                          note: note,
                          imageWeb: imageWeb,  // Pass imageWeb for web
                        );
                      } else {
                        foodProvider.updateFood(
                          groupId: widget.groupId,
                          foodId: widget.food['id'],
                          name: name,
                          type: type,
                          categoryName: categoryName,
                          unitName: unitName,
                          note: note,
                          image: image!,  // Pass image for mobile
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Lưu"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}