// group_detail_screen.dart
import 'package:flutter/material.dart';

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
