enum UserRole {
  farmer,
  agent,
  driver,
  receiver,
  admin,
}

extension UserRoleExtension on UserRole {
  String toShortString() {
    switch (this) {
      case UserRole.farmer:
        return 'FARMER';
      case UserRole.agent:
        return 'AGENT';
      case UserRole.driver:
        return 'DRIVER';
      case UserRole.receiver:
        return 'RECEIVER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'FARMER':
        return UserRole.farmer;
      case 'AGENT':
        return UserRole.agent;
      case 'DRIVER':
        return UserRole.driver;
      case 'RECEIVER':
        return UserRole.receiver;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.farmer;
    }
  }
}

class User {
  final String id;
  final String phone;
  final String? email;
  final String fullName;
  final UserRole role;
  final bool isActive;
  final String createdAt;

  User({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      fullName: json['fullName'] ?? '',
      role: UserRoleExtension.fromString(json['role'] ?? 'FARMER'),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'fullName': fullName,
      'role': role.toShortString(),
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
