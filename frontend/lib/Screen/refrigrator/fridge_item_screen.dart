import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FridgeItemDetailScreen extends StatelessWidget {
  final String fridgeItemId;

  const FridgeItemDetailScreen({super.key, required this.fridgeItemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết món đồ"),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchFridgeItemDetail(fridgeItemId), // Hàm fetch API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi khi tải dữ liệu"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Không có dữ liệu"));
          }

          final fridgeItem = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fridgeItem['image'] != null)
                  Center(
                    child: Image.network(
                      fridgeItem['image'],
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  fridgeItem['name'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Số lượng: ${fridgeItem['quantity']} ${fridgeItem['unit']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ngày hết hạn: ${fridgeItem['expirationDate']}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loại: ${fridgeItem['type']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Danh mục: ${fridgeItem['category']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (fridgeItem['notes'] != null)
                  Text(
                    'Ghi chú: ${fridgeItem['notes']}',
                    style: const TextStyle(
                        fontSize: 16, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hàm fetch dữ liệu chi tiết món đồ từ API
  Future<Map<String, dynamic>> _fetchFridgeItemDetail(String id) async {
    // final response =
    //     await http.get(Uri.parse('http://localhost:5000/api/food-item/$id'));
    // if (response.statusCode == 200) {
    //   return Map<String, dynamic>.from(json.decode(response.body));
    // } else {
    //   throw Exception('Failed to load food item');
    // }
    return {
      'name': 'Thịt bò',
      'quantity': 1,
      'unit': 'kg',
      'expirationDate': '2022-12-31',
      'type': 'Thực phẩm',
      'category': 'Thịt',
      'notes': 'Mua ở siêu thị A',
      'image':
          'https://cdn.tgdd.vn/Products/Images/8783/220833/iphone-13-pro-max-xanh-duong-600x600.jpg',
    };
  }
}
