class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final String? major;
  final String? faculty;
  final String? imageUrl;
  final String role;
  final List<dynamic>? faceIdentityVector;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    this.major,
    this.faculty,
    this.imageUrl,
    required this.role,
    this.faceIdentityVector,
  });

    factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      major: json['major'],
      faculty: json['faculty'],
      imageUrl: json['image'],
      role: json['role'] ?? '', // Since role isn't in the response, providing a default
    );
  }
}
