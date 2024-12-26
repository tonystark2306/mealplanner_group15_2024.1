import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/fridge/fridge_item_model.dart';
import '../../Providers/fridge_provider/refrigerator_provider.dart';

class EditFridgeItemScreen extends StatefulWidget {
  final FridgeItem fridgeItem; // Nhận FridgeItem cần chỉnh sửa

  const EditFridgeItemScreen({super.key, required this.fridgeItem});

  @override
  _EditFridgeItemScreenState createState() => _EditFridgeItemScreenState();
}

class _EditFridgeItemScreenState extends State<EditFridgeItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _quantity;
  late DateTime _expiryDate;

  @override
  void initState() {
    super.initState();
    // Khởi tạo với thông tin của FridgeItem hiện tại
    _name = widget.fridgeItem.name;
    _quantity = widget.fridgeItem.quantity;
    _expiryDate = widget.fridgeItem.expirationDate;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedFridgeItem = FridgeItem(
        id: widget.fridgeItem.id, // Giữ nguyên ID
        name: _name,
        quantity: _quantity,
        expirationDate: _expiryDate,
      );

      // Cập nhật item trong Provider
      Provider.of<RefrigeratorProvider>(context, listen: false)
          .updateItem(updatedFridgeItem);

      Navigator.pop(context);
    }
  }

  void _pickExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime(2024),
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
