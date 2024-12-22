class User {
  int? id;
  String username;
  String fullName;
  String password;

  User({
    this.id,
    required this.username,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      fullName: map['full_name'],
      password: map['password'],
    );
  }
}
