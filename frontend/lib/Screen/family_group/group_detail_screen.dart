import 'package:flutter/material.dart';
import 'package:meal_planner_app/Services/get_group_details.dart';
import 'package:meal_planner_app/Providers/token_storage.dart';
import 'package:meal_planner_app/Services/add_member_service.dart';
import 'package:meal_planner_app/Services/remove_member_service.dart';


class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late Future<Map<String, dynamic>> _groupDetailsFuture;

  @override
  void initState() {
    super.initState();
    _groupDetailsFuture = _fetchGroupDetails();
  }

  Future<void> _showAddMemberDialog(BuildContext context, String groupId) async {
    final TextEditingController usernameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm thành viên'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Nhập username',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text.trim();
                if (username.isNotEmpty) {
                  Navigator.pop(context); // Đóng popup
                  await _addMemberToGroup(groupId, username);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addMemberToGroup(String groupId, String username) async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      await AddMemberService.addMember(accessToken ?? '', groupId, [username]);

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm thành viên thành công.')),
      );

      // Cập nhật thông tin chi tiết nhóm
      setState(() {
        _groupDetailsFuture = _fetchGroupDetails();
      });
    } catch (e) {
      // Hiển thị lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm thành viên: $e')),
      );
    }
  }

  Future<void> _showRemoveMemberDialog(BuildContext context, String groupId) async {
    final TextEditingController usernameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa thành viên'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Nhập username',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text.trim();
                if (username.isNotEmpty) {
                  Navigator.pop(context); // Đóng popup
                  await _removeMemberFromGroup(groupId, username);
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeMemberFromGroup(String groupId, String username) async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      await RemoveMemberService.removeMember(accessToken ?? '', groupId, username);

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa thành viên thành công.')),
      );

      // Cập nhật thông tin chi tiết nhóm
      setState(() {
        _groupDetailsFuture = _fetchGroupDetails();
      });
    } catch (e) {
      // Hiển thị lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa thành viên: $e')),
      );
    }
  }




  Future<Map<String, dynamic>> _fetchGroupDetails() async {
    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'];
    return ApiGetGroupDetails.getGroupDetails(accessToken ?? '', widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.groupName,
          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _groupDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải chi tiết nhóm: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có thông tin nhóm.'));
          }

          final groupDetails = snapshot.data!;
          final members = List<Map<String, dynamic>>.from(groupDetails['members'] ?? []);
          final adminId = groupDetails['groupAdmin'];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isAdmin = member['id'] == adminId;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: member['avatar_url'] != null
                            ? NetworkImage(member['avatar_url'])
                            : null,
                        child: member['avatar_url'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(member['name'] ?? 'Tên không xác định'),
                      subtitle: Text(member['username']),
                      trailing: isAdmin
                          ? const Text(
                              'Trưởng nhóm',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            )
                          : const Text('Thành viên'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddMemberDialog(context, widget.groupId),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text('Thêm thành viên', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showRemoveMemberDialog(context, widget.groupId),
                      icon: const Icon(Icons.person_remove, color: Colors.white,),
                      label: const Text('Xóa thành viên', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}
