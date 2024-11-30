import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Tạo key cho Scaffold

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Gắn key vào Scaffold
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Căn giữa tiêu đề
        title: Text(
          'Đi Chợ Tiện Lợi',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.green[700]),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Mở Drawer bằng key
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.green[700]),
            onPressed: () {
              // Xử lý thông báo
            },
          ),
        ],
      ),
      drawer: _buildDrawer(), // Thêm Drawer chứa các danh mục
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Tủ Lạnh Của Bạn',
              icon: Icons.kitchen,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng số mặt hàng:',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                      Text(
                        '15/50',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.3,
                    backgroundColor: Colors.green[100],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip('Còn hạn', Colors.green),
                      _buildStatusChip('Sắp hết hạn', Colors.orange),
                      _buildStatusChip('Đã hết hạn', Colors.red),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Kế Hoạch Bữa Ăn Hôm Nay',
              icon: Icons.restaurant_menu,
              child: Column(
                children: [
                  _buildMealPlanItem('Bữa Sáng', 'Bánh mì trứng'),
                  _buildMealPlanItem('Bữa Trưa', 'Cơm chiên'),
                  _buildMealPlanItem('Bữa Tối', 'Canh cá'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickActionButton(
                  icon: Icons.shopping_cart,
                  label: 'Danh Sách Mua Sắm',
                  onPressed: () {},
                ),
                _buildQuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Thêm Mặt Hàng',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[700]),
            child: const Text(
              'Have a nice day, user!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem(icon: Icons.group, text: 'Quản lý thành viên nhóm'),
          _buildDrawerItem(icon: Icons.notifications, text: 'Cài đặt thông báo'),
          _buildDrawerItem(icon: Icons.star, text: 'Đánh giá ứng dụng'),
          _buildDrawerItem(icon: Icons.privacy_tip, text: 'Chính sách bảo mật'),
          _buildDrawerItem(icon: Icons.help, text: 'Hướng dẫn sử dụng'),
          const Divider(),
          _buildDrawerItem(icon: Icons.logout, text: 'Đăng xuất'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(text, style: TextStyle(color: Colors.green[700])),
      onTap: () {
        // Đóng Drawer
        _scaffoldKey.currentState?.closeDrawer();
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green[700]),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  Widget _buildMealPlanItem(String meal, String dish) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(meal, style: TextStyle(color: Colors.green[700])),
          Text(dish, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(color: Colors.green[700], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
