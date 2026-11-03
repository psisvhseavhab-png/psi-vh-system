import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../models/tax_report_model.dart';
import '../../../widgets/custom_badge.dart';

class FinanceReportsView extends StatefulWidget {
  const FinanceReportsView({Key? key}) : super(key: key);

  @override
  State<FinanceReportsView> createState() => _FinanceReportsViewState();
}

class _FinanceReportsViewState extends State<FinanceReportsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  Map<String, dynamic>? _annualSummary;
  GdtTaxReportModel? _gdtReport;
  List<dynamic> _ledgerEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFinanceData();
  }

  Future<void> _loadFinanceData() async {
    setState(() => _isLoading = true);
    try {
      final resSummary = await ApiClient().get(ApiEndpoints.annualSummary);
      final resGdt = await ApiClient().get(ApiEndpoints.gdtTaxDeclaration);
      final resLedger = await ApiClient().get(ApiEndpoints.financialLedger);

      if (mounted) {
        setState(() {
          _annualSummary = resSummary.data;
          _gdtReport = GdtTaxReportModel.fromJson(resGdt.data);
          _ledgerEntries = resLedger.data;
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
                      'Annual Financial Ledger & GDT Tax Declarations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Cambodia General Department of Taxation (GDT) Compliant • Corporate Profit Tax & Tax On Salary (TOS)',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.primaryNavy,
                  labelColor: AppColors.primaryNavy,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  tabs: const [
                    Tab(text: 'Cambodia GDT Tax Declaration'),
                    Tab(text: 'Annual General Ledger'),
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
                _buildGdtTaxTab(),
                _buildGeneralLedgerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: GDT TAX DECLARATION ====================
  Widget _buildGdtTaxTab() {
    if (_gdtReport == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Official GDT School Registration Card
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance, color: AppColors.primaryNavy, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _gdtReport!.taxAuthority,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                        ),
                        Text(
                          'Taxpayer: ${_gdtReport!.schoolName} • TIN: ${_gdtReport!.schoolTin}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          'Tax Year: ${_gdtReport!.taxYear} • Official NBC Rate: 1 USD = ${_gdtReport!.nbcRate.toStringAsFixed(0)} KHR',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomBadge.success('GDT E-Filing Verified', icon: Icons.verified),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Calculation Cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Corporate Profit Tax Card
              Expanded(
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
                      const Text(
                        'Corporate Tax on Profit (ToP / ពន្ធលើប្រាក់ចំណេញ)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                      ),
                      const SizedBox(height: 14),
                      _taxRow('Gross Annual Revenue', CurrencyFormatter.formatBoth(_gdtReport!.annualRevenueUsd)),
                      _taxRow('Deductible Operating Expenses', CurrencyFormatter.formatBoth(_gdtReport!.deductibleExpensesUsd)),
                      const Divider(height: 20),
                      _taxRow('Taxable Net Profit (KHR)', CurrencyFormatter.formatKhr(_gdtReport!.taxableProfitKhr), isBold: true),
                      _taxRow('Standard 20% Profit Tax', CurrencyFormatter.formatKhr(_gdtReport!.standardProfitTaxKhr)),
                      _taxRow('1% Minimum Turnover Tax', CurrencyFormatter.formatKhr(_gdtReport!.minimumTaxKhr)),
                      const Divider(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Final Tax on Profit Due:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                Text('Rule: ${_gdtReport!.ruleApplied}', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                              ],
                            ),
                            Text(
                              CurrencyFormatter.formatBoth(_gdtReport!.finalTaxLiabilityUsd),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Tax on Salary (TOS) Withheld
              Expanded(
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
                      const Text(
                        'Tax on Salary (TOS / ពន្ធលើប្រាក់បៀវត្ស)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy),
                      ),
                      const SizedBox(height: 14),
                      _taxRow('Total Gross Payroll Disbursed', CurrencyFormatter.formatBoth(_gdtReport!.annualGrossPayrollUsd)),
                      _taxRow('Total TOS Withheld & Reconciled (KHR)', CurrencyFormatter.formatKhr(_gdtReport!.totalTosWithheldKhr), isBold: true),
                      _taxRow('TOS Equivalent in USD', CurrencyFormatter.formatUsd(_gdtReport!.totalTosWithheldUsd)),
                      const Divider(height: 20),
                      const Text('Cambodian Resident Monthly Brackets:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('• 0 - 1,500,000 KHR: 0%\n• 1,500,001 - 2,000,000 KHR: 5%\n• 2,000,001 - 8,500,000 KHR: 10%\n• 8,500,001 - 12,500,000 KHR: 15%\n• Above 12,500,000 KHR: 20%', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.4)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Rebate Allowance per Dependent Child/Spouse:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('150,000 ៛ / mo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                          ],
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

  // ==================== TAB 2: GENERAL LEDGER ====================
  Widget _buildGeneralLedgerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fiscal Year 2026 Accounting Journal & Financial Ledger', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              CustomBadge.info('Dual Currency KHR / USD'),
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
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Reference ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Amount (USD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('Amount (Khmer Riel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _ledgerEntries.map((e) {
                final isIncome = e['is_income'] == true;
                return DataRow(
                  cells: [
                    DataCell(Text(e['date'], style: const TextStyle(fontSize: 11))),
                    DataCell(
                      CustomBadge(
                        label: e['category'],
                        backgroundColor: isIncome ? AppColors.lightGreen : AppColors.lightRed,
                        textColor: isIncome ? AppColors.successGreen : AppColors.dangerRed,
                      ),
                    ),
                    DataCell(Text(e['reference_id'] ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    DataCell(Text(e['description'], style: const TextStyle(fontSize: 11))),
                    DataCell(
                      Text(
                        '${isIncome ? '+' : '-'}\$${e['amount_usd']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isIncome ? AppColors.successGreen : AppColors.dangerRed,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${e['amount_khr']} ៛',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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

  Widget _taxRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

