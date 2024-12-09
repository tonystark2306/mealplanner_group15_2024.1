import 'package:flutter/material.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<Map<String, String>> _shoppingList = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  void _addItem() {
    final item = _itemController.text.trim();
    final quantity = _quantityController.text.trim();

    if (item.isNotEmpty && quantity.isNotEmpty) {
      setState(() {
        _shoppingList.add({'item': item, 'quantity': quantity});
      });
      _itemController.clear();
      _quantityController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thêm thực phẩm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    labelText: 'Tên thực phẩm',
                    hintText: 'Ví dụ: Rau cải',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Định lượng',
                    hintText: 'Ví dụ: 500g, 1 bó',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text(
                        'Thêm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeItem(int index) {
    setState(() {
      _shoppingList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Danh sách mua sắm',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _shoppingList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: Colors.green[200],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Danh sách trống',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nhấn vào nút "+" ở góc dưới để thêm thực phẩm.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _shoppingList.length,
                itemBuilder: (context, index) {
                  final item = _shoppingList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(
                        item['item']!,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Định lượng: ${item['quantity']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _showAddItemDialog,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green[700],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
