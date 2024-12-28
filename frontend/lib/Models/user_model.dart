class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }
}