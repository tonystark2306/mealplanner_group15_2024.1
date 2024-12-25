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
            return Center(child: const Text("Lỗi khi tải dữ liệu"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: const Text("Không có dữ liệu"));
          }

          final fridgeItem = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fridgeItem['image'] != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        fridgeItem['image'],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Icon(
                      Icons.food_bank,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  fridgeItem['name'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.countertops,
                  title: 'Số lượng',
                  value: '${fridgeItem['quantity']} ${fridgeItem['unit']}',
                ),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  title: 'Ngày hết hạn',
                  value: fridgeItem['expirationDate'],
                  valueStyle: const TextStyle(color: Colors.red),
                ),
                _buildDetailRow(
                  icon: Icons.category,
                  title: 'Loại',
                  value: fridgeItem['type'],
                ),
                _buildDetailRow(
                  icon: Icons.label,
                  title: 'Danh mục',
                  value: fridgeItem['category'],
                ),
                if (fridgeItem['notes'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 24, thickness: 1),
                      const Text(
                        'Ghi chú',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fridgeItem['notes'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị một hàng thông tin chi tiết
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 16,
                  ),
            ),
          ),
        ],
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
