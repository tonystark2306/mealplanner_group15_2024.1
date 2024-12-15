import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/food_item_model.dart';
import '../../Providers/refrigerator_provider.dart';

class EditFoodItemScreen extends StatefulWidget {
  final FoodItem foodItem; // Nhận FoodItem cần chỉnh sửa

  const EditFoodItemScreen({super.key, required this.foodItem});

  @override
  _EditFoodItemScreenState createState() => _EditFoodItemScreenState();
}

class _EditFoodItemScreenState extends State<EditFoodItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _quantity;
  late DateTime _expiryDate;

  @override
  void initState() {
    super.initState();
    // Khởi tạo với thông tin của FoodItem hiện tại
    _name = widget.foodItem.name;
    _quantity = widget.foodItem.quantity;
    _expiryDate = widget.foodItem.expirationDate;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedFoodItem = FoodItem(
        id: widget.foodItem.id, // Giữ nguyên ID
        name: _name,
        quantity: _quantity,
        expirationDate: _expiryDate,
      );

      // Cập nhật item trong Provider
      Provider.of<RefrigeratorProvider>(context, listen: false)
          .updateItem(updatedFoodItem);

      Navigator.pop(context);
    }
  }

  void _pickExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh Sửa Thực Phẩm',
          style: TextStyle(color: Colors.green[700]),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Tên thực phẩm'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên thực phẩm';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Vui lòng nhập số lượng hợp lệ';
                  }
                  return null;
                },
                onSaved: (value) {
                  _quantity = int.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Ngày hết hạn: ${_expiryDate.toLocal().toString().split(' ')[0]}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickExpiryDate,
                    child: const Text('Chọn ngày'),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Center(
                  child: Text(
                    'Lưu thay đổi',
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
