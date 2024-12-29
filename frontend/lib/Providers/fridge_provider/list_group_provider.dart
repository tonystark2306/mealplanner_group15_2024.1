import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/fridge/group_model.dart';
import '../token_storage.dart';

class GroupFridgeProvider with ChangeNotifier {
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  // Hàm tải danh sách nhóm từ backend
  Future<void> loadGroupsFromApi() async {
    final url = 'http://localhost:5000/api/user/group';
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${tokenObject['accessToken']}', // Thay 'YOUR_TOKEN' bằng token người dùng
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
