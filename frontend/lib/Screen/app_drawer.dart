import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import các service bạn cần dùng:
import 'package:meal_planner_app/Services/logoutservice.dart';
import 'package:meal_planner_app/Services/delete_account_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Drawer
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[700]),
            child: const Text(
              'Một ngày thật tốt lành!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          // Các item trong Drawer
          _buildDrawerItem(
            icon: Icons.person,
            text: 'Thông tin cá nhân',
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.pushNamed(context, '/user-info');
            },
          ),
          _buildDrawerItem(
            icon: Icons.group,
            text: 'Quản lý nhóm',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/family-group');
            },
          ),
          _buildDrawerItem(
            icon: Icons.food_bank,
            text: 'Quản lý thực phẩm',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/food-management');
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            text: 'Cài đặt thông báo',
            onTap: () {
              // Xử lý khi bấm
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.star,
            text: 'Đánh giá ứng dụng',
            onTap: () {
              Navigator.pop(context);
              // Xử lý khi bấm
            },
          ),
          _buildDrawerItem(
            icon: Icons.privacy_tip,
            text: 'Chính sách bảo mật',
            onTap: () {
              Navigator.pop(context);
              // Xử lý khi bấm
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.analytics,
            text: 'Thống kê báo cáo',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/report');
            },
          ),
          _buildDrawerItem(
            icon: Icons.menu_book,
            text: 'Quản lý công thức',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/recipe-management');
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Đăng xuất',
            onTap: () async {
              // Hiển thị loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await logoutUser();
                Navigator.pop(context); // tắt dialog
                // Điều hướng về màn hình đăng nhập, xóa hết stack
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } catch (error) {
                Navigator.pop(context); // tắt dialog
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
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context); // đóng Drawer
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text(
                      'Bạn có chắc chắn muốn xóa tài khoản không? Hành động này không thể hoàn tác.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Hủy
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          Navigator.pop(context); // đóng dialog

                          // Hiển thị thông báo đang xử lý
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đang xóa tài khoản...'),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          // Gọi API xóa tài khoản
                          bool success = await DeleteUserApi.deleteUser();

                          if (success) {
                            // Thông báo xóa thành công
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Xóa tài khoản thành công!'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Điều hướng về màn hình đăng nhập
                            Navigator.pushReplacementNamed(context, '/login');
                          } else {
                            // Thông báo xóa thất bại
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Xóa tài khoản thất bại, vui lòng thử lại.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Xóa',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  /// Đây là hàm dùng chung để build các item trong Drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.green[700]),
      title: Text(
        text,
        style: TextStyle(color: textColor ?? Colors.green[700]),
      ),
      onTap: onTap,
    );
  }
}
