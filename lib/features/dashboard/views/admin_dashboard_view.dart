import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/stat_metric_card.dart';
import '../../../widgets/custom_badge.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class AdminDashboardView extends StatefulWidget {
  final Function(int) onNavigate;
  const AdminDashboardView({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  bool _isLoading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final response = await ApiClient().get(ApiEndpoints.dashboardSummary);
      if (mounted) {
        setState(() {
          _summary = response.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final kpis = _summary?['kpis'] ?? {};
    final payroll = _summary?['payroll_closing_cycle'] ?? {};
    final scans = (_summary?['recent_gate_scans'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
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
                    'Executive Command Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Preah Sihanouk International School (PSI-VH) • Real-Time ERP Telemetry',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              CustomBadge.info('Academic Year 2026-2027', icon: Icons.calendar_today),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Monthly Closing Cycle Status Alert Box (25th to 25th / 30th)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: payroll['is_within_closing_window_25_to_30'] == true
                  ? AppColors.lightOrange
                  : AppColors.lightTeal,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: payroll['is_within_closing_window_25_to_30'] == true
                    ? AppColors.warningOrange.withOpacity(0.4)
                    : AppColors.infoTeal.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  payroll['is_within_closing_window_25_to_30'] == true
                      ? Icons.lock_clock
                      : Icons.verified_user_outlined,
                  color: payroll['is_within_closing_window_25_to_30'] == true
                      ? AppColors.warningOrange
                      : AppColors.infoTeal,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            payroll['is_within_closing_window_25_to_30'] == true
                                ? 'MONTHLY CLOSING WINDOW ACTIVE (25th to 30th)'
                                : 'PAYROLL CYCLE IN PROGRESS (25th to 25th Period)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: payroll['is_within_closing_window_25_to_30'] == true
                                  ? AppColors.warningOrange
                                  : AppColors.infoTeal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CustomBadge(
                            label: payroll['is_closed_locked'] == true ? 'LEDGER LOCKED' : 'OPEN / AUDITING',
                            backgroundColor: payroll['is_closed_locked'] == true
                                ? AppColors.lightRed
                                : AppColors.lightGreen,
                            textColor: payroll['is_closed_locked'] == true
                                ? AppColors.dangerRed
                                : AppColors.successGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active Cycle: ${payroll['active_cycle_code']} • Day of Month: ${payroll['current_day_of_month']}. Ledger closure & accounting lockdown strictly enforced between the 25th and 30th.',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => widget.onNavigate(4), // Navigate to Payroll
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('Open Payroll Audit', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Top Metrics Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 1.6 : 1.3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatMetricCard(
                    title: 'Total Enrolled Students',
                    value: '${kpis['total_students'] ?? 0}',
                    subtitle: 'Preschool (${kpis['preschool_students']}), G1-12 (${kpis['general_ed_students']})',
                    icon: Icons.people_alt_outlined,
                    iconColor: AppColors.primaryBlue,
                    badgeText: '+12% YoY',
                  ),
                  StatMetricCard(
                    title: 'Year-to-Date Net Cashflow',
                    value: CurrencyFormatter.formatUsd(
                      (kpis['ytd_net_income_usd'] as num?)?.toDouble() ?? 0.0,
                    ),
                    subtitle: 'Rev: \$${kpis['ytd_revenue_usd']} • Exp: \$${kpis['ytd_expenses_usd']}',
                    icon: Icons.account_balance,
                    iconColor: AppColors.successGreen,
                    badgeText: 'Healthy',
                  ),
                  StatMetricCard(
                    title: 'Pending Procurements',
                    value: '${kpis['pending_procurement_approvals'] ?? 0} Requests',
                    subtitle: 'Awaiting Dept Head or Accounting review',
                    icon: Icons.pending_actions,
                    iconColor: AppColors.warningOrange,
                    badgeText: 'Action Req',
                    badgeColor: AppColors.warningOrange,
                  ),
                  StatMetricCard(
                    title: 'Low Stock Item Alerts',
                    value: '${kpis['low_stock_alerts'] ?? 0} SKUs',
                    subtitle: 'Uniforms & stationery below safety min',
                    icon: Icons.inventory_2_outlined,
                    iconColor: AppColors.dangerRed,
                    badgeText: 'Restock',
                    badgeColor: AppColors.dangerRed,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 4. Middle Section: Academic Enrollment Split & Gate-Pass Live Feed
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Programs Card
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
                          const Text(
                            'Academic Structure Breakdown',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => widget.onNavigate(1),
                            child: const Text('Manage Classes ➔', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _programRow(
                        'Preschool Early Learning',
                        'Ages 2 to 6 • Nap, nutrition & guardian check',
                        '${kpis['preschool_students'] ?? 0} toddlers',
                        AppColors.accentGold,
                        Icons.child_care,
                      ),
                      const Divider(height: 24),
                      _programRow(
                        'General Education (K-12)',
                        'Grades 1 to 12 • Cambridge & MoEYS grading',
                        '${kpis['general_ed_students'] ?? 0} students',
                        AppColors.primaryBlue,
                        Icons.school,
                      ),
                      const Divider(height: 24),
                      _programRow(
                        'Part-Time Language Center',
                        'Khmer, English & Chinese (Morning/Eve/Wknd)',
                        '${kpis['part_time_students'] ?? 0} enrollments',
                        AppColors.infoTeal,
                        Icons.translate,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Recent Gate-Pass Scans Live Feed
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
                        children: [
                          const Text(
                            'Gate-Pass Telemetry Live',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          CustomBadge.success('Scanner Online', icon: Icons.radar),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (scans.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text('No scans recorded today yet')),
                        )
                      else
                        ...scans.map((s) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    s['type'] == 'ENTRY' ? Icons.login : Icons.logout,
                                    color: s['type'] == 'ENTRY' ? AppColors.successGreen : AppColors.dangerRed,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gate ${s['type']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                      Text(
                                        s['location'] ?? 'Gate A',
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                s['time'] ?? '',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                              ),
                            ],
                          ),
                        )),
                      const SizedBox(height: 8),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onNavigate(6),
                          icon: const Icon(Icons.qr_code_scanner, size: 14),
                          label: const Text('Open QR Gate Scanner', style: TextStyle(fontSize: 11)),
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

  Widget _programRow(String title, String subtitle, String countText, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
        Text(
          countText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
      ],
    );
  }
}

