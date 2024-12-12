import 'package:flutter/material.dart';

class FamilyGroupListScreen extends StatelessWidget {
  FamilyGroupListScreen({super.key});

  final List<Map<String, dynamic>> familyGroups = [
    {'name': 'Gia đình A', 'members': 5, 'role': 'Trưởng nhóm'},
    {'name': 'Gia đình B', 'members': 3, 'role': 'Thành viên'},
    {'name': 'Gia đình C', 'members': 4, 'role': 'Thành viên'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhóm gia đình'),
        backgroundColor: Colors.green[700],
      ),
      body: familyGroups.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: familyGroups.length,
              itemBuilder: (context, index) {
                final group = familyGroups[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.group, color: Colors.white),
                    ),
                    title: Text(group['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${group['members']} thành viên'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          group['role'],
                          style: TextStyle(
                            color: group['role'] == 'Trưởng nhóm' ? Colors.orange : Colors.grey,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, color: Colors.green),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/family-group-detail',
                              arguments: group,
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/family-group-detail',
                        arguments: group,
                      );
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'Danh sách trống. Nhấn + để thêm nhóm mới.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.pushNamed(context, '/create-family-group');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
