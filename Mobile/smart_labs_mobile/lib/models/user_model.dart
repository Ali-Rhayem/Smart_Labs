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
  final bool isFirstLogin;

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
    required this.isFirstLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      major: json['major'],
      faculty: json['faculty'],
      imageUrl: json['image'],
      role: json['role'] ??
          '',
      isFirstLogin: json['isFirstLogin'] ?? false,
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? major,
    String? faculty,
    String? imageUrl,
    bool? isFirstLogin,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      major: major ?? this.major,
      faculty: faculty ?? this.faculty,
      imageUrl: imageUrl ?? this.imageUrl,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      faceIdentityVector: faceIdentityVector,
    );
  }
}
