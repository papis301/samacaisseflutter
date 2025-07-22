class UserModel {
  final int? id;
  final String username;
  final String password;
  final String role;
  final String? lastLogin;
  final String? lastLogout;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.lastLogin,
    this.lastLogout,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'last_login': lastLogin,
      'last_logout': lastLogout,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      lastLogin: map['last_login'],
      lastLogout: map['last_logout'],
    );
  }
}
