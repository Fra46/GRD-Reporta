class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool active;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'coordinador',
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'active': active,
    };
  }
}