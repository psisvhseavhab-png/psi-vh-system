import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/minute_calculator.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../models/payroll_model.dart';
import '../../../widgets/custom_badge.dart';
import '../../auth/providers/auth_provider.dart';

class PayrollClosingView extends StatefulWidget {
  const PayrollClosingView({Key? key}) : super(key: key);

  @override
  State<PayrollClosingView> createState() => _PayrollClosingViewState();
}

class _PayrollClosingViewState extends State<PayrollClosingView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  List<PayrollCycleModel> _cycles = [];
  PayrollCycleModel? _activeCycle;
  List<PayrollSlipModel> _slips = [];
  List<dynamic> _timeLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCyclesAndLogs();
  }

  Future<void> _loadCyclesAndLogs() async {
    setState(() => _isLoading = true);
    try {
      final resCycles = await ApiClient().get(ApiEndpoints.payrollCycles);
      final resLogs = await ApiClient().get(ApiEndpoints.timeLogsList);

      if (mounted) {
        setState(() {
          _cycles = (resCycles.data as List)
              .map((c) => PayrollCycleModel.fromJson(c))
              .toList();
          _timeLogs = resLogs.data;

          if (_cycles.isNotEmpty) {
            _activeCycle = _cycles.first;
            _loadCycleSlips(_activeCycle!.id);
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCycleSlips(String cycleId) async {
    try {
      final res = await ApiClient().get(ApiEndpoints.cycleSlips(cycleId));
      if (mounted) {
        setState(() {
          _slips = (res.data['slips'] as List)
              .map((s) => PayrollSlipModel.fromJson(s))
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateNewCycle() async {
    try {
      await ApiClient().post(ApiEndpoints.generatePayrollCycle, data: {
        'year': 2026,
        'month': 11,
      });
      _loadCyclesAndLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payroll Cycle 25th-to-25th calculated & generated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _executeMonthlyCloseLock() async {
    if (_activeCycle == null) return;
    try {
      await ApiClient().post(
        ApiEndpoints.monthlyCloseLock(_activeCycle!.id),
        data: {'closing_notes': 'Monthly accounting review completed. Ledger locked between 25th-30th.'},
      );
      _loadCyclesAndLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cycle CLOSED & LOCKED! Entries posted to official ledger.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lock failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userRole = auth.currentRole;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Header Bar
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Advanced Payroll & Monthly Closing Engine',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '25th to 25th Pay Cycle Period • Monthly Ledger Lockdown strictly 25th to 30th • Minute-by-Minute Wage Engine',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: AppColors.primaryNavy,
                      labelColor: AppColors.primaryNavy,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      tabs: const [
                        Tab(text: 'Payroll Cycle & GDT Tax Slips'),
                        Tab(text: 'Part-Time Minute Working Logs'),
                      ],
                    ),
                    const SizedBox(width: 14),
                    if (userRole == 'ACCOUNTANT' || userRole == 'SCHOOL_DIRECTOR' || userRole == 'SUPER_ADMIN')
                      ElevatedButton.icon(
                        onPressed: _generateNewCycle,
                        icon: const Icon(Icons.calculate, size: 16),
                        label: const Text('Recalculate Cycle (25-25)', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCycleSlipsTab(userRole),
                _buildMinuteTimeLogsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: PAYROLL CYCLE & SLIPS ====================
  Widget _buildCycleSlipsTab(String userRole) {
    if (_activeCycle == null) {
      return const Center(child: Text('No active payroll cycle found. Generate one above.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cycle Card & Monthly Lock Controller
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _activeCycle!.cycleCode,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy),
                        ),
                        const SizedBox(width: 12),
                        CustomBadge(
                          label: _activeCycle!.isClosedLocked ? 'LOCKED / CLOSED' : 'OPEN / AUDITING',
                          backgroundColor: _activeCycle!.isClosedLocked ? AppColors.lightRed : AppColors.lightGreen,
                          textColor: _activeCycle!.isClosedLocked ? AppColors.dangerRed : AppColors.successGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pay Period: ${_activeCycle!.startDate} to ${_activeCycle!.endDate} (Strictly 25th of month M-1 to 25th of month M)',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      'Closing Lock Deadline: ${_activeCycle!.closeLockDeadline} (Locked strictly between 25th and 30th)',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Net Payout:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text(
                          CurrencyFormatter.formatBoth(_activeCycle!.totalPayoutUsd),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryNavy),
                        ),
                        Text(
                          'GDT Tax on Salary: ${CurrencyFormatter.formatKhr(_activeCycle!.totalGdtTaxKhr)}',
                          style: const TextStyle(fontSize: 10, color: AppColors.accentGold, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    if (!_activeCycle!.isClosedLocked &&
                        (userRole == 'ACCOUNTANT' || userRole == 'SCHOOL_DIRECTOR' || userRole == 'SUPER_ADMIN'))
                      ElevatedButton.icon(
                        onPressed: _executeMonthlyCloseLock,
                        icon: const Icon(Icons.lock, size: 16),
                        label: const Text('Lock Ledger (Monthly Close)', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Slips Table
          const Text('Employee Compensation Breakdown & Cambodia GDT Tax Withholdings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
              columns: const [
                DataColumn(label: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Base / Minute Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Gross Salary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('GDT Tax on Salary (TOS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Net Pay (USD & KHR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _slips.map((s) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          if (s.khmerName != null)
                            Text(s.khmerName!, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    DataCell(
                      CustomBadge(
                        label: s.employmentType,
                        backgroundColor: s.employmentType == 'FULL_TIME' ? AppColors.lightBlue : AppColors.lightOrange,
                        textColor: s.employmentType == 'FULL_TIME' ? AppColors.primaryBlue : AppColors.warningOrange,
                      ),
                    ),
                    DataCell(
                      s.employmentType == 'FULL_TIME'
                          ? Text('\$${s.baseSalaryUsd} / mo', style: const TextStyle(fontSize: 11))
                          : Text(
                              '${s.totalPartTimeMinutes} mins (${MinuteCalculator.formatDuration(s.totalPartTimeMinutes)})',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                    ),
                    DataCell(Text(CurrencyFormatter.formatUsd(s.grossSalaryUsd), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(CurrencyFormatter.formatKhr(s.gdtTaxOnSalaryKhr), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.dangerRed)),
                          Text('(\$${s.gdtTaxOnSalaryUsd})', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(CurrencyFormatter.formatUsd(s.netSalaryUsd), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
                          Text(CurrencyFormatter.formatKhr(s.netSalaryKhr), style: const TextStyle(fontSize: 10, color: AppColors.accentGold)),
                        ],
                      ),
                    ),
                    DataCell(CustomBadge.success('APPROVED')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: PART-TIME MINUTE LOGS ====================
  Widget _buildMinuteTimeLogsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Part-Time Teacher Minute-by-Minute Clock In / Clock Out Logs',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              CustomBadge.info('Exact Minute Wage Calculation Engine', icon: Icons.av_timer),
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
                DataColumn(label: Text('Teacher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Clock In - Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Total Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Hourly Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Computed Wage (USD & KHR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _timeLogs.map((tl) {
                return DataRow(
                  cells: [
                    DataCell(Text(tl['teacher_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataCell(Text(tl['log_date'], style: const TextStyle(fontSize: 11))),
                    DataCell(Text('${tl['clock_in']} - ${tl['clock_out']}', style: const TextStyle(fontSize: 11))),
                    DataCell(
                      CustomBadge.info('${tl['total_minutes']} mins (${tl['total_hours_formatted']})'),
                    ),
                    DataCell(Text('\$${tl['hourly_rate']}/hr', style: const TextStyle(fontSize: 11))),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\$${tl['wage_usd']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
                          Text('${tl['wage_khr']} ៛', style: const TextStyle(fontSize: 9, color: AppColors.accentGold)),
                        ],
                      ),
                    ),
                    DataCell(CustomBadge.success('Verified')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

