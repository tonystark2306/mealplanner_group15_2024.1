// screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green[700],
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
            () => Navigator.pushNamed(context, '/admin/categories'),
          ),
          _buildAdminTile(
            context,
            'Quản lý đơn vị',
            Icons.straighten,
            () => Navigator.pushNamed(context, '/admin/units'),
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