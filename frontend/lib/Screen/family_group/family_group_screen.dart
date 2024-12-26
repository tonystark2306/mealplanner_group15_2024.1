// family_group_screen.dart
import 'package:flutter/material.dart';
import 'package:meal_planner_app/Models/group_model.dart';
import 'package:meal_planner_app/Services/get_all_group.dart';
import 'package:meal_planner_app/Providers/token_storage.dart';

class FamilyGroupScreen extends StatefulWidget {
  const FamilyGroupScreen({super.key});

  @override
  State<FamilyGroupScreen> createState() => _FamilyGroupScreenState();
}

class _FamilyGroupScreenState extends State<FamilyGroupScreen> {
  List<FamilyGroup> _familyGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFamilyGroups();
  }

  Future<void> _fetchFamilyGroups() async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];

      if (accessToken == null) {

        throw Exception('Access token is null');

      }

      final response = await ApiGetAllGroup.getFamilyGroups(accessToken);
      print('API response: , $response');

      if (response['resultCode'] == '00094') {
        setState(() {
          _familyGroups = (response['groups'] as List)
              .map((data) => FamilyGroup.fromJson(data))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Lỗi: ${response['resultMessage']['vn']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _navigateToGroupDetails(FamilyGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(group: group),
      ),
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
          'Quản lý nhóm gia đình',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _familyGroups.length,
                itemBuilder: (context, index) {
                  final group = _familyGroups[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      title: Text(
                        group.groupName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      //subtitle: Text('ID: ${group.id}'),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                      onTap: () => _navigateToGroupDetails(group),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupDetailScreen extends StatelessWidget {
  final FamilyGroup group;

  const GroupDetailScreen({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          group.groupName,
          style: TextStyle(color: Colors.green[700]),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi tiết nhóm:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            Text('ID nhóm: ${group.id}'),
            Text('Người quản trị: ${group.adminId}'),
            Text('Ngày tạo: ${group.createdAt}'),
          ],
        ),
      ),
    );
  }
}

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Tạo nhóm mới',
        style: TextStyle(color: Colors.green[700]),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Tên nhóm',
            hintText: 'Nhập tên nhóm gia đình',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên nhóm';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                {'name': _nameController.text},
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
          ),
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}
