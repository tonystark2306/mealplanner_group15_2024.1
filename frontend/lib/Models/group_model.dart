class FamilyGroup {
  final String id;
  final String groupName;
  final String? adminId;
  final String? createdAt;

  FamilyGroup({
    required this.id,
    required this.groupName,
    this.adminId,
    this.createdAt,
  });

  factory FamilyGroup.fromJson(Map<String, dynamic> json) {
    return FamilyGroup(
      id: json['id'] ?? '',
      groupName: json['groupName'] ?? 'Không tên', // Sử dụng groupName từ API
      adminId: json['adminId'], // Sử dụng adminId từ API
      createdAt: json['createdAt'], // Sử dụng createdAt từ API
    );
  }
}
