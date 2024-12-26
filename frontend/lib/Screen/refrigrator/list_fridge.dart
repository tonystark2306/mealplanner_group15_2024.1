import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/fridge_provider/list_group_provider.dart';  // Giả sử bạn đã tạo provider để lấy nhóm người dùng
import './refrigerator_management_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  Future<void> _loadUserGroups() async {
    try {
      await Provider.of<GroupFridgeProvider>(context, listen: false).loadGroupsFromApi();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải nhóm')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách tủ lạnh',
          style: TextStyle(
            color: Colors.white, // Màu chữ trắng
            fontWeight: FontWeight.bold, // Chữ đậm
          ),
        ),
        backgroundColor: Colors.green[700], // Nền AppBar màu xanh
        centerTitle: true,
        elevation: 0, // Không có bóng đổ
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<GroupFridgeProvider>(
              builder: (context, groupProvider, child) {
                final groups = groupProvider.groups;
                return ListView.builder(
                  padding: EdgeInsets.all(8.0), // Thêm padding cho ListView
                  itemCount: groups.length,
                  itemBuilder: (ctx, index) {
                    final group = groups[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0), // Khoảng cách giữa các Card
                      elevation: 5.0, // Độ dày bóng đổ của card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Bo góc cho card
                      ),
                      color: Colors.grey[200], // Nền màu sáng cho card
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding cho nội dung ListTile
                        leading: Icon(
                          Icons.kitchen, // Icon cho tủ lạnh
                          color: Colors.green[700], // Màu xanh cho icon
                        ),
                        title: Text(
                          'Tủ lạnh của ${group.name}', // Tên nhóm
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700], // Chữ màu xanh cho tên nhóm
                          ),
                        ),
                        subtitle: Text(
                          'Nhóm ID: ${group.id}', // Hiển thị ID của nhóm dưới dạng phụ
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]), // Thêm icon mũi tên
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RefrigeratorManagementScreen(groupId: group.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
