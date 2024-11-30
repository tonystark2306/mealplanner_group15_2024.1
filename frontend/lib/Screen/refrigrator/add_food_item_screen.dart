import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/food_item_model.dart';
import '../../Providers/refrigerator_provider.dart';

class AddFoodItemScreen extends StatefulWidget {
  @override
  _AddFoodItemScreenState createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends State<AddFoodItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _quantity = 1;
  DateTime _expiryDate = DateTime.now();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newFoodItem = FoodItem(
        id: DateTime.now().toString(),
        name: _name,
        quantity: _quantity,
        expiryDate: _expiryDate,
      );

      Provider.of<RefrigeratorProvider>(context, listen: false)
          .addItem(newFoodItem);

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
                decoration: InputDecoration(labelText: 'Tên thực phẩm'),
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
                decoration: InputDecoration(labelText: 'Số lượng'),
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
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Ngày hết hạn: ${_expiryDate.toLocal().toString().split(' ')[0]}',
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: _pickExpiryDate,
                    child: Text('Chọn ngày'),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
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
