class User {
  final int id;
  final String name;
  final String email;
  final String initials;
  final double weight;
  final bool onboarded;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.weight,
    required this.onboarded,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      initials: json['initials'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      onboarded: json['onboarded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'initials': initials,
      'weight': weight,
      'onboarded': onboarded,
    };
  }
}
