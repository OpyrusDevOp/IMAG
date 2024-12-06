class User {
  int id;
  String username;
  String password;
  UserRole role = UserRole.regular;

  User(
      {this.id = 0,
      required this.username,
      required this.password,
      required this.role});

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password': password,
        'role': role.index
      };

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'] as int,
        username: map['username'] as String,
        password: map['password'] as String,
        role: UserRole.values[map['role'] as int]);
  }
}

enum UserRole { admin, regular }
