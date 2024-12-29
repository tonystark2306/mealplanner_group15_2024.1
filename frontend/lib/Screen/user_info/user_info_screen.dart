// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:meal_planner_app/Providers/token_storage.dart';
import 'package:meal_planner_app/Services/get_user_info.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  final List<String> _languages = ['Tiếng Việt'];
  final List<String> _timezones = ['GMT+7'];

  @override
  void initState() {
    super.initState();
    _fetchAndSetUserInfo();
  }

  Future<void> _fetchAndSetUserInfo() async {
    setState(() => _isLoading = true);
    final userInfo = await fetchUserInfo();
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

  Future<void> _updateUserProfile(Map<String, dynamic> updatedFields) async {
    const String apiUrl = 'http://127.0.0.1:5000/api/user/'; // Thay URL thật
    try {
      setState(() => _isLoading = true);
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'] ?? '';

      if (accessToken.isEmpty) {
        throw Exception('Access token không tồn tại.');
      }

      final request = http.MultipartRequest('PUT', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $accessToken';

      // Thêm các trường vào request
      updatedFields.forEach((key, value) {
        if (value is http.MultipartFile) {
          request.files.add(value);
        } else if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData =
            json.decode(await response.stream.bytesToString());
        if (responseData['resultCode'] == '00086') {
          setState(() {
            _userData = responseData['updatedUser'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['resultMessage']['vn'])),
          );
        } else {
          throw Exception(responseData['resultMessage']['vn']);
        }
      } else {
        throw Exception('Username này đang được sử dụng. Vui lòng nhập username khác.');
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

    if (result != null && result != currentValue) {
      await _updateUserProfile({field: result});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        // Đọc dữ liệu từ ảnh và lấy tên file
        final imageBytes = await image.readAsBytes();
        final fileName = image.name;

        // Gửi dữ liệu qua API
        await _updateUserProfile({
          'image': http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: fileName,
          ),
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải ảnh lên: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildPreferencesCard(),
                  const SizedBox(height: 20),
                  _buildSecurityCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green[100],
            backgroundImage: _userData!['avatar_url'] != null
                ? NetworkImage(_userData!['avatar_url'])
                : null,
            child: _userData!['avatar_url'] == null
                ? Icon(Icons.person, size: 60, color: Colors.green[700])
                : null,
          ),
          TextButton(
            onPressed: _pickImage,
            child: const Text('Cập nhật ảnh đại diện'),
          ),
        ],
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
            _buildInfoRow('Username', _userData!['username'], 'username'),
            const Divider(),
            _buildInfoRow('Họ và tên', _userData!['name'], 'name'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.green[700])),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.green[700]),
            onPressed: () => _editField(field, value),
          ),
        ],
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
              _languages[0],
              _languages,
              (value) {
                if (value != null) {
                  setState(() => _userData!['language'] = value);
                }
              },
            ),
            const Divider(),
            _buildDropdownRow(
              'Múi giờ',
              _timezones[0],
              _timezones,
              (value) {
                if (value != null) {
                  setState(() => _userData!['timezone'] = value);
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
                onPressed: () {},
                icon: const Icon(Icons.lock, color: Colors.white),
                label: const Text(
                                    'Đổi mật khẩu',
                                    style: TextStyle(
                                      color: Colors.white, // Màu chữ
                                      fontWeight: FontWeight.bold, // Bôi đậm
                                    ),
                                  ),
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
          child: const Text(
                              'Lưu',
                              style: TextStyle(
                                color: Colors.white, // Màu chữ
                                fontWeight: FontWeight.bold, // Bôi đậm
                              ),
                            ),
        ),
      ],
    );
  }
}
