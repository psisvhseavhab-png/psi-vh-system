import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../widgets/custom_badge.dart';
import 'employee_gps_attendance_view.dart';

class AttendanceGatepassView extends StatefulWidget {
  const AttendanceGatepassView({Key? key}) : super(key: key);

  @override
  State<AttendanceGatepassView> createState() => _AttendanceGatepassViewState();
}

class _AttendanceGatepassViewState extends State<AttendanceGatepassView> {
  int _selectedTab = 0; // 0: QR Gate-Pass Telemetry, 1: Employee GPS Geofencing (50m)
  final _qrController = TextEditingController(text: 'QR-GATE-PSI-PRE-001');
  String _scanType = 'ENTRY';
  String _gateLocation = 'MAIN_GATE_A';
  bool _isLoading = true;
  bool _isScanning = false;
  List<dynamic> _logs = [];
  Map<String, dynamic>? _lastScanResult;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().get(ApiEndpoints.gatePassLogs);
      if (mounted) {
        setState(() {
          _logs = res.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processScan() async {
    if (_qrController.text.trim().isEmpty) return;

    setState(() => _isScanning = true);
    try {
      final res = await ApiClient().post(
        ApiEndpoints.gatePassScan,
        data: {
          'qr_code': _qrController.text.trim(),
          'scan_type': _scanType,
          'scanner_location': _gateLocation,
        },
      );

      setState(() {
        _lastScanResult = res.data;
        _isScanning = false;
      });
      _loadLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gate-Pass $_scanType recorded & Telegram alert sent!')),
      );
    } catch (e) {
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Smart Gate-Pass QR Scanner & Attendance Telemetry',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Instant Student / Staff QR Verification • Real-Time Telegram Alerts to Parents & Administration',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              CustomBadge.success('Telegram Bot Connected', icon: Icons.send),
            ],
          ),
          const SizedBox(height: 16),

          // TAB BAR SELECTOR
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 0),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? AppColors.primaryNavy : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, size: 16, color: _selectedTab == 0 ? Colors.white : AppColors.textPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'Student & Staff QR Gate-Pass Telemetry',
                            style: TextStyle(
                              color: _selectedTab == 0 ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 1),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? AppColors.primaryNavy : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, size: 16, color: _selectedTab == 1 ? AppColors.accentGold : AppColors.textPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'Employee GPS Geofence (50m Radius) & Anti-Spoofing',
                            style: TextStyle(
                              color: _selectedTab == 1 ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_selectedTab == 1)
            const EmployeeGpsAttendanceView()
          else ...[
            // Scanner Control Box
            Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scanner Input Card
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
                      const Text('QR Code Terminal Scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _qrController,
                        decoration: InputDecoration(
                          labelText: 'QR Gate-Pass Code or Barcode',
                          prefixIcon: const Icon(Icons.qr_code, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _scanType,
                              decoration: InputDecoration(
                                labelText: 'Gate Action',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'ENTRY', child: Text('ENTRY (Inbound)')),
                                DropdownMenuItem(value: 'EXIT', child: Text('EXIT (Outbound)')),
                              ],
                              onChanged: (v) => setState(() => _scanType = v!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _gateLocation,
                              decoration: InputDecoration(
                                labelText: 'Gate Station',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'MAIN_GATE_A', child: Text('Main Gate A')),
                                DropdownMenuItem(value: 'PRESCHOOL_GATE', child: Text('Preschool Gate')),
                                DropdownMenuItem(value: 'BUS_DROP_OFF', child: Text('Bus Drop-Off')),
                              ],
                              onChanged: (v) => setState(() => _gateLocation = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isScanning ? null : _processScan,
                        icon: const Icon(Icons.qr_code_scanner, size: 16),
                        label: Text(_isScanning ? 'Verifying...' : 'Verify Gate-Pass & Dispatch Telegram Alert', style: const TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          minimumSize: const Size.fromHeight(42),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: [
                          ActionChip(
                            label: const Text('Preschool Dara', style: TextStyle(fontSize: 10)),
                            onPressed: () => setState(() => _qrController.text = 'QR-GATE-PSI-PRE-001'),
                          ),
                          ActionChip(
                            label: const Text('Grade 10 Bopha', style: TextStyle(fontSize: 10)),
                            onPressed: () => setState(() => _qrController.text = 'QR-GATE-PSI-G10-042'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Scan Result & Telegram Dispatch Box
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _lastScanResult != null ? AppColors.lightGreen : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _lastScanResult != null ? AppColors.successGreen : AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Last Scan Verification & Telegram Dispatch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (_lastScanResult != null)
                            CustomBadge.success('Verified Valid'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_lastScanResult == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Text(
                              'Ready for Gate-Pass check-in. Select student code and verify.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          _lastScanResult!['message'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.successGreen),
                        ),
                        const SizedBox(height: 8),
                        Text('Timestamp: ${_lastScanResult!['scanned_at']}', style: const TextStyle(fontSize: 11)),
                        Text('Telegram Alert: ${_lastScanResult!['telegram_alert_sent'] == true ? 'Dispatched successfully' : 'Queued'}', style: const TextStyle(fontSize: 11, color: AppColors.infoTeal)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.telegram, color: Color(0xFF0088CC), size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Automated SMS / Telegram notification delivered to parent guardian.',
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Real-Time Audit Log Table
          const Text('Today Gate-Pass Activity Stream', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                columns: const [
                  DataColumn(label: Text('Person Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Identifier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Location Station', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Telegram Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                ],
                rows: _logs.map((l) {
                  return DataRow(
                    cells: [
                      DataCell(Text(l['name'] ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataCell(Text(l['code'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                      DataCell(
                        CustomBadge(
                          label: l['scan_type'],
                          backgroundColor: l['scan_type'] == 'ENTRY' ? AppColors.lightGreen : AppColors.lightRed,
                          textColor: l['scan_type'] == 'ENTRY' ? AppColors.successGreen : AppColors.dangerRed,
                        ),
                      ),
                      DataCell(Text(l['scanner_location'] ?? 'Gate A', style: const TextStyle(fontSize: 11))),
                      DataCell(Text(l['scanned_at'] ?? '', style: const TextStyle(fontSize: 11))),
                      DataCell(
                        l['telegram_alert_sent'] == true
                            ? CustomBadge.success('Delivered')
                            : CustomBadge.warning('Simulated'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

