import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/fridge/group_model.dart';

class GroupFridgeProvider with ChangeNotifier {
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  // Hàm tải danh sách nhóm từ backend
  Future<void> loadGroupsFromApi() async {
    final url = 'http://localhost:5000/api/user/group';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQ1MDFhZDgtNWE0ZS00OTI5LWE3YzItYjhhMjU1OTU2NDE1IiwiZXhwIjoxNzM1MjU3NTA4fQ.PWYwn3v7tVT9G6cyrpMGPPfCEzuTx57jlFQVxvZjWwg', // Thay 'YOUR_TOKEN' bằng token người dùng
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loadedGroups = (data['groups'] as List)
            .map((group) => Group.fromJson(group))
            .toList();
        _groups = loadedGroups;
        notifyListeners();
      } else {
        throw Exception('Failed to load groups');
      }
    } catch (error) {
      throw error;
    }
  }
}
