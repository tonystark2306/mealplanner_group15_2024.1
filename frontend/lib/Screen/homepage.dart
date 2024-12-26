import 'package:flutter/material.dart';
import 'package:meal_planner_app/Services/logoutservice.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

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
                child: const Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '• Rau cải - 2 bó\n• Thịt gà - 1kg\n• Táo - 3 quả',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        Icon(
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
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Xem, thêm hoặc chỉnh sửa công thức của bạn.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Icon(
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
        _buildDrawerItem(icon: Icons.person, text: 'Thông tin cá nhân', onTap: (){
            Navigator.pushNamed(context, '/user-info');
        }),
        _buildDrawerItem(icon: Icons.group, text: 'Quản lý thành viên nhóm', onTap: () {
            Navigator.pushNamed(context, '/family-group');
        }),
        _buildDrawerItem(icon: Icons.notifications, text: 'Cài đặt thông báo'),
        _buildDrawerItem(icon: Icons.star, text: 'Đánh giá ứng dụng'),
        _buildDrawerItem(icon: Icons.privacy_tip, text: 'Chính sách bảo mật'),
        
        const Divider(),
        _buildDrawerItem(icon: Icons.analytics, text: 'Thống kê báo cáo', onTap: () {
          Navigator.pushNamed(context, '/report');
        }),
        _buildDrawerItem(icon: Icons.menu_book, text: 'Quản lý công thức', onTap: () {
          Navigator.pushNamed(context, '/recipe-management');
        }),
        _buildDrawerItem(
          icon: Icons.logout,
          text: 'Đăng xuất',
          onTap: ()
          // {
          //   Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          // }
           async {
            // Hiển thị loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            try {
              // Gọi hàm logout
              await logoutUser();
              Navigator.pop(context); // Đóng loading indicator
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            } catch (error) {
              Navigator.pop(context); // Đóng loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        _buildDrawerItem(
  icon: Icons.delete,
  text: 'Xóa tài khoản',
  iconColor: Colors.red, // Màu đỏ cho icon
  textColor: Colors.red, // Màu đỏ cho text
  onTap: () {
    // Xử lý khi nhấn vào mục "Xóa tài khoản"
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc chắn muốn xóa tài khoản không? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Hủy bỏ xóa
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                // Thêm logic xóa tài khoản tại đây
                print('Tài khoản đã được xóa.');
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  },
),


      ],
    ),
  );
}


  Widget _buildDrawerItem({
  required IconData icon,
  required String text,
  void Function()? onTap,
  Color? iconColor,
  Color? textColor,
}) {
  return ListTile(
    leading: Icon(icon, color: iconColor ?? Colors.green[700]),
    title: Text(text, style: TextStyle(color: textColor ?? Colors.green[700])),
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
