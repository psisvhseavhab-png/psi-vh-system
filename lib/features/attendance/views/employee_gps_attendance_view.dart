import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../widgets/custom_badge.dart';
import '../../auth/providers/auth_provider.dart';

class EmployeeGpsAttendanceView extends StatefulWidget {
  const EmployeeGpsAttendanceView({Key? key}) : super(key: key);

  @override
  State<EmployeeGpsAttendanceView> createState() => _EmployeeGpsAttendanceViewState();
}

class _EmployeeGpsAttendanceViewState extends State<EmployeeGpsAttendanceView> {
  bool _isLoading = true;
  bool _isPunching = false;
  List<dynamic> _gpsLogs = [];
  Map<String, dynamic>? _lastPunchResult;

  // Campus coordinates: 11.538301221415631, 104.96633807434716
  final double _campusLat = 11.538301221415631;
  final double _campusLng = 104.96633807434716;
  final double _maxPerimeter = 50.0;

  // Selected telemetry preset
  String _selectedCheckType = 'CHECK_IN';
  double _currentLat = 11.538320;
  double _currentLng = 104.966340;
  double _currentAccuracy = 6.5;
  bool _isMocked = false;
  String _currentPreset = 'CAMPUS_INSIDE_12M';

  @override
  void initState() {
    super.initState();
    _loadGpsLogs();
  }

