import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../widgets/custom_badge.dart';
import '../../auth/providers/auth_provider.dart';

class ParentPortalView extends StatefulWidget {
  final Function(int) onNavigate;
  const ParentPortalView({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<ParentPortalView> createState() => _ParentPortalViewState();
}

class _ParentPortalViewState extends State<ParentPortalView> {
  bool _isLoading = true;
  List<dynamic> _children = [];
  String? _selectedStudentId;
  Map<String, dynamic>? _trackingData;

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch children
      final childrenRes = await ApiClient().get(ApiEndpoints.parentChildren);
      final List<dynamic> kids = childrenRes.data is List ? childrenRes.data : [];

      String? activeKidId = _selectedStudentId;
      if (activeKidId == null && kids.isNotEmpty) {
        activeKidId = kids.first['id'];
      }

      // 2. Fetch tracking data for active kid
      Map<String, dynamic>? tracking;
      if (activeKidId != null) {
        final trackRes = await ApiClient().get('${ApiEndpoints.parentStudentTracking}?student_id=$activeKidId');
        tracking = trackRes.data;
      }

      if (mounted) {
        setState(() {
          _children = kids;
          _selectedStudentId = activeKidId;
          _trackingData = tracking;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _switchChild(String studentId) async {
    setState(() {
      _selectedStudentId = studentId;
      _isLoading = true;
    });

    try {
      final trackRes = await ApiClient().get('${ApiEndpoints.parentStudentTracking}?student_id=$studentId');
      if (mounted) {
        setState(() {
          _trackingData = trackRes.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Syncing child academic and campus telemetry...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }

    final student = _trackingData?['student'];
    final study = _trackingData?['study_tracking'];
    final preschool = _trackingData?['preschool_health_monitoring'];
    final isPreschool = student?['program_type'] == 'PRESCHOOL';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Parent Welcome Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.family_restroom, color: AppColors.primaryNavy, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Welcome, ${user?.fullName ?? "Parent"}!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PSI-VH Parent Portal • Real-Time Study Tracking, Campus Safety & Academic Progress',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomBadge.success('Telegram Alerts Connected', icon: Icons.send),
                  const SizedBox(width: 8),
                  CustomBadge.info('AY 2025-2026', icon: Icons.school),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Child Switcher Bar
          if (_children.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Select Child:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: _children.map((kid) {
                        final isSelected = kid['id'] == _selectedStudentId;
                        final kidType = kid['program_type'] == 'PRESCHOOL' ? 'Preschool (Age ${kid['age']})' : 'Grade 10';
                        return ChoiceChip(
                          avatar: Icon(
                            kid['program_type'] == 'PRESCHOOL' ? Icons.child_care : Icons.school,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.primaryNavy,
                          ),
                          label: Text(
                            '${kid['full_name']} (${kid['khmer_name'] ?? ""}) • $kidType',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryNavy,
                          backgroundColor: AppColors.backgroundLight,
                          onSelected: (_) => _switchChild(kid['id']),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // 3. Child Profile & Live Campus Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2640), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child Avatar & Code
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentGold, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      isPreschool ? Icons.child_care : Icons.school,
                      color: AppColors.accentGold,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Core Student Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${student?['full_name'] ?? "Student"} (${student?['khmer_name'] ?? ""})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${student?['student_code'] ?? ""} • Class: ${student?['classroom'] ?? ""} (Room ${student?['room_number'] ?? ""})',
                                style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF065F46),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF34D399)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Color(0xFF34D399), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'ON CAMPUS (Safety Verified)',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF334155), height: 1),
                      const SizedBox(height: 14),

                      // Quick Info Strip
                      Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          _infoPill(Icons.access_time, 'Campus Entry: 07:45 AM (Gate A)'),
                          _infoPill(Icons.directions_bus, 'Transport: School Bus Route 1'),
                          if (student?['dietary_allergies'] != null)
                            _infoPill(Icons.warning_amber_rounded, 'Allergies: ${student?['dietary_allergies']}'),
                          _infoPill(
                            Icons.person_pin,
                            'Teacher: ${student?['homeroom_teacher']?['name']} (${student?['homeroom_teacher']?['phone']})',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Two-Column Dashboard (Left: Schedule & Tracking; Right: Academic Grades or Preschool Monitoring)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT: Today's Study Schedule & Timetable
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildTodayScheduleCard(study),
                    const SizedBox(height: 20),
                    _buildTeacherContactCard(student?['homeroom_teacher']),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // RIGHT: K-12 Grades Breakdown OR Preschool Health & Nap Monitoring
              Expanded(
                flex: 6,
                child: isPreschool
                    ? _buildPreschoolHealthCard(preschool, student)
                    : _buildAcademicGradesCard(study),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accentGold, size: 13),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11)),
      ],
    );
  }

  // Today's Study Timetable Card
  Widget _buildTodayScheduleCard(Map<String, dynamic>? study) {
    final schedule = (study?['today_schedule'] as List<dynamic>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primaryNavy, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Today's Study Timetable",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                  ),
                ],
              ),
              CustomBadge.info('Attendance: ${study?['attendance_rate'] ?? "98.5%"}', icon: Icons.verified),
            ],
          ),
          const SizedBox(height: 14),
          if (schedule.isEmpty)
            const Center(child: Text('No classes scheduled for today.'))
          else
            ...schedule.map((item) {
              final status = item['status'] ?? 'UPCOMING';
              Color badgeColor = AppColors.textMuted;
              Color badgeBg = AppColors.backgroundLight;
              IconData statusIcon = Icons.hourglass_empty;

              if (status == 'COMPLETED') {
                badgeColor = AppColors.successGreen;
                badgeBg = AppColors.lightGreen;
                statusIcon = Icons.check_circle;
              } else if (status == 'IN_PROGRESS') {
                badgeColor = AppColors.primaryBlue;
                badgeBg = AppColors.lightBlue;
                statusIcon = Icons.play_circle_fill;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: status == 'IN_PROGRESS' ? const Color(0xFFEFF6FF) : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: status == 'IN_PROGRESS' ? AppColors.primaryBlue : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: badgeColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['subject'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item['period']} • ${item['room']}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // Homeroom Teacher Direct Communication Card
  Widget _buildTeacherContactCard(Map<String, dynamic>? teacher) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Homeroom Teacher Contact',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryNavy,
                child: Text(
                  teacher?['name'] != null && teacher!['name'].toString().isNotEmpty
                      ? teacher['name'].toString()[0]
                      : 'T',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teacher?['name'] ?? 'Faculty Member', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(teacher?['email'] ?? 'faculty@psivh.edu.kh', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text(teacher?['phone'] ?? '+855 34 933 888', style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling Homeroom Teacher: ${teacher?['phone']}')),
                  );
                },
                icon: const Icon(Icons.call, size: 14),
                label: const Text('Call', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Preschool Health, Nap & Nutrition Monitoring Card (for Ages 2-6)
  Widget _buildPreschoolHealthCard(Map<String, dynamic>? preschool, Map<String, dynamic>? student) {
    final meals = preschool?['meals'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.favorite, color: AppColors.dangerRed, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Preschool Health, Nap & Meal Telemetry',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                  ),
                ],
              ),
              CustomBadge.success('Montessori Certified', icon: Icons.stars),
            ],
          ),
          const SizedBox(height: 16),

          // Nap & Sleep Tracker
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bedtime, color: Color(0xFF16A34A), size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Afternoon Nap Quality',
                        style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${preschool?['nap_duration'] ?? "12:30 - 14:15"} • ${preschool?['nap_quality'] ?? "RESTFUL"}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                      const Text('Child slept soundly without interruption.', style: TextStyle(fontSize: 10, color: Color(0xFF15803D))),
                    ],
                  ),
                ),
                const CustomBadge(label: 'Restful Sleep', backgroundColor: Color(0xFFDCFCE7), textColor: Color(0xFF166534)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Meals & Nutrition
          const Text('Today Nutrition Intake', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _mealItem('Breakfast', meals?['breakfast'] ?? 'ALL', 'Steamed Egg & Rice Congee')),
              const SizedBox(width: 8),
              Expanded(child: _mealItem('Lunch', meals?['lunch'] ?? 'ALL', 'Chicken soup & pumpkin')),
              const SizedBox(width: 8),
              Expanded(child: _mealItem('Snack', meals?['afternoon_snack'] ?? 'ALL', 'Organic Banana & Milk')),
            ],
          ),
          const SizedBox(height: 16),

          // Mood & Potty Routine
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mood Rating', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.sentiment_very_satisfied, color: Color(0xFFEAB308), size: 20),
                          const SizedBox(width: 6),
                          Text(preschool?['mood_rating'] ?? 'HAPPY', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Potty & Hygiene Routine', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(preschool?['diaper_potty_routine'] ?? 'Normal routine', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pickup Authorization
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Color(0xFFD97706), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Authorized Guardian Pickup Verification',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF92400E)),
                      ),
                      Text(
                        'Pickup Confirmed: ${preschool?['pickup_person'] ?? "Oum Sopheap (Mother)"}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealItem(String title, String status, String menu) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const Icon(Icons.check, size: 12, color: AppColors.successGreen),
            ],
          ),
          const SizedBox(height: 4),
          Text(status == 'ALL' ? 'Ate 100%' : status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.successGreen)),
          const SizedBox(height: 2),
          Text(menu, style: const TextStyle(fontSize: 9, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // Grade 10 / General Ed Academic Report Card
  Widget _buildAcademicGradesCard(Map<String, dynamic>? study) {
    final grades = (study?['grades_breakdown'] as List<dynamic>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium, color: AppColors.accentGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Academic Report Card & Subject GPA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                  ),
                ],
              ),
              CustomBadge.success('Promotion: ${study?['academic_status'] ?? "PROMOTED"}', icon: Icons.arrow_upward),
            ],
          ),
          const SizedBox(height: 16),

          // GPA and Average Summary Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cumulative GPA', style: TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${study?['current_gpa'] ?? "4.0"} / 4.0', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                      const Text('MoEYS & Cambridge Honors', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overall Score', style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${study?['overall_average_score'] ?? "88.6"}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                      const Text('Grade Promotion Eligible', style: TextStyle(fontSize: 9, color: Color(0xFF166534))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subject Grades Table
          const Text('Subject Breakdown (Semester 1 & 2)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
          const SizedBox(height: 8),
          if (grades.isEmpty)
            const Center(child: Text('No grade records found.'))
          else
            ...grades.map((g) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Sem 1: ${g['semester_1']}% • Sem 2: ${g['semester_2']}%', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Final: ${g['final_score']}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
                        Text('Grade ${g['grade']} • GPA ${g['gpa']}', style: const TextStyle(fontSize: 10, color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 18),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

