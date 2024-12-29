import 'package:flutter/material.dart';
import 'group_detail_screen.dart';
import 'create_group_dialog.dart';
import 'package:meal_planner_app/Services/get_all_group.dart';
import 'package:meal_planner_app/Providers/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_planner_app/Providers/group_id_provider.dart';

class FamilyGroupScreen extends StatefulWidget {
  const FamilyGroupScreen({super.key});

  @override
  State<FamilyGroupScreen> createState() => _FamilyGroupScreenState();
}

class _FamilyGroupScreenState extends State<FamilyGroupScreen> {
  late Future<List<Map<String, dynamic>>> _groupsFuture;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _fetchGroups();
  }

  // Giữ nguyên logic của các methods
  Future<List<Map<String, dynamic>>> _fetchGroups() async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      final data = await ApiGetAllGroup.getFamilyGroups(accessToken ?? '');

      if (data.containsKey('groups')) {
        final List<Map<String, dynamic>> groups = List<Map<String, dynamic>>.from(data['groups']);
        final prefs = await SharedPreferences.getInstance();
        final List<String> groupIds = groups.map((group) => group['id'] as String).toList();
        await prefs.setStringList('groupIds', groupIds);
        return groups;
      } else {
        throw Exception('Dữ liệu từ API không hợp lệ.');
      }
    } catch (e) {
      print('Lỗi khi tải nhóm: $e');
      return [];
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

  Future<void> _saveSelectedGroupId(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGroupId', groupId);
  }

  void _showSuccessDialog(String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 10),
              const Text('Thành công'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Đã chọn nhóm thành công!'),
              const SizedBox(height: 8),
              Text(
                'ID nhóm: $groupId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/bottomnav');
              },
              child: Text(
                'Đóng',
                style: TextStyle(color: Colors.green[700]),
              ),
            ),
          ],
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Quản lý nhóm',
        style: TextStyle(
          color: Colors.green[700],
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.green[700],
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => const CreateGroupDialog(),
            ).then((result) {
              if (result != null) {
                setState(() {
                  _groupsFuture = _fetchGroups();
                });
              }
            });
          },
          icon: Icon(Icons.add, color: Colors.green[700]),
          label: Text(
            'Tạo nhóm',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: Container(
      color: Colors.grey[50],
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể tải danh sách nhóm',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có nhóm nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final groupId = group['id'];
                    final isSelected = _selectedGroupId == groupId;

                    return Card(
                      elevation: isSelected ? 2 : 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? Colors.green[700]! : Colors.transparent,
                          width: isSelected ? 2 : 0,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _selectedGroupId = groupId;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.group,
                                    color: Colors.green[700],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      group['groupName'] ?? 'Không có tên',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Radio<String>(
                                    value: groupId,
                                    groupValue: _selectedGroupId,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGroupId = value;
                                      });
                                    },
                                    activeColor: Colors.green[700],
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _navigateToGroupDetails(group),
                                    icon: const Icon(Icons.visibility_outlined),
                                    label: const Text('Chi tiết'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              if (_selectedGroupId != null)
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: () async {
        if (_selectedGroupId != null) {
          // Lưu groupId đã chọn
          await GroupIdProvider.saveSelectedGroupId(_selectedGroupId!);

          // Kiểm tra và in ra groupId đã lưu
          final savedGroupId = await GroupIdProvider.getSelectedGroupId();
          print('Group ID đã lưu: $savedGroupId'); // Kiểm tra log

          // Hiển thị thông báo cho người dùng
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã lưu Group ID: $savedGroupId')),
          );

          // Hiển thị hộp thoại thành công
          _showSuccessDialog(_selectedGroupId!);

          // Chuyển đến màn hình 'bottomnav'
          Navigator.pushReplacementNamed(context, 'bottomnav');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Xác nhận chọn nhóm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  ),

            ],
          );
        },
      ),
    ),
  );
  
}}