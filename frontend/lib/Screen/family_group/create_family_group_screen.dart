import 'package:flutter/material.dart';

class CreateFamilyGroupScreen extends StatefulWidget {
  const CreateFamilyGroupScreen({super.key});

  @override
  State<CreateFamilyGroupScreen> createState() => _CreateFamilyGroupScreenState();
}

class _CreateFamilyGroupScreenState extends State<CreateFamilyGroupScreen> {
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo nhóm mới'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tên nhóm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập tên nhóm gia đình',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                onPressed: () {
                  final groupName = _groupNameController.text;
                  if (groupName.isNotEmpty) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create-shopping-list');
                  }
                },
                child: const Text('Tạo nhóm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
