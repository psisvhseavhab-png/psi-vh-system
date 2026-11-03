class PreschoolDailyLogModel {
  final String studentId;
  final String fullName;
  final String? khmerName;
  final int age;
  final String? allergies;
  final String napQuality;
  final String napStart;
  final String napEnd;
  final String lunchStatus;
  final String moodRating;
  final bool pickupVerified;
  final String? pickupName;

  PreschoolDailyLogModel({
    required this.studentId,
    required this.fullName,
    this.khmerName,
    required this.age,
    this.allergies,
    required this.napQuality,
    required this.napStart,
    required this.napEnd,
    required this.lunchStatus,
    required this.moodRating,
    required this.pickupVerified,
    this.pickupName,
  });

  factory PreschoolDailyLogModel.fromJson(Map<String, dynamic> json) {
    final log = json['today_log'];
    return PreschoolDailyLogModel(
      studentId: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      khmerName: json['khmer_name'],
      age: json['age'] ?? 3,
      allergies: json['dietary_allergies'],
      napQuality: log != null ? log['nap_quality'] ?? 'RESTFUL' : 'Not Logged',
      napStart: log != null ? log['nap_start'] ?? '12:30' : '12:30',
      napEnd: log != null ? log['nap_end'] ?? '14:00' : '14:00',
      lunchStatus: log != null ? log['lunch_status'] ?? 'ALL' : 'Pending',
      moodRating: log != null ? log['mood_rating'] ?? 'HAPPY' : 'Pending',
      pickupVerified: log != null ? log['pickup_verified'] ?? false : false,
      pickupName: log != null ? log['pickup_name'] : null,
    );
  }
}

class ClassRoomModel {
  final String id;
  final int gradeLevel;
  final String sectionName;
  final String academicYear;
  final String? roomNumber;
  final int enrolledStudents;
  final int maxCapacity;
  final String homeroomTeacher;

  ClassRoomModel({
    required this.id,
    required this.gradeLevel,
    required this.sectionName,
    required this.academicYear,
    this.roomNumber,
    required this.enrolledStudents,
    required this.maxCapacity,
    required this.homeroomTeacher,
  });

  factory ClassRoomModel.fromJson(Map<String, dynamic> json) {
    return ClassRoomModel(
      id: json['id'] ?? '',
      gradeLevel: json['grade_level'] ?? 1,
      sectionName: json['section_name'] ?? '',
      academicYear: json['academic_year'] ?? '2026-2027',
      roomNumber: json['room_number'],
      enrolledStudents: json['enrolled_students'] ?? 0,
      maxCapacity: json['max_capacity'] ?? 30,
      homeroomTeacher: json['homeroom_teacher'] ?? 'Unassigned',
    );
  }
}

class PartTimeShiftModel {
  final String id;
  final String language; // KHMER, ENGLISH, CHINESE
  final String courseLevel;
  final String shiftType; // MORNING, AFTERNOON, EVENING, WEEKEND
  final String shiftName;
  final String daysPattern;
  final String startTime;
  final String endTime;
  final double hourlyRateUsd;
  final double monthlyFeeUsd;
  final int enrolledCount;
  final String teacherName;

  PartTimeShiftModel({
    required this.id,
    required this.language,
    required this.courseLevel,
    required this.shiftType,
    required this.shiftName,
    required this.daysPattern,
    required this.startTime,
    required this.endTime,
    required this.hourlyRateUsd,
    required this.monthlyFeeUsd,
    required this.enrolledCount,
    required this.teacherName,
  });

  factory PartTimeShiftModel.fromJson(Map<String, dynamic> json) {
    return PartTimeShiftModel(
      id: json['id'] ?? '',
      language: json['language'] ?? 'ENGLISH',
      courseLevel: json['course_level'] ?? '',
      shiftType: json['shift_type'] ?? 'EVENING',
      shiftName: json['shift_name'] ?? '',
      daysPattern: json['days_pattern'] ?? 'Mon-Wed-Fri',
      startTime: json['start_time'] ?? '17:30',
      endTime: json['end_time'] ?? '19:00',
      hourlyRateUsd: (json['hourly_rate_usd'] as num?)?.toDouble() ?? 14.0,
      monthlyFeeUsd: (json['monthly_fee_usd'] as num?)?.toDouble() ?? 45.0,
      enrolledCount: json['enrolled_count'] ?? 0,
      teacherName: json['teacher_name'] ?? 'Instructor',
    );
  }
}

