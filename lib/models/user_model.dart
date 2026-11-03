class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? khmerName;
  final String role;
  final String? departmentId;
  final String? phone;
  final String? telegramChatId;
  final String employmentType;
  final double baseSalaryUsd;
  final double hourlyRateUsd;
  final int numDependents;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.khmerName,
    required this.role,
    this.departmentId,
    this.phone,
    this.telegramChatId,
    required this.employmentType,
    required this.baseSalaryUsd,
    required this.hourlyRateUsd,
    required this.numDependents,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      khmerName: json['khmer_name'],
      role: json['role'] ?? 'TEACHER',
      departmentId: json['department_id'],
      phone: json['phone'],
      telegramChatId: json['telegram_chat_id'],
      employmentType: json['employment_type'] ?? 'FULL_TIME',
      baseSalaryUsd: (json['base_salary_usd'] as num?)?.toDouble() ?? 0.0,
      hourlyRateUsd: (json['hourly_rate_usd'] as num?)?.toDouble() ?? 12.0,
      numDependents: (json['num_dependents'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'khmer_name': khmerName,
    'role': role,
    'department_id': departmentId,
    'phone': phone,
    'telegram_chat_id': telegramChatId,
    'employment_type': employmentType,
    'base_salary_usd': baseSalaryUsd,
    'hourly_rate_usd': hourlyRateUsd,
    'num_dependents': numDependents,
    'is_active': isActive,
  };
}

