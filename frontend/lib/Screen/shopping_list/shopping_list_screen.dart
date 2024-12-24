import 'package:flutter/material.dart';
import '../../Models/shopping_list_model.dart'; // Import model ShoppingList

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<ShoppingList> shoppingLists = []; // Danh sách tất cả các ngày mua sắm

  final TextEditingController _itemController = TextEditingController(); // Controller cho item mới
  final TextEditingController _dateController = TextEditingController(); // Controller cho ngày mua sắm

  // Hàm chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != DateTime.now()) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Định dạng ngày theo YYYY-MM-DD
      });
    }
  }

  void _addItem(ShoppingList shoppingList) {
    if (_itemController.text.isNotEmpty) {
      setState(() {
        shoppingList.items.add(ShoppingItem(name: _itemController.text));
      });
      _itemController.clear();
    }
  }

  void _toggleItemPurchase(ShoppingList shoppingList, int index) {
    setState(() {
      shoppingList.items[index].isPurchased = !shoppingList.items[index].isPurchased;
    });
  }

  void _editItem(ShoppingList shoppingList, int index) {
    _itemController.text = shoppingList.items[index].name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa món đồ'),
        content: TextField(
          controller: _itemController,
          decoration: const InputDecoration(hintText: 'Nhập món đồ'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                shoppingList.items[index].name = _itemController.text;
              });
              _itemController.clear();
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _removeItem(ShoppingList shoppingList, int index) {
    setState(() {
      shoppingList.items.removeAt(index);
    });
  }

  void _addShoppingList() {
    if (_dateController.text.isNotEmpty) {
      setState(() {
        shoppingLists.add(ShoppingList(date: _dateController.text));
      });
      _dateController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách mua sắm',
          style:
              TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Ngày mua sắm',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true, // Chỉ đọc, không cho nhập tay
                    onTap: () => _selectDate(context), // Chọn ngày khi tap vào TextField
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addShoppingList,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: shoppingLists.length,
                itemBuilder: (context, index) {
                  ShoppingList shoppingList = shoppingLists[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(shoppingList.date),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Có thể mở màn hình chỉnh sửa ngày mua sắm
                            },
                          ),
                        ),
                        for (int i = 0; i < shoppingList.items.length; i++)
                          ListTile(
                            title: Text(shoppingList.items[i].name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: shoppingList.items[i].isPurchased,
                                  onChanged: (_) {
                                    _toggleItemPurchase(shoppingList, i);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editItem(shoppingList, i),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeItem(shoppingList, i),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _itemController,
                                  decoration: const InputDecoration(
                                    labelText: 'Thêm món đồ',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _addItem(shoppingList),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
