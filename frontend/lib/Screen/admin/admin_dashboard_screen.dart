// screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white, // Màu chữ
            fontSize: 20, // Kích thước chữ (tuỳ chỉnh)
            fontWeight: FontWeight.bold, // Kiểu chữ đậm (tuỳ chọn)
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        actions: [
          // Nút Đăng xuất
          TextButton.icon(
            onPressed: () {
              // Logic để logout
              Navigator.pushReplacementNamed(context, '/login'); // Chuyển về màn hình đăng nhập
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.red, // Icon màu đỏ
            ),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.red, // Chữ màu đỏ
                fontWeight: FontWeight.bold, // Chữ đậm
              ),
            ),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        children: [
          _buildAdminTile(
            context,
            'Quản lý người dùng',
            Icons.people,
            () => Navigator.pushNamed(context, '/admin/users'),
          ),
          _buildAdminTile(
            context,
            'Quản lý danh mục',
            Icons.category,
            () => Navigator.pushNamed(context, '/admin-categories'),
          ),
          _buildAdminTile(
            context,
            'Quản lý đơn vị',
            Icons.straighten,
            () => Navigator.pushNamed(context, '/admin-unit'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.green[700]),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
