// family_group_screen.dart
import 'package:flutter/material.dart';

class FamilyGroupScreen extends StatefulWidget {
  const FamilyGroupScreen({super.key});

  @override
  State<FamilyGroupScreen> createState() => _FamilyGroupScreenState();
}

class _FamilyGroupScreenState extends State<FamilyGroupScreen> {
  final List<Map<String, dynamic>> _groups = [
    {
      'id': '1',
      'name': 'Nhóm Gia đình Nguyễn',
      'members': [
        {'id': '1', 'name': 'Nguyễn Văn A', 'username': 'nguyenvana', 'role': 'Trưởng nhóm'},
        {'id': '2', 'name': 'Nguyễn Thị B', 'username': 'nguyenthb', 'role': 'Thành viên'},
      ],
    },
    {
      'id': '2',
      'name': 'Nhóm Gia đình Trần',
      'members': [
        {'id': '1', 'name': 'Trần Văn C', 'username': 'tranvanc', 'role': 'Trưởng nhóm'},
        {'id': '2', 'name': 'Trần Thị D', 'username': 'tranthid', 'role': 'Thành viên'},
      ],
    },
  ];

  void _navigateToGroupDetails(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(group: group),
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
          _groups.add({
            'id': DateTime.now().toString(),
            'name': result['name'],
            'members': [],
          });
        });
      }
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _groups.length,
          itemBuilder: (context, index) {
            final group = _groups[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                title: Text(
                  group['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                onTap: () => _navigateToGroupDetails(group),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupDetailScreen extends StatelessWidget {
  final Map<String, dynamic> group;

  const GroupDetailScreen({required this.group, super.key});

  void _showInputDialog(BuildContext context, String title, Function(String) onSubmit) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nhập username'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = controller.text.trim();
                if (input.isNotEmpty) {
                  onSubmit(input);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = group['members'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          group['name'],
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
              'Thành viên:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(
                        member['name'][0],
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                    title: Text(member['name']),
                    subtitle: Text('${member['role']} - username: ${member['username']}'),
                  );
                },
              ),
            ),
            if (members.any((member) => member['role'] == 'Trưởng nhóm'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showInputDialog(
                      context,
                      'Thêm thành viên',
                      (input) {
                        // Add member logic here
                        print('Thêm thành viên: $input');
                      },
                    ),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Thêm thành viên'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showInputDialog(
                      context,
                      'Xóa thành viên',
                      (input) {
                        // Remove member logic here
                        print('Xóa thành viên: $input');
                      },
                    ),
                    icon: const Icon(Icons.person_remove),
                    label: const Text('Xóa thành viên'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                  ),
                ],
              ),
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
