class ProcurementRequestModel {
  final String id;
  final String requestNumber;
  final String title;
  final String departmentName;
  final String requesterName;
  final String itemDetails;
  final String purpose;
  final int quantity;
  final double estimatedCostUsd;
  final double estimatedCostKhr;
  final String requiredByDate;
  final String priority;
  final String status;
  final String? headComments;
  final String? headReviewedAt;
  final String? accountingComments;
  final String? accountingReviewedAt;
  final String createdAt;

  ProcurementRequestModel({
    required this.id,
    required this.requestNumber,
    required this.title,
    required this.departmentName,
    required this.requesterName,
    required this.itemDetails,
    required this.purpose,
    required this.quantity,
    required this.estimatedCostUsd,
    required this.estimatedCostKhr,
    required this.requiredByDate,
    required this.priority,
    required this.status,
    this.headComments,
    this.headReviewedAt,
    this.accountingComments,
    this.accountingReviewedAt,
    required this.createdAt,
  });

  factory ProcurementRequestModel.fromJson(Map<String, dynamic> json) {
    return ProcurementRequestModel(
      id: json['id'] ?? '',
      requestNumber: json['request_number'] ?? '',
      title: json['title'] ?? '',
      departmentName: json['department_name'] ?? 'Department',
      requesterName: json['requester_name'] ?? 'Staff',
      itemDetails: json['item_details'] ?? '',
      purpose: json['purpose'] ?? '',
      quantity: json['quantity'] ?? 1,
      estimatedCostUsd: (json['estimated_cost_usd'] as num?)?.toDouble() ?? 0.0,
      estimatedCostKhr: (json['estimated_cost_khr'] as num?)?.toDouble() ?? 0.0,
      requiredByDate: json['required_by_date'] ?? '',
      priority: json['priority'] ?? 'MEDIUM',
      status: json['status'] ?? 'PENDING_HEAD',
      headComments: json['head_comments'],
      headReviewedAt: json['head_reviewed_at'],
      accountingComments: json['accounting_comments'],
      accountingReviewedAt: json['accounting_reviewed_at'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

