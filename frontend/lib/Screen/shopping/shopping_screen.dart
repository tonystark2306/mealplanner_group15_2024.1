import 'package:flutter/material.dart';
import 'add_shopping_screen.dart';
import 'edit_shopping_screen.dart';
import 'package:provider/provider.dart';
import '../../Providers/shopping_provider.dart';
import 'package:intl/intl.dart';

import 'shopping_item_detail.dart'; // Để định dạng ngày tháng

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
    return DateFormat('yyyy-MM-dd – kk:mm')
        .format(dateTime); // Định dạng ngày giờ
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = Provider.of<ShoppingProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping List',
          style:
              TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
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
            // Kiểm tra nếu shopping list trống
            if (shoppingProvider.shoppingList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Hiện đang chưa có kế hoạch',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding:
                    EdgeInsets.all(8), // Thêm padding cho toàn bộ list view
                itemCount: shoppingProvider.shoppingList.length,
                itemBuilder: (context, index) {
                  final shoppingItem = shoppingProvider.shoppingList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(
                        vertical: 8), // Thêm khoảng cách giữa các item
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
                            'Giao cho: ${shoppingItem.nameAssignedTo ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hạn: ${shoppingItem.dueTime ?? 'No due date'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Giảm kích thước row để vừa với nút
                        children: [
                          // Nút Xoá
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Hiển thị Dialog xác nhận trước khi xóa
                              bool? confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text(
                                        'Are you sure you want to delete this item?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(false); // Không xóa
                                        },
                                        child: Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(true); // Xóa
                                        },
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Nếu người dùng chọn "Yes", thực hiện xóa
                              if (confirmDelete == true) {
                                try {
                                  // Gọi hàm xóa từ provider
                                  await shoppingProvider
                                      .deleteShoppingItem(shoppingItem.id);
                                } catch (error) {
                                  // Xử lý lỗi nếu có
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to delete item: $error')),
                                  );
                                }
                              }
                            },
                          ),
                          // Nút Sửa
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Điều hướng đến màn hình chỉnh sửa shopping item
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditShoppingItemScreen(
                                    shoppingItem:
                                        shoppingItem, // Truyền shopping item để chỉnh sửa
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      leading: Checkbox(
                        value: shoppingItem.isDone,
                        onChanged: (_) {
                          shoppingProvider
                              .toggleShoppingItemDone(shoppingItem.id);
                        },
                      ),
                      onTap: () {
                        // Gọi Dialog khi người dùng chọn shopping item
                        showDialog(
                          context: context,
                          builder: (context) => ShoppingItemDetailsDialog(
                              shoppingItemId: shoppingItem.id),
                        );
                      },
                    ),
                  );
                },
              );
            }
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
