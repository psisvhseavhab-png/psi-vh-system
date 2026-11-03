import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/minute_calculator.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../widgets/custom_badge.dart';
import '../../auth/providers/auth_provider.dart';

class TeacherPortalView extends StatefulWidget {
  final Function(int) onNavigate;
  const TeacherPortalView({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<TeacherPortalView> createState() => _TeacherPortalViewState();
}

class _TeacherPortalViewState extends State<TeacherPortalView> {
  bool _isLoading = true;
  List<dynamic> _myTimeLogs = [];
  List<dynamic> _myRequests = [];
  List<dynamic> _shifts = [];

  // Active Punch Clock State
  bool _isClockedIn = false;
  DateTime? _clockInTime;
  Duration _activeDuration = Duration.zero;
  Timer? _punchTimer;
  double _activeHourlyRate = 16.0;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  @override
  void dispose() {
    _punchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);
    try {
      final resLogs = await ApiClient().get(ApiEndpoints.timeLogsList);
      final resReqs = await ApiClient().get(ApiEndpoints.procurementRequests);
      final resShifts = await ApiClient().get(ApiEndpoints.partTimeShifts);

      if (mounted) {
        setState(() {
          _myTimeLogs = resLogs.data;
          _myRequests = resReqs.data;
          _shifts = resShifts.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _togglePunchClock() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final teacherId = auth.currentUser?.id ?? '';

    if (!_isClockedIn) {
      // Clock in
      setState(() {
        _isClockedIn = true;
        _clockInTime = DateTime.now();
        _activeDuration = Duration.zero;
      });

      _punchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _activeDuration = DateTime.now().difference(_clockInTime!);
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Punch Clock Started! Tracking minutes for payroll.')),
      );
    } else {
      // Clock out and send to backend minute wage engine
      _punchTimer?.cancel();
      final clockOutTime = DateTime.now();
      final totalMins = clockOutTime.difference(_clockInTime!).inMinutes;

      try {
        await ApiClient().post(ApiEndpoints.timeLog, data: {
          'teacher_id': teacherId,
          'clock_in': _clockInTime!.toIso8601String(),
          'clock_out': clockOutTime.toIso8601String(),
          'hourly_rate_usd': _activeHourlyRate,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Clocked Out! Logged $totalMins minutes directly to payroll.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving log: $e')),
        );
      }

      setState(() {
        _isClockedIn = false;
        _clockInTime = null;
        _activeDuration = Duration.zero;
      });

      _loadTeacherData();
    }
  }

  bool _isGpsPunching = false;
  Map<String, dynamic>? _lastGpsResult;

  Future<void> _executeGpsPunch({
    required String checkType,
    required double lat,
    required double lng,
    required double accuracy,
    required bool isMocked,
  }) async {
    setState(() => _isGpsPunching = true);
    try {
      final res = await ApiClient().post(
        ApiEndpoints.employeeGpsPunch,
        data: {
          'check_type': checkType,
          'latitude': lat,
          'longitude': lng,
          'accuracy': accuracy,
          'is_mocked': isMocked,
          'altitude': 14.2,
        },
      );

      setState(() {
        _lastGpsResult = res.data;
        _isGpsPunching = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successGreen,
            content: Text('GPS $checkType Approved! ${(res.data['distance_meters'] as num).toStringAsFixed(1)}m from PSI-VH campus.'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGpsPunching = false);
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.security, color: AppColors.dangerRed),
                SizedBox(width: 8),
                Text('GPS Security Check', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
              ],
            ),
            content: Text(errorMsg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalLoggedMins = _myTimeLogs.fold<int>(0, (sum, l) => sum + (l['total_minutes'] as num).toInt());
    final totalWagesUsd = _myTimeLogs.fold<double>(0.0, (sum, l) => sum + (l['wage_usd'] as num).toDouble());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Personalized Header Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.fullName ?? "Teacher"}!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                  ),
                  Text(
                    '${user?.khmerName ?? ""} • Teacher & Faculty Portal • PSI-VH System',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              CustomBadge.info('Pay Period: Oct 25 - Nov 25', icon: Icons.calendar_month),
            ],
          ),
          const SizedBox(height: 20),

          // 2. LIVE PUNCH CLOCK & MINUTE WAGE ENGINE WIDGET
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isClockedIn
                    ? [const Color(0xFF064E3B), const Color(0xFF047857)]
                    : [AppColors.primaryNavy, const Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isClockedIn ? Icons.timer : Icons.alarm_on,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _isClockedIn ? 'SHIFT IN PROGRESS (ACTIVE)' : 'READY TO CLOCK IN',
                            style: const TextStyle(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isClockedIn)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isClockedIn
                            ? '${_activeDuration.inHours.toString().padLeft(2, '0')}h : ${(_activeDuration.inMinutes % 60).toString().padLeft(2, '0')}m : ${(_activeDuration.inSeconds % 60).toString().padLeft(2, '0')}s'
                            : 'Evening Language Shift: Chinese HSK 3 / Cambridge English',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isClockedIn
                            ? 'Running Wage: \$${((_activeDuration.inSeconds / 3600.0) * _activeHourlyRate).toStringAsFixed(2)} USD • Rate: \$$_activeHourlyRate/hr'
                            : 'Minute-by-minute wage engine applies exact duration to your monthly 25-25 pay cycle.',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _togglePunchClock,
                  icon: Icon(_isClockedIn ? Icons.stop_circle : Icons.play_circle_fill, size: 18),
                  label: Text(_isClockedIn ? 'Clock Out & Save' : 'Clock In Now', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isClockedIn ? AppColors.dangerRed : AppColors.accentGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2.5 GPS GEOFENCE CAMPUS ATTENDANCE CARD (11.538301, 104.966338 - 50m Strict)
          Container(
            padding: const EdgeInsets.all(18),
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
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: AppColors.primaryNavy, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Campus GPS Geofence Check-In & Anti-Spoofing',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy),
                        ),
                      ],
                    ),
                    CustomBadge.success('50m Geofence Active (11.538301, 104.966338)', icon: Icons.radar),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Verify physical presence at PSI-VH Campus. Automatic detection & rejection of Fake GPS mock locations, zero-accuracy spoofers, and teleportation jumps.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isGpsPunching
                          ? null
                          : () => _executeGpsPunch(
                                checkType: 'CHECK_IN',
                                lat: 11.538315,
                                lng: 104.966345,
                                accuracy: 5.5,
                                isMocked: false,
                              ),
                      icon: const Icon(Icons.login, size: 16),
                      label: const Text('📍 GPS Check-In (Inside 12m)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isGpsPunching
                          ? null
                          : () => _executeGpsPunch(
                                checkType: 'CHECK_OUT',
                                lat: 11.538320,
                                lng: 104.966330,
                                accuracy: 6.0,
                                isMocked: false,
                              ),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('📍 GPS Check-Out (Inside 18m)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isGpsPunching
                          ? null
                          : () => _executeGpsPunch(
                                checkType: 'CHECK_IN',
                                lat: 11.539300,
                                lng: 104.966340,
                                accuracy: 8.0,
                                isMocked: false,
                              ),
                      icon: const Icon(Icons.location_off, size: 16, color: Color(0xFFD97706)),
                      label: const Text('Test Reject: Outside 110m', style: TextStyle(color: Color(0xFFD97706))),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isGpsPunching
                          ? null
                          : () => _executeGpsPunch(
                                checkType: 'CHECK_IN',
                                lat: 11.538301,
                                lng: 104.966338,
                                accuracy: 4.0,
                                isMocked: true,
                              ),
                      icon: const Icon(Icons.gpp_bad, size: 16, color: AppColors.dangerRed),
                      label: const Text('Test Reject: Fake GPS Mock Spoofer', style: TextStyle(color: AppColors.dangerRed)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Compensation & Teaching Statistics Cards
          Row(
            children: [
              Expanded(
                child: _metricBox(
                  title: 'Accumulated Working Time',
                  value: MinuteCalculator.formatDuration(totalLoggedMins),
                  subtitle: '$totalLoggedMins exact logged minutes',
                  icon: Icons.access_time_filled,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _metricBox(
                  title: 'Cycle Estimated Gross Wage',
                  value: CurrencyFormatter.formatUsd(totalWagesUsd),
                  subtitle: CurrencyFormatter.formatKhr(totalWagesUsd * 4100.0),
                  icon: Icons.payments,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _metricBox(
                  title: 'My Material Requests',
                  value: '${_myRequests.length} Submitted',
                  subtitle: 'Classroom teaching supplies',
                  icon: Icons.inventory,
                  color: AppColors.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Two-Column Teaching Modules
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Assigned Shifts & Quick Actions
              Expanded(
                flex: 5,
                child: Container(
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
                          const Text('My Assigned Teaching Classes & Shifts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          TextButton(
                            onPressed: () => widget.onNavigate(1), // Academics
                            child: const Text('Open Gradebook ➔', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _classCard('Grade 10-A (Science & Math)', 'Homeroom & Physics Lecturer • 24 Students', Icons.science),
                      const SizedBox(height: 10),
                      _classCard('Chinese HSK 3 (Evening Shift)', 'Mon-Wed-Fri (17:30 - 19:00) • 18 Students', Icons.translate),
                      const SizedBox(height: 10),
                      _classCard('Weekend IELTS Intensive', 'Sat-Sun (08:00 - 11:30) • 22 Students', Icons.language),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => widget.onNavigate(1),
                              icon: const Icon(Icons.grading, size: 14),
                              label: const Text('Input Grades', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => widget.onNavigate(3), // Procurement
                              icon: const Icon(Icons.add_shopping_cart, size: 14),
                              label: const Text('Request Materials', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Right: Recent Punch Logs
              Expanded(
                flex: 4,
                child: Container(
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
                        children: const [
                          Text('Recent Working Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          CustomBadge(label: 'Verified by Director', backgroundColor: AppColors.lightGreen, textColor: AppColors.successGreen),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_myTimeLogs.isEmpty)
                        const Center(child: Text('No working logs recorded yet this cycle.'))
                      else
                        ..._myTimeLogs.take(4).map((l) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l['log_date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  Text('${l['clock_in']} to ${l['clock_out']}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '+${CurrencyFormatter.formatUsd((l['wage_usd'] as num).toDouble())}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.successGreen),
                                  ),
                                  Text('${l['total_minutes']} mins', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        )),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => widget.onNavigate(4), // Payroll
                          child: const Text('View Full Pay Slip Breakdown ➔', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricBox({required String title, required String value, required String subtitle, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _classCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryNavy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

