class UserProfile {
  final String name;
  final String email;
  final String cpf;
  final DateTime birthdate;

  UserProfile({
    required this.name,
    required this.email,
    required this.cpf,
    required this.birthdate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['email'],
      cpf: json['cpf'],
      birthdate: DateTime.parse(json['birthdate']),
    );
  }

  @override
  String toString() {
    return 'UserProfile{name: $name, email: $email, cpf: $cpf, birthdate: $birthdate}';
  }
}
