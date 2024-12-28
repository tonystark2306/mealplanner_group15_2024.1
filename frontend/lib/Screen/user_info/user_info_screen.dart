// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:meal_planner_app/Providers/token_storage.dart';
import 'package:meal_planner_app/Services/get_user_info.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  //bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Map<String, dynamic>? _userData; // Để lưu thông tin người dùng
  // Mock data - replace with actual user data

  @override
  void initState() {
    super.initState();
    _fetchAndSetUserInfo(); // Gọi hàm lấy thông tin người dùng khi màn hình mở
  }

  final List<String> _languages = ['Tiếng Việt', 'English'];
  final List<String> _timezones = ['GMT+7'];

  Future<void> _fetchAndSetUserInfo() async {
    setState(() => _isLoading = true);
    final userInfo = await fetchUserInfo(); // Gọi hàm API
    if (userInfo != null) {
      setState(() {
        _userData = userInfo;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lấy thông tin người dùng')),
      );
    }
  }


  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() => _isLoading = true);
        // TODO: Implement API call to upload image
        // final response = await uploadProfileImage(File(image.path));
        // setState(() {
        //   _userData['avatarUrl'] = response.data['url'];
        // });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editField(String field, String currentValue) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditFieldDialog(
        field: field,
        currentValue: currentValue,
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        // TODO: Implement API call to update field
        // await updateUserField(field, result);
        setState(() {
          if (_userData != null) {
            _userData![field] = result;
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công')),
      );
    }
  }

  @override
  @override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('Không thể tải thông tin người dùng'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildAvatarSection(),
                      const SizedBox(height: 20),
                      _buildInfoCard(),
                    ],
                  ),
                ),
    );
  }


  Widget _buildAvatarSection() {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.green[100],
        backgroundImage: _userData!['avatar_url'] != null
            ? NetworkImage(_userData!['avatar_url'])
            : null,
        child: _userData!['avatar_url'] == null
            ? Icon(Icons.person, size: 60, color: Colors.green[700])
            : null,
      ),
    );
  }


  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.green[700]),
                const SizedBox(width: 10),
                Text(
                  'Thông tin cơ bản',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Tên đăng nhập', _userData!['username']),
            const Divider(),
            _buildInfoRow('Họ và tên', _userData!['name']),
          ],
        ),
      ),
    );
  }


  Widget _buildPreferencesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.green[700]),
                const SizedBox(width: 10),
                Text(
                  'Tùy chọn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownRow(
              'Ngôn ngữ',
              _userData != null ? _userData!['language'] : '',
              _languages,
              (value) {
                if (value != null) {
                  setState(() {
                    if (_userData != null) {
                      _userData!['language'] = value;
                    }
                  });
                }
              },
            ),
            const Divider(),
            _buildDropdownRow(
              'Múi giờ',
              _userData != null ? _userData!['timezone'] : '',
              _timezones,
              (value) {
                if (value != null) {
                  setState(() {
                    if (_userData != null) {
                      _userData!['timezone'] = value;
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.green[700]),
                const SizedBox(width: 10),
                Text(
                  'Bảo mật',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock),
                label: const Text('Đổi mật khẩu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.green[700])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


  Widget _buildDropdownRow(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.green[700])),
          DropdownButton<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// edit_field_dialog.dart
class EditFieldDialog extends StatefulWidget {
  final String field;
  final String currentValue;

  const EditFieldDialog({
    super.key,
    required this.field,
    required this.currentValue,
  });

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Chỉnh sửa ${widget.field}',
        style: TextStyle(color: Colors.green[700]),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.field,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập ${widget.field}';
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
              Navigator.pop(context, _controller.text);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

// change_password_dialog.dart
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // TODO: Implement API call to change password
        // await changePassword(
        //   _oldPasswordController.text,
        //   _newPasswordController.text,
        // );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Đổi mật khẩu',
        style: TextStyle(color: Colors.green[700]),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu cũ',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu cũ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới';
                  }
                if (value.length < 8) {
                  return 'Mật khẩu phải có ít nhất 8 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu mới';
                }
                if (value != _newPasswordController.text) {
                  return 'Mật khẩu xác nhận không khớp';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Xác nhận'),
        ),
      ],
    );
  }
}

// Service để gọi API
class ProfileService {
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1)); // Mock API delay
      // throw Exception('Test error');
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin: $e');
    }
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1)); // Mock API delay
      // throw Exception('Test error');
    } catch (e) {
      throw Exception('Không thể đổi mật khẩu: $e');
    }
  }

  static Future<void> uploadAvatar(File file) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1)); // Mock API delay
      // throw Exception('Test error');
    } catch (e) {
      throw Exception('Không thể tải lên ảnh đại diện: $e');
    }
  }

  
}