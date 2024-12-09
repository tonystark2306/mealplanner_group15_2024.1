import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Đi chợ tiện lợi',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.green[700]),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.green[700]),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.analytics, color: Colors.green[700]),
            onPressed: () {
              Navigator.pushNamed(context, '/report');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Tủ lạnh của bạn',
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
              title: 'Kế hoạch bữa ăn hôm nay',
              icon: Icons.restaurant_menu,
              child: Column(
                children: [
                  _buildMealPlanItem('Bữa sáng', 'Bánh mì trứng'),
                  _buildMealPlanItem('Bữa trưa', 'Cơm chiên'),
                  _buildMealPlanItem('Bữa tối', 'Canh cá'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Danh sách cần mua',
              icon: Icons.shopping_cart,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/shopping-list');
                },
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '• Rau cải - 2 bó\n• Thịt gà - 1kg\n• Táo - 3 quả',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.green,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Quản lý công thức',
              icon: Icons.menu_book,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/recipe-management');
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Xem, thêm hoặc chỉnh sửa công thức của bạn.',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
          _buildDrawerItem(icon: Icons.analytics, text: 'Thống kê báo cáo', onTap: () {
            Navigator.pushNamed(context, '/report');
          }),
          _buildDrawerItem(icon: Icons.menu_book, text: 'Quản lý công thức', onTap: () {
            Navigator.pushNamed(context, '/recipe-management');
          }),
          _buildDrawerItem(icon: Icons.logout, text: 'Đăng xuất'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, void Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(text, style: TextStyle(color: Colors.green[700])),
      onTap: onTap ?? () {
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
}
