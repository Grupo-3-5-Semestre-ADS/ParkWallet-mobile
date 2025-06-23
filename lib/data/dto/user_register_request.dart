class UserRegisterRequest {
  final String name;
  final String cpf;
  final String birthDate;
  final String email;
  final String password;
  UserRegisterRequest({
    required this.name,
    required this.cpf,
    required this.birthDate,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cpf': cpf,
      'birthDate': birthDate,
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'UserRegisterRequest{name: $name, cpf: $cpf, birthDate: $birthDate, email: $email, password: $password}';
  }



}
