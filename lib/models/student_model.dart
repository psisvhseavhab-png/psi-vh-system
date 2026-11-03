class StudentModel {
  final String id;
  final String studentCode;
  final String fullName;
  final String? khmerName;
  final String gender;
  final int age;
  final String programType; // PRESCHOOL, GENERAL_ED, PART_TIME_LANGUAGE
  final String? guardianName;
  final String? guardianPhone;
  final String? authorizedPickups;
  final String? dietaryAllergies;
  final String qrCode;

  StudentModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    this.khmerName,
    required this.gender,
    required this.age,
    required this.programType,
    this.guardianName,
    this.guardianPhone,
    this.authorizedPickups,
    this.dietaryAllergies,
    required this.qrCode,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      studentCode: json['student_code'] ?? '',
      fullName: json['full_name'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      khmerName: json['khmer_name'],
      gender: json['gender'] ?? 'MALE',
      age: (json['age'] as num?)?.toInt() ?? 5,
      programType: json['program_type'] ?? 'GENERAL_ED',
      guardianName: json['guardian_name'],
      guardianPhone: json['guardian_phone'],
      authorizedPickups: json['authorized_pickups'] ?? json['authorized_pickup_names'],
      dietaryAllergies: json['dietary_allergies'],
      qrCode: json['qr_gate_pass_code'] ?? 'QR-${json['student_code'] ?? ''}',
    );
  }
}

