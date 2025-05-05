class PPE {
  final int id;
  final String name;

  PPE({
    required this.id,
    required this.name,
  });

  factory PPE.fromJson(Map<String, dynamic> json) {
    return PPE(
      id: json['id'],
      name: json['name'],
    );
  }
}
