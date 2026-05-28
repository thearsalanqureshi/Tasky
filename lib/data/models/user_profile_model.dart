class UserProfileModel {
  const UserProfileModel({required this.username, this.avatarPath});

  final String username;
  final String? avatarPath;

  Map<String, dynamic> toJson() {
    return {'username': username, 'avatarPath': avatarPath};
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      username: json['username'] as String? ?? '',
      avatarPath: json['avatarPath'] as String?,
    );
  }
}
