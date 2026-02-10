class UserModel {
  final int id;
  final int nik;
  final String fullName;
  final String department;
  final String role;
  final String token;

  UserModel({
    required this.id,
    required this.nik,
    required this.fullName,
    required this.department,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      id: json['id'],
      nik: json['nik'],
      fullName: json['full_name'],
      department: json['department'],
      role: json['role'],
      token: token,
    );
  }
}
