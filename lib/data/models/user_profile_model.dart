class UserProfileModel {
  const UserProfileModel({this.username = defaultUsername, this.avatarPath});

  static const String defaultUsername = 'Task Hero';

  final String username;
  final String? avatarPath;

  UserProfileModel copyWith({String? username, String? avatarPath}) {
    return UserProfileModel(
      username: _safeUsername(username ?? this.username),
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'avatarPath': avatarPath};
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      username: _safeUsername(json['username']),
      avatarPath: _safeOptionalString(json['avatarPath']),
    );
  }

  static String _safeUsername(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return defaultUsername;
  }

  static String? _safeOptionalString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }
}
