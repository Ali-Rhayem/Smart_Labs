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
}
