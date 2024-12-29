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
  DateTime? _expiryDate;
  List<String> _foodNames = [];

  @override
  void initState() {
    super.initState();
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

      try {
        await Provider.of<RefrigeratorProvider>(context, listen: false)
            .addItemToApi(context, widget.groupId, newFridgeItem);

        Navigator.pop(context);
      } catch (error) {
        print('Error: $error');
      }
    }
  }

  void _pickExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
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
        child: Consumer<RefrigeratorProvider>(
          builder: (context, provider, child) {
            _foodNames = provider.foodNames;  // Lấy danh sách thực phẩm từ provider

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
                            : 'Ngày hết hạn: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
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
                        'Thêm thực phẩm',
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
