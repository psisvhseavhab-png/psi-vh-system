import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../widgets/custom_badge.dart';

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({Key? key}) : super(key: key);

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Data lists
  List<dynamic> _preschoolStudents = [];
  List<dynamic> _generalEdClasses = [];
  List<dynamic> _languageShifts = [];

  // Selected class for G1-12
  String? _selectedClassId;
  List<dynamic> _classStudents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final resPre = await ApiClient().get(ApiEndpoints.preschoolStudents);
      final resGen = await ApiClient().get(ApiEndpoints.generalEdClasses);
      final resLang = await ApiClient().get(ApiEndpoints.partTimeShifts);

      if (mounted) {
        setState(() {
          _preschoolStudents = resPre.data;
          _generalEdClasses = resGen.data;
          _languageShifts = resLang.data;

          if (_generalEdClasses.isNotEmpty) {
            _selectedClassId = _generalEdClasses.first['id'];
            _loadClassStudents(_selectedClassId!);
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClassStudents(String classId) async {
    try {
      final res = await ApiClient().get(ApiEndpoints.classStudents(classId));
      if (mounted) {
        setState(() {
          _classStudents = res.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Top Navigation Bar
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Academic Structure & Curriculum Programs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Early Learners Preschool • Grades 1-12 General Ed • Part-Time Language Center',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: AppColors.primaryNavy,
                    labelColor: AppColors.primaryNavy,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    tabs: const [
                      Tab(text: 'Preschool (Ages 2-6) & Health Log'),
                      Tab(text: 'General Ed (Grades 1-12) & Grading'),
                      Tab(text: 'Part-Time Languages (EN/KH/ZH)'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPreschoolTab(),
                      _buildGeneralEdTab(),
                      _buildPartTimeLanguagesTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: PRESCHOOL (AGES 2-6) ====================
  Widget _buildPreschoolTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Preschool Daily Health, Nap & Guardian Pickup Monitoring',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              CustomBadge.info('Toddlers 2-6 Years', icon: Icons.child_friendly),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
              columns: const [
                DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Age / Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Dietary & Allergies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Nap Schedule & Quality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Meals Intake', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Mood Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Pickup Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _preschoolStudents.map((s) {
                final log = s['today_log'];
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s['full_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(s['student_code'], style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    DataCell(Text('${s['age']} yrs • ${s['gender']}', style: const TextStyle(fontSize: 11))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (s['dietary_allergies'] ?? '').toString().contains('peanut')
                              ? AppColors.lightRed
                              : AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s['dietary_allergies'] ?? 'None',
                          style: TextStyle(
                            fontSize: 10,
                            color: (s['dietary_allergies'] ?? '').toString().contains('peanut')
                                ? AppColors.dangerRed
                                : AppColors.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        log != null
                            ? '${log['nap_start']} - ${log['nap_end']} (${log['nap_quality']})'
                            : 'Pending',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        log != null ? 'Lunch: ${log['lunch_status']}' : 'Pending',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      CustomBadge(
                        label: log != null ? log['mood_rating'] : 'Normal',
                        backgroundColor: AppColors.lightGold,
                        textColor: AppColors.accentGold,
                      ),
                    ),
                    DataCell(
                      log != null && log['pickup_verified'] == true
                          ? CustomBadge.success('Picked: ${log['pickup_name'] ?? 'Guardian'}')
                          : CustomBadge.warning('Awaiting Pickup'),
                    ),
                    DataCell(
                      OutlinedButton(
                        onPressed: () => _showPreschoolLogDialog(s),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: const Text('Update Log', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: GENERAL EDUCATION (GRADES 1-12) ====================
  Widget _buildGeneralEdTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Select Classroom: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedClassId,
                    items: _generalEdClasses.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['id'],
                        child: Text('${c['section_name']} (Room ${c['room_number']})', style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedClassId = val);
                        _loadClassStudents(val);
                      }
                    },
                  ),
                ],
              ),
              CustomBadge.success('Promotion Threshold: >= 50% Final GPA'),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
              columns: const [
                DataColumn(label: Text('Student Name & ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Average Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('GPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Subject Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Promotion Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _classStudents.map((s) {
                final subjects = (s['subject_grades'] as List?) ?? [];
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s['full_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(s['student_code'], style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    DataCell(Text('${s['average_score']}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataCell(Text('${s['gpa']} / 4.0', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                    DataCell(
                      Wrap(
                        spacing: 4,
                        children: subjects.map((sub) {
                          return Chip(
                            padding: EdgeInsets.zero,
                            label: Text(
                              '${sub['subject_name']}: ${sub['final_score']} (${sub['letter_grade']})',
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    DataCell(
                      s['is_promoted'] == true
                          ? CustomBadge.success('PROMOTED TO NEXT GRADE')
                          : CustomBadge.danger('UNDER ACADEMIC REVIEW'),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: PART-TIME LANGUAGES ====================
  Widget _buildPartTimeLanguagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Flexible Language Shifts: Khmer • English • Chinese (Mandarin)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              CustomBadge(
                label: 'Minute-by-Minute Wage Engine Compatible',
                backgroundColor: AppColors.lightGreen,
                textColor: AppColors.successGreen,
                icon: Icons.timer,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 900 ? 3 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: _languageShifts.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final sh = _languageShifts[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomBadge.info(sh['language']),
                            Text(
                              sh['shift_type'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Text(
                          sh['course_level'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                        ),
                        Text(
                          'Schedule: ${sh['days_pattern']} (${sh['start_time']} - ${sh['end_time']})',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Teacher Rate / Hr', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                Text('\$${sh['hourly_rate_usd']}/hr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentGold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Enrollment', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                Text('${sh['enrolled_count']} Students', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPreschoolLogDialog(dynamic student) {
    String mood = 'HAPPY';
    String napQuality = 'RESTFUL';
    final pickupController = TextEditingController(text: student['guardian_name'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Preschool Daily Health Check: ${student['full_name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Authorized Pickups:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            Text(student['authorized_pickups'] ?? 'Grandmother, Mother', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            const Text('Nap Quality:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: napQuality,
              items: const [
                DropdownMenuItem(value: 'RESTFUL', child: Text('RESTFUL (Slept soundly)')),
                DropdownMenuItem(value: 'RESTLESS', child: Text('RESTLESS (Woke up repeatedly)')),
                DropdownMenuItem(value: 'NO_SLEEP', child: Text('NO_SLEEP')),
              ],
              onChanged: (v) => napQuality = v!,
            ),
            const SizedBox(height: 12),
            const Text('Guardian Verifying Pickup:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            TextField(controller: pickupController, decoration: const InputDecoration(hintText: 'Guardian Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ApiClient().post(ApiEndpoints.preschoolDailyLog, data: {
                'student_id': student['id'],
                'mood_rating': mood,
                'nap_quality': napQuality,
                'guardian_pickup_name': pickupController.text,
                'guardian_pickup_verified': true,
              });
              Navigator.pop(ctx);
              _loadAllData();
            },
            child: const Text('Save & Verify Pickup'),
          ),
        ],
      ),
    );
  }
}

