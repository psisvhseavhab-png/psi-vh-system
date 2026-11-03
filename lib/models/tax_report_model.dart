class GdtTaxReportModel {
  final String taxAuthority;
  final String schoolTin;
  final String schoolName;
  final int taxYear;
  final double nbcRate;
  
  // Profit Tax
  final double annualRevenueUsd;
  final double annualRevenueKhr;
  final double deductibleExpensesUsd;
  final double taxableProfitKhr;
  final double standardProfitTaxKhr;
  final double minimumTaxKhr;
  final double finalTaxLiabilityKhr;
  final double finalTaxLiabilityUsd;
  final String ruleApplied;

  // Tax On Salary (TOS)
  final double annualGrossPayrollUsd;
  final double totalTosWithheldKhr;
  final double totalTosWithheldUsd;

  GdtTaxReportModel({
    required this.taxAuthority,
    required this.schoolTin,
    required this.schoolName,
    required this.taxYear,
    required this.nbcRate,
    required this.annualRevenueUsd,
    required this.annualRevenueKhr,
    required this.deductibleExpensesUsd,
    required this.taxableProfitKhr,
    required this.standardProfitTaxKhr,
    required this.minimumTaxKhr,
    required this.finalTaxLiabilityKhr,
    required this.finalTaxLiabilityUsd,
    required this.ruleApplied,
    required this.annualGrossPayrollUsd,
    required this.totalTosWithheldKhr,
    required this.totalTosWithheldUsd,
  });

  factory GdtTaxReportModel.fromJson(Map<String, dynamic> json) {
    final profit = json['annual_profit_tax'] ?? {};
    final tos = json['tax_on_salary_summary'] ?? {};

    return GdtTaxReportModel(
      taxAuthority: json['tax_authority'] ?? 'General Department of Taxation (GDT)',
      schoolTin: json['school_tax_tin'] ?? 'K008-90234812',
      schoolName: json['school_name'] ?? 'PSI-VH',
      taxYear: json['tax_year'] ?? 2026,
      nbcRate: (json['official_nbc_rate'] as num?)?.toDouble() ?? 4100.0,
      annualRevenueUsd: (profit['annual_revenue_usd'] as num?)?.toDouble() ?? 0.0,
      annualRevenueKhr: (profit['annual_revenue_khr'] as num?)?.toDouble() ?? 0.0,
      deductibleExpensesUsd: (profit['deductible_expenses_usd'] as num?)?.toDouble() ?? 0.0,
      taxableProfitKhr: (profit['taxable_profit_khr'] as num?)?.toDouble() ?? 0.0,
      standardProfitTaxKhr: (profit['standard_profit_tax_khr'] as num?)?.toDouble() ?? 0.0,
      minimumTaxKhr: (profit['minimum_tax_khr'] as num?)?.toDouble() ?? 0.0,
      finalTaxLiabilityKhr: (profit['final_tax_liability_khr'] as num?)?.toDouble() ?? 0.0,
      finalTaxLiabilityUsd: (profit['final_tax_liability_usd'] as num?)?.toDouble() ?? 0.0,
      ruleApplied: profit['rule_applied'] ?? '20% Tax on Profit',
      annualGrossPayrollUsd: (tos['annual_gross_payroll_usd'] as num?)?.toDouble() ?? 0.0,
      totalTosWithheldKhr: (tos['total_tos_withheld_khr'] as num?)?.toDouble() ?? 0.0,
      totalTosWithheldUsd: (tos['total_tos_withheld_usd'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

