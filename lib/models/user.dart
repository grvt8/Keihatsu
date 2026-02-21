class User {
  final String id;
  final String? googleId;
  final String email;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? username;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final bool isOnboarded;
  final bool isProfilePublic;
  final dynamic readingStats;
  final int achievementCount;
  final int points;

  User({
    required this.id,
    this.googleId,
    required this.email,
    this.avatarUrl,
    this.bannerUrl,
    this.username,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.isOnboarded = false,
    this.isProfilePublic = true,
    this.readingStats,
    this.achievementCount = 0,
    this.points = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      googleId: json['googleId'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      bannerUrl: json['bannerUrl'],
      username: json['username'],
      bio: json['bio'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      isOnboarded: json['isOnboarded'] ?? false,
      isProfilePublic: json['isProfilePublic'] ?? true,
      readingStats: json['readingStats'],
      achievementCount: json['achievementCount'] ?? 0,
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'googleId': googleId,
      'email': email,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'username': username,
      'bio': bio,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isOnboarded': isOnboarded,
      'isProfilePublic': isProfilePublic,
      'readingStats': readingStats,
      'achievementCount': achievementCount,
      'points': points,
    };
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
