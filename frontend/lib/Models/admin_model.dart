class Admin {
  final String id;
  final String name;
  final String email;
  final List<String> permissions;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.permissions,
  });

  // Tạo Admin object từ JSON
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  // Convert Admin object thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'permissions': permissions,
    };
  }
}