  Future<void> _loadGpsLogs() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().get(ApiEndpoints.employeeGpsLogs);
      if (mounted) {
        setState(() {
          _gpsLogs = res.data is List ? res.data : [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _executeGpsPunch() async {
    setState(() => _isPunching = true);
    try {
      final res = await ApiClient().post(
        ApiEndpoints.employeeGpsPunch,
        data: {
          'check_type': _selectedCheckType,
          'latitude': _currentLat,
          'longitude': _currentLng,
          'accuracy': _currentAccuracy,
          'is_mocked': _isMocked,
          'altitude': 14.5,
        },
      );

      setState(() {
        _lastPunchResult = res.data;
        _isPunching = false;
      });

      _loadGpsLogs();

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.successGreen, size: 24),
                SizedBox(width: 8),
                Text('GPS Punch Approved', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(res.data['message'] ?? 'Check-in successful!'),
                const SizedBox(height: 10),
                Text('• Target Campus: $_campusLat, $_campusLng', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text('• Distance to Campus: ${(res.data['distance_meters'] as num).toStringAsFixed(1)}m (Allowed: 50m)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                Text('• Anti-Spoofing: Verified Authentic GPS', style: const TextStyle(fontSize: 11, color: AppColors.primaryNavy)),
                Text('• Real-Time Alert: Dispatched to School Telegram Channel', style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isPunching = false);
      _loadGpsLogs();

      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        final isSpoof = errorMsg.contains('Fake GPS') || errorMsg.contains('Mock');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(isSpoof ? Icons.gpp_bad : Icons.location_off, color: AppColors.dangerRed, size: 24),
                const SizedBox(width: 8),
                Text(
                  isSpoof ? 'Fake GPS Spoofing Blocked!' : 'Out-of-Bounds Rejection',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.dangerRed),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMsg, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lightRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: AppColors.dangerRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSpoof
                              ? 'Security Defense: PSI-VH anti-spoofing engine rejected mock location provider.'
                              : 'Geofence Perimeter: Attendance is restricted strictly to within 50m of campus.',
                          style: const TextStyle(fontSize: 10, color: AppColors.dangerRed, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _applyTelemetryPreset(String preset) {
    setState(() {
      _currentPreset = preset;
      if (preset == 'CAMPUS_INSIDE_12M') {
        _currentLat = 11.538315;
        _currentLng = 104.966345;
        _currentAccuracy = 5.5;
        _isMocked = false;
      } else if (preset == 'CAMPUS_INSIDE_35M') {
        _currentLat = 11.538550;
        _currentLng = 104.966338;
        _currentAccuracy = 8.0;
        _isMocked = false;
      } else if (preset == 'OUTSIDE_110M') {
        // ~110m away
        _currentLat = 11.539300;
        _currentLng = 104.966340;
        _currentAccuracy = 10.0;
        _isMocked = false;
      } else if (preset == 'FAKE_GPS_SPOOFER') {
        // Inside coordinates BUT is_mocked = true
        _currentLat = 11.538301;
        _currentLng = 104.966338;
        _currentAccuracy = 4.0;
        _isMocked = true;
      } else if (preset == 'ZERO_ACCURACY_ANOMALY') {
        // Zero accuracy
        _currentLat = 11.538301;
        _currentLng = 104.966338;
        _currentAccuracy = 0.0;
        _isMocked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // 1. Header Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Employee GPS Geofencing & Anti-Spoofing Radar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                  ),
                  Text(
                    'Target Coordinates: 11.538301, 104.966338 • Strict 50-Meter Radius • Real-Time Mock Provider Defense',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomBadge.success('Anti-Spoofing Active', icon: Icons.shield),
                  const SizedBox(width: 8),
                  CustomBadge.info('Geofence: 50m Max', icon: Icons.radar),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. High-Tech GPS Geofence Terminal
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF334155)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Radar Animation Icon
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF60A5FA), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.my_location, color: Color(0xFF60A5FA), size: 34),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Campus GPS Telemetry Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'CAMPUS GEOFENCE RADAR STATION',
                                style: TextStyle(
                                  color: Color(0xFF93C5FD),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.satellite_alt, color: Color(0xFF38BDF8), size: 14),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Preah Sihanouk International School (PSI-VH)',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _telemetryChip(Icons.pin_drop, 'Lat: $_campusLat, Lng: $_campusLng'),
                              const SizedBox(width: 10),
                              _telemetryChip(Icons.circle_outlined, 'Radius: ${_maxPerimeter.toInt()}m Strict'),
                              const SizedBox(width: 10),
                              _telemetryChip(Icons.security, 'Spoofer Defense: ON'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF334155), height: 1),
                const SizedBox(height: 18),

                // Live Simulator / Punch Presets
                const Text(
                  '1. SELECT GPS LOCATION & TELEMETRY PRESET FOR VERIFICATION:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _presetButton(
                      id: 'CAMPUS_INSIDE_12M',
                      label: 'Campus Gate A (Inside 12m) - Legitimate',
                      icon: Icons.check_circle_outline,
                      color: AppColors.successGreen,
                    ),
                    _presetButton(
                      id: 'CAMPUS_INSIDE_35M',
                      label: 'Teacher Lounge (Inside 35m) - Legitimate',
                      icon: Icons.check_circle_outline,
                      color: AppColors.primaryBlue,
                    ),
                    _presetButton(
                      id: 'OUTSIDE_110M',
                      label: 'Outside Campus (110m Away) - Reject Bounds',
                      icon: Icons.not_listed_location,
                      color: const Color(0xFFF59E0B),
                    ),
                    _presetButton(
                      id: 'FAKE_GPS_SPOOFER',
                      label: 'Fake GPS Mock Provider App - Auto Detect & Block',
                      icon: Icons.gpp_bad,
                      color: AppColors.dangerRed,
                    ),
                    _presetButton(
                      id: 'ZERO_ACCURACY_ANOMALY',
                      label: 'Zero Accuracy Anomaly (0.0m) - Spoofer Anomaly',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFEC4899),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Telemetry Details & Punch Trigger
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reporting: Lat $_currentLat, Lng $_currentLng',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Satellite Accuracy: ${_currentAccuracy}m • Mock Provider Active: ${_isMocked ? "YES (DETECTED)" : "NO (CLEAN)"}',
                              style: TextStyle(
                                color: _isMocked ? const Color(0xFFF87171) : const Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('CHECK IN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            selected: _selectedCheckType == 'CHECK_IN',
                            selectedColor: AppColors.successGreen,
                            labelStyle: TextStyle(color: _selectedCheckType == 'CHECK_IN' ? Colors.white : Colors.black87),
                            onSelected: (_) => setState(() => _selectedCheckType = 'CHECK_IN'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('CHECK OUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            selected: _selectedCheckType == 'CHECK_OUT',
                            selectedColor: AppColors.primaryNavy,
                            labelStyle: TextStyle(color: _selectedCheckType == 'CHECK_OUT' ? Colors.white : Colors.black87),
                            onSelected: (_) => setState(() => _selectedCheckType = 'CHECK_OUT'),
                          ),
                          const SizedBox(width: 14),
                          ElevatedButton.icon(
                            onPressed: _isPunching ? null : _executeGpsPunch,
                            icon: Icon(
                              _selectedCheckType == 'CHECK_IN' ? Icons.login : Icons.logout,
                              size: 16,
                            ),
                            label: Text(
                              _isPunching ? 'Verifying GPS...' : 'Transmit GPS Punch',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGold,
                              foregroundColor: AppColors.primaryNavy,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
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

          // 3. Employee Attendance GPS Audit Log Table
          Container(
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
                    const Text(
                      'Live GPS Attendance Audit & Anti-Spoofing Records',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _loadGpsLogs,
                      tooltip: 'Refresh GPS Audit Logs',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_gpsLogs.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No GPS attendance logs registered yet.')))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(AppColors.backgroundLight),
                      columns: const [
                        DataColumn(label: Text('STAFF NAME & ROLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('DISTANCE TO CAMPUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('ACCURACY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('ANTI-SPOOF TELEMETRY NOTES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('TIMESTAMP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      ],
                      rows: _gpsLogs.map((log) {
                        final status = log['status'] ?? 'APPROVED';
                        Color statusColor = AppColors.successGreen;
                        Color statusBg = AppColors.lightGreen;
                        IconData statusIcon = Icons.check_circle;

                        if (status == 'REJECTED_OUT_OF_BOUNDS') {
                          statusColor = const Color(0xFFD97706);
                          statusBg = const Color(0xFFFEF3C7);
                          statusIcon = Icons.location_off;
                        } else if (status == 'REJECTED_FAKE_GPS') {
                          statusColor = AppColors.dangerRed;
                          statusBg = AppColors.lightRed;
                          statusIcon = Icons.gpp_bad;
                        }

                        return DataRow(cells: [
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(log['staff_name'] ?? 'Staff', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(log['role'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          )),
                          DataCell(Text(log['check_type'] ?? 'CHECK_IN', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11))),
                          DataCell(Text(
                            '${(log['distance_meters'] as num?)?.toStringAsFixed(1) ?? "0.0"} meters',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: (log['distance_meters'] as num? ?? 0) <= 50 ? AppColors.successGreen : AppColors.dangerRed,
                            ),
                          )),
                          DataCell(Text('${(log['accuracy_meters'] as num?)?.toStringAsFixed(1) ?? "0.0"}m', style: const TextStyle(fontSize: 11))),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, color: statusColor, size: 12),
                                const SizedBox(width: 4),
                                Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )),
                          DataCell(Text(
                            log['security_notes'] ?? 'Clean GPS fix',
                            style: TextStyle(
                              fontSize: 11,
                              color: log['is_mock_detected'] == true ? AppColors.dangerRed : AppColors.textSecondary,
                            ),
                          )),
                          DataCell(Text(log['timestamp'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _telemetryChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF38BDF8), size: 12),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _presetButton({
    required String id,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _currentPreset == id;
    return InkWell(
      onTap: () => _applyTelemetryPreset(id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : const Color(0xFF334155), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : const Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
