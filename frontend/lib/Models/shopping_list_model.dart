// shopping_list.dart
class ShoppingItem {
  String name; // Tên món đồ
  bool isPurchased; // Trạng thái đã mua hay chưa

  ShoppingItem({
    required this.name,
    this.isPurchased = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isPurchased': isPurchased,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      name: map['name'],
      isPurchased: map['isPurchased'] ?? false,
    );
  }
}

class ShoppingList {
  String date; // Ngày của danh sách mua sắm
  List<ShoppingItem> items; // Các món đồ trong danh sách

  ShoppingList({
    required this.date,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      date: map['date'],
      items: List<ShoppingItem>.from(
        map['items']?.map((x) => ShoppingItem.fromMap(x))),
    );
  }
}
