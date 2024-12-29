// family_group_screen.dart
import 'package:flutter/material.dart';
import 'group_detail_screen.dart';
import 'create_group_dialog.dart';
import 'package:meal_planner_app/Services/get_all_group.dart';
import 'package:meal_planner_app/Providers/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyGroupScreen extends StatefulWidget {
  const FamilyGroupScreen({super.key});

  @override
  State<FamilyGroupScreen> createState() => _FamilyGroupScreenState();
}

class _FamilyGroupScreenState extends State<FamilyGroupScreen> {
  late Future<List<Map<String, dynamic>>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _fetchGroups(); // Khởi tạo ngay lập tức
  }

  Future<List<Map<String, dynamic>>> _fetchGroups() async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      final data = await ApiGetAllGroup.getFamilyGroups(accessToken ?? '');

      if (data.containsKey('groups')) {
        final List<Map<String, dynamic>> groups = List<Map<String, dynamic>>.from(data['groups']);

        // Lưu danh sách groupId vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final List<String> groupIds = groups.map((group) => group['id'] as String).toList();
        await prefs.setStringList('groupIds', groupIds);

        print('Group IDs saved: $groupIds'); // Debug: Kiểm tra danh sách groupId

        return groups;
      } else {
        throw Exception('Dữ liệu từ API không hợp lệ.');
      }
    } catch (e) {
      print('Lỗi khi tải nhóm: $e');
      return []; // Trả về danh sách trống nếu có lỗi
    }
  }

  void _navigateToGroupDetails(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(
          groupId: group['id'],
          groupName: group['groupName'],
        ),
      ),
    );
  }

  void _createGroup() {
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    ).then((result) {
      if (result != null) {
        setState(() {
          _groupsFuture = _groupsFuture.then((groups) {
            groups.add({
              'id': DateTime.now().toString(),
              'groupName': result['name'], // Đảm bảo sử dụng đúng key 'groupName'
              'members': [],
            });

            // Lưu groupId mới vào SharedPreferences
            _saveGroupId(groups.map((group) => group['id'] as String).toList());

            return groups;
          });
        });
      }
    });
  }

  Future<void> _saveGroupId(List<String> groupIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('groupIds', groupIds);
    print('Updated Group IDs: $groupIds');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Quản lý nhóm gia đình',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải danh sách nhóm: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có nhóm nào.'));
          }

          final groups = snapshot.data!;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupName = group['groupName'] ?? 'Tên nhóm không xác định';
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  title: Text(
                    groupName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                  onTap: () => _navigateToGroupDetails(group),
                ),
              );
            },
          );
        },
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải danh sách nhóm: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có nhóm nào.'));
          }

          final groups = snapshot.data!;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupName = group['groupName'] ?? 'Tên nhóm không xác định';
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  title: Text(
                    groupName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                  onTap: () => _navigateToGroupDetails(group),
                ),
              );
            },
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}
