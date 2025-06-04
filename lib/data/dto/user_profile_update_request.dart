class UserProfileUpdateRequest {
  final String name;
  final String birthDate;
  final String email;

  UserProfileUpdateRequest({
    required this.name,
    required this.birthDate,
    required this.email
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthdate': birthDate,
      'email': email
    };
  }
}