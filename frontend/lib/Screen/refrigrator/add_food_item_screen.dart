import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/fridge/fridge_item_model.dart';
import '../../Providers/fridge_provider/refrigerator_provider.dart';

class AddFridgeItemScreen extends StatefulWidget {
  final String groupId;

  const AddFridgeItemScreen({super.key, required this.groupId});

  @override
  _AddFridgeItemScreenState createState() => _AddFridgeItemScreenState();
}

class _AddFridgeItemScreenState extends State<AddFridgeItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _quantity = 1;
  DateTime? _expiryDate;  // Khởi tạo là null

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Kiểm tra nếu ngày hết hạn chưa được chọn
      if (_expiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ngày hết hạn')),
        );
        return;
      }

      final newFridgeItem = FridgeItem(
        id: DateTime.now().toString(),
        name: _name,
        quantity: _quantity,
        expirationDate: _expiryDate!,
      );

      Provider.of<RefrigeratorProvider>(context, listen: false)
          // .addItem(newFridgeItem);
          .addItemToApi(widget.groupId, newFridgeItem);

      Navigator.pop(context);
    }
  }

  void _pickExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),  // Nếu chưa chọn thì không mặc định là ngày hôm nay
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _expiryDate = pickedDate;
        print(_expiryDate?.toIso8601String());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm Thực Phẩm',
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
                    _expiryDate == null
                        ? 'Chưa chọn ngày'
                        : 'Ngày hết hạn: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
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
                    'Thêm thực phẩm',
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