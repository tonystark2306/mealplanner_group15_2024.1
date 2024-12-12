import 'package:flutter/material.dart';

class FamilyGroupDetailScreen extends StatelessWidget {
  const FamilyGroupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final group = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(group['name']),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên nhóm: ${group['name']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Thành viên: ${group['members']} người',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Vai trò của bạn: ${group['role']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              'Danh sách mua sắm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            const SizedBox(height: 10),
            _buildShoppingList(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                onPressed: () {
                  // Điều hướng đến màn hình tạo danh sách mới
                  Navigator.pushNamed(context, '/create-shopping-list');
                },
                child: const Text('Chia sẻ danh sách'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingList() {
    // Danh sách mẫu để hiển thị danh sách mua sắm
    final shoppingItems = [
      'Rau cải - 2 bó',
      'Thịt gà - 1kg',
      'Táo - 3 quả',
    ];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: shoppingItems.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text('• ${shoppingItems[index]}', style: TextStyle(fontSize: 16)),
        );
      },
    );
  }
}
