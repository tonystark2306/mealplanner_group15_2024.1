// create_group_dialog.dart
import 'package:flutter/material.dart';
import 'package:meal_planner_app/Services/create_group_service.dart';

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
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang tạo nhóm...'),
                  duration: Duration(seconds: 2),
                ),
              );

              // Gọi API tạo nhóm
              final bool success = await createGroupApi(
                _nameController.text, // Tên nhóm
                [], // Ban đầu danh sách thành viên để trống
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tạo nhóm thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(
                  context,
                  {'name': _nameController.text},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tạo nhóm thất bại, vui lòng thử lại.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
