class PayrollCycleModel {
  final String id;
  final String cycleCode;
  final String startDate;
  final String endDate;
  final String closeLockDeadline;
  final bool isClosedLocked;
  final String? closedAt;
  final int totalEmployees;
  final double totalPayoutUsd;
  final double totalGdtTaxKhr;

  PayrollCycleModel({
    required this.id,
    required this.cycleCode,
    required this.startDate,
    required this.endDate,
    required this.closeLockDeadline,
    required this.isClosedLocked,
    this.closedAt,
    required this.totalEmployees,
    required this.totalPayoutUsd,
    required this.totalGdtTaxKhr,
  });

  factory PayrollCycleModel.fromJson(Map<String, dynamic> json) {
    return PayrollCycleModel(
      id: json['id'] ?? '',
      cycleCode: json['cycle_code'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      closeLockDeadline: json['close_lock_deadline'] ?? '',
      isClosedLocked: json['is_closed_locked'] ?? false,
      closedAt: json['closed_at'],
      totalEmployees: json['total_employees'] ?? 0,
      totalPayoutUsd: (json['total_payout_usd'] as num?)?.toDouble() ?? 0.0,
      totalGdtTaxKhr: (json['total_gdt_tax_khr'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PayrollSlipModel {
  final String id;
  final String employeeName;
  final String? khmerName;
  final String employmentType;
  final double baseSalaryUsd;
  final int totalPartTimeMinutes;
  final double partTimeWageUsd;
  final double grossSalaryUsd;
  final double grossSalaryKhr;
  final double dependentRebateKhr;
  final double taxableSalaryKhr;
  final double gdtTaxOnSalaryKhr;
  final double gdtTaxOnSalaryUsd;
  final double netSalaryUsd;
  final double netSalaryKhr;
  final String paymentStatus;

  PayrollSlipModel({
    required this.id,
    required this.employeeName,
    this.khmerName,
    required this.employmentType,
    required this.baseSalaryUsd,
    required this.totalPartTimeMinutes,
    required this.partTimeWageUsd,
    required this.grossSalaryUsd,
    required this.grossSalaryKhr,
    required this.dependentRebateKhr,
    required this.taxableSalaryKhr,
    required this.gdtTaxOnSalaryKhr,
    required this.gdtTaxOnSalaryUsd,
    required this.netSalaryUsd,
    required this.netSalaryKhr,
    required this.paymentStatus,
  });

  factory PayrollSlipModel.fromJson(Map<String, dynamic> json) {
    return PayrollSlipModel(
      id: json['id'] ?? '',
      employeeName: json['employee_name'] ?? 'Employee',
      khmerName: json['khmer_name'],
      employmentType: json['employment_type'] ?? 'FULL_TIME',
      baseSalaryUsd: (json['base_salary_usd'] as num?)?.toDouble() ?? 0.0,
      totalPartTimeMinutes: (json['total_part_time_minutes'] as num?)?.toInt() ?? 0,
      partTimeWageUsd: (json['part_time_wage_usd'] as num?)?.toDouble() ?? 0.0,
      grossSalaryUsd: (json['gross_salary_usd'] as num?)?.toDouble() ?? 0.0,
      grossSalaryKhr: (json['gross_salary_khr'] as num?)?.toDouble() ?? 0.0,
      dependentRebateKhr: (json['dependent_rebate_khr'] as num?)?.toDouble() ?? 0.0,
      taxableSalaryKhr: (json['taxable_salary_khr'] as num?)?.toDouble() ?? 0.0,
      gdtTaxOnSalaryKhr: (json['gdt_tax_on_salary_khr'] as num?)?.toDouble() ?? 0.0,
      gdtTaxOnSalaryUsd: (json['gdt_tax_on_salary_usd'] as num?)?.toDouble() ?? 0.0,
      netSalaryUsd: (json['net_salary_usd'] as num?)?.toDouble() ?? 0.0,
      netSalaryKhr: (json['net_salary_khr'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'APPROVED',
    );
  }
}

