import 'package:flutter/material.dart';
import 'add_shopping_screen.dart';
import 'package:provider/provider.dart';
import '../../Providers/shopping_provider.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày tháng

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late Future<void> _fetchShoppingListFuture;

  @override
  void initState() {
    super.initState();
    _fetchShoppingListFuture =
        Provider.of<ShoppingProvider>(context, listen: false)
            .fetchShoppingList();
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'No due date';
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime); // Định dạng ngày giờ
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = Provider.of<ShoppingProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping List',
          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.green[700]),
      ),
      body: FutureBuilder(
        future: _fetchShoppingListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load shopping list: ${snapshot.error}'),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(8), // Thêm padding cho toàn bộ list view
              itemCount: shoppingProvider.shoppingList.length,
              itemBuilder: (context, index) {
                final shoppingItem = shoppingProvider.shoppingList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8), // Thêm khoảng cách giữa các item
                  elevation: 3,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      shoppingItem.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: shoppingItem.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Assigned to: ${shoppingItem.assignedTo ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Due: ${shoppingItem.dueTime}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        shoppingProvider.deleteShoppingItem(shoppingItem.id);
                      },
                    ),
                    leading: Checkbox(
                      value: shoppingItem.isDone,
                      onChanged: (_) {
                        shoppingProvider.toggleShoppingItemDone(shoppingItem.id);
                      },
                    ),
                    onTap: () {
                      // Navigate to task management screen
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddShoppingItemScreen()),
          );
        },
      ),
    );
  }
}
