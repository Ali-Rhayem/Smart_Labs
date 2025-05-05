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
  final bool firstLogin;

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
    required this.firstLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      major: json['major'],
      faculty: json['faculty'],
      imageUrl: json['image'],
      role: json['role'] ?? '',
      firstLogin: json['first_login'] ?? true,
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? major,
    String? faculty,
    String? imageUrl,
    bool? firstLogin,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      major: major ?? this.major,
      faculty: faculty ?? this.faculty,
      imageUrl: imageUrl ?? this.imageUrl,
      faceIdentityVector: faceIdentityVector,
      firstLogin: firstLogin ?? this.firstLogin,
    );
  }
}
