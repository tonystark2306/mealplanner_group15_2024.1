import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/fridge/fridge_item_model.dart';
import '../../Providers/fridge_provider/refrigerator_provider.dart';

class EditFridgeItemScreen extends StatefulWidget {
  final FridgeItem fridgeItem; // Nhận FridgeItem cần chỉnh sửa
  final String groupId;

  const EditFridgeItemScreen({super.key, required this.fridgeItem, required this.groupId});

  @override
  _EditFridgeItemScreenState createState() => _EditFridgeItemScreenState();
}

class _EditFridgeItemScreenState extends State<EditFridgeItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _quantity;
  late DateTime _expiryDate;
  late List<String> _foodNames;

  @override
  void initState() {
    super.initState();
    _name = widget.fridgeItem.name;
    _quantity = widget.fridgeItem.quantity;
    _expiryDate = widget.fridgeItem.expirationDate;
    _loadFoodNames();
  }

  // Hàm gọi fetchFoodNames từ Provider
  Future<void> _loadFoodNames() async {
    try {
      await Provider.of<RefrigeratorProvider>(context, listen: false)
          .fetchFoodNames(widget.groupId);
    } catch (error) {
      print('Error loading food names: $error');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedFridgeItem = FridgeItem(
        id: widget.fridgeItem.id,
        name: _name,
        quantity: _quantity,
        expirationDate: _expiryDate,
      );

      try {
        await Provider.of<RefrigeratorProvider>(context, listen: false)
            .updateItemInApi(context, widget.groupId, updatedFridgeItem);

        Navigator.pop(context);
      } catch (error) {
        print('Error: $error');
      }
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
        child: Consumer<RefrigeratorProvider>(
          builder: (context, provider, child) {
            _foodNames = provider.foodNames;

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown để chọn thực phẩm
                  DropdownButtonFormField<String>(
                    value: _name.isEmpty ? null : _name,
                    decoration: InputDecoration(
                      labelText: 'Tên thực phẩm',
                      labelStyle: TextStyle(color: Colors.green[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                      ),
                    ),
                    items: _foodNames.isEmpty
                        ? [DropdownMenuItem<String>(value: '', child: Text('Không có thực phẩm'))]
                        : _foodNames.map((foodName) {
                            return DropdownMenuItem<String>(
                              value: foodName,
                              child: Text(foodName),
                            );
                          }).toList(),
                    onChanged: (selectedFood) {
                      if (selectedFood != null) {
                        setState(() {
                          _name = selectedFood;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn tên thực phẩm';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: _quantity.toString(),
                    decoration: InputDecoration(
                      labelText: 'Số lượng',
                      labelStyle: TextStyle(color: Colors.green[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                      ),
                    ),
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
                            : 'Ngày hết hạn: ${_expiryDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.green[700]),
                        onPressed: _pickExpiryDate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
            );
          },
        ),
      ),
    );
  }
}
