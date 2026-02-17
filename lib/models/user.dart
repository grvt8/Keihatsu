class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String? googleId;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.googleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'], // Handle both potential id fields
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      googleId: json['googleId'],
    );
  }
}

class AuthResponse {
  final String accessToken;
  final User user;

  AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      user: User.fromJson(json['user']),
    );
  }
}
