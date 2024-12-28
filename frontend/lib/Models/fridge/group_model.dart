import 'dart:convert';

class Group {
  final String id;
  final String name;

  Group({
    required this.id,
    required this.name,
  });

  // Hàm tạo đối tượng Group từ JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['groupName'],
    );
  }

}
