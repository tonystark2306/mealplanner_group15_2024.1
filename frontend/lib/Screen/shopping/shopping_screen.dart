import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Providers/shopping_provider.dart';
import 'shopping_item_detail.dart';
import 'add_shopping_screen.dart';
import 'edit_shopping_screen.dart';

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

  Color _getDueDateColor(String? dueTime) {
    if (dueTime == null) return Colors.grey;
    final dueDate = DateTime.tryParse(dueTime);
    if (dueDate == null) return Colors.grey;

    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return Colors.red;
    } else if (difference.inDays < 1) {
      return Colors.orange;
    } else if (difference.inDays < 3) {
      return Colors.yellow;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoppingProvider = Provider.of<ShoppingProvider>(context);

    return Theme(
      data: theme.copyWith(
        // Tuỳ chỉnh CardTheme để bo góc và có bóng nhẹ
        cardTheme: CardTheme(
          elevation: 4, // Tăng chút để có hiệu ứng bóng rõ hơn
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green[700],
          centerTitle: true,
          title: const Text(
            'Danh sách shopping',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        body: FutureBuilder(
          future: _fetchShoppingListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load shopping list: ${snapshot.error}'),
              );
            } else if (shoppingProvider.shoppingList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hiện đang chưa có kế hoạch',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: shoppingProvider.shoppingList.length,
              itemBuilder: (context, index) {
                final item = shoppingProvider.shoppingList[index];
                final dueColor = _getDueDateColor(item.dueTime);

                // Đổi màu nền item khi đã hoàn thành
                final itemBackgroundColor = item.isDone
                    ? Colors.green[100]
                    : theme.cardColor;

                return Hero(
                  tag: 'shopping-item-${item.id}',
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Sửa',
                          onPressed: (context) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditShoppingItemScreen(
                                  shoppingItem: item,
                                ),
                              ),
                            );
                          },
                        ),
                        SlidableAction(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Xoá',
                          onPressed: (context) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xác nhận xoá'),
                                content:
                                    const Text('Bạn có chắc muốn xoá mục này?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Huỷ'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Xoá'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await shoppingProvider.deleteShoppingItem(item.id);
                            }
                          },
                        ),
                      ],
                    ),
                    child: Card(
                      color: itemBackgroundColor,
                      child: InkWell(
                        onTap: () {
                          // Mở dialog xem chi tiết với Hero animation
                          showDialog(
                            context: context,
                            builder: (context) => ShoppingItemDetailsDialog(
                              shoppingItemId: item.id,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item.isDone,
                                onChanged: (_) {
                                  shoppingProvider.toggleShoppingItemDone(
                                    item.id,
                                  );
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        decoration: item.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: item.isDone
                                            ? theme.disabledColor
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Giao cho: ${item.nameAssignedTo ?? 'N/A'}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Chip(
                                      label: Text(
                                        'Hạn: ${item.dueTime ?? 'Không có'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: dueColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddShoppingItemScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
