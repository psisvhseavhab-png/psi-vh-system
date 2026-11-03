import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../models/procurement_model.dart';
import '../../../widgets/custom_badge.dart';
import '../../auth/providers/auth_provider.dart';

class ProcurementWorkflowView extends StatefulWidget {
  const ProcurementWorkflowView({Key? key}) : super(key: key);

  @override
  State<ProcurementWorkflowView> createState() => _ProcurementWorkflowViewState();
}

class _ProcurementWorkflowViewState extends State<ProcurementWorkflowView> {
  bool _isLoading = true;
  List<ProcurementRequestModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().get(ApiEndpoints.procurementRequests);
      if (mounted) {
        setState(() {
          _requests = (res.data as List)
              .map((r) => ProcurementRequestModel.fromJson(r))
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleHeadReview(String reqId, String action, String comments) async {
    try {
      await ApiClient().post(ApiEndpoints.headReview(reqId), data: {
        'action': action,
        'comments': comments,
      });
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request marked as $action by Department Head')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _handleAccountingReview(String reqId, String action, String comments, double amount) async {
    try {
      await ApiClient().post(ApiEndpoints.accountingReview(reqId), data: {
        'action': action,
        'comments': comments,
        'disbursed_amount_usd': amount,
      });
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accounting $action finalized & ledger updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userRole = auth.currentRole;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & New Request Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Departmental Procurement & Multi-Tier Approval Workflow',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Teacher Request ➔ Department Head Approval ➔ Accounting Review & Ledger Disbursement',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showNewRequestDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Submit Materials Request', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Requests List Table
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_requests.isEmpty)
            const Center(child: Text('No procurement requests found.'))
          else
            ..._requests.map((r) => _buildRequestCard(r, userRole)).toList(),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ProcurementRequestModel r, String userRole) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Row(
                children: [
                  Text(
                    r.requestNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy),
                  ),
                  const SizedBox(width: 10),
                  CustomBadge(
                    label: r.priority,
                    backgroundColor: r.priority == 'HIGH' ? AppColors.lightRed : AppColors.lightOrange,
                    textColor: r.priority == 'HIGH' ? AppColors.dangerRed : AppColors.warningOrange,
                  ),
                ],
              ),
              _buildStatusBadge(r.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Purpose: ${r.purpose}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Item Details: ${r.itemDetails} (Quantity: ${r.quantity})', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 12),

          // Multi-Tier Visual Stepper
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _workflowStep(
                  '1. Submission',
                  r.requesterName,
                  Icons.person,
                  true,
                ),
                _workflowArrow(),
                _workflowStep(
                  '2. Department Head',
                  r.headReviewedAt != null ? 'Approved' : 'Pending Review',
                  Icons.supervisor_account,
                  r.status != 'PENDING_HEAD',
                  isRejected: r.status == 'HEAD_REJECTED',
                ),
                _workflowArrow(),
                _workflowStep(
                  '3. Accounting Final',
                  r.accountingReviewedAt != null ? 'Disbursed' : 'Awaiting Review',
                  Icons.account_balance,
                  r.status == 'ACCOUNTING_APPROVED',
                  isRejected: r.status == 'ACCOUNTING_REJECTED',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Financial Cost & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimated Budget Required:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(
                    CurrencyFormatter.formatBoth(r.estimatedCostUsd),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy),
                  ),
                ],
              ),
              Row(
                children: [
                  // Head Approval button
                  if (r.status == 'PENDING_HEAD' &&
                      (userRole == 'DEPARTMENT_HEAD' || userRole == 'SCHOOL_DIRECTOR' || userRole == 'SUPER_ADMIN'))
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _handleHeadReview(r.id, 'REJECT', 'Rejected by Head'),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.dangerRed),
                          child: const Text('Reject', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleHeadReview(r.id, 'APPROVE', 'Approved by Department Head'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
                          child: const Text('Head Approve ➔', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),

                  // Accounting Approval button
                  if (r.status == 'HEAD_APPROVED' &&
                      (userRole == 'ACCOUNTANT' || userRole == 'SCHOOL_DIRECTOR' || userRole == 'SUPER_ADMIN'))
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _handleAccountingReview(r.id, 'REJECT', 'Budget rejected', 0),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.dangerRed),
                          child: const Text('Decline Budget', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _handleAccountingReview(r.id, 'APPROVE', 'Approved and disbursed', r.estimatedCostUsd),
                          icon: const Icon(Icons.check, size: 14),
                          label: const Text('Accounting Disburse', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'PENDING_HEAD':
        return CustomBadge.warning('Awaiting Dept Head');
      case 'HEAD_APPROVED':
        return CustomBadge.info('Head Approved ➔ Awaiting Accounting');
      case 'ACCOUNTING_APPROVED':
        return CustomBadge.success('Accounting Disbursed');
      case 'HEAD_REJECTED':
      case 'ACCOUNTING_REJECTED':
        return CustomBadge.danger('Rejected');
      default:
        return CustomBadge(label: status, backgroundColor: Colors.grey, textColor: Colors.white);
    }
  }

  Widget _workflowStep(String title, String subtitle, IconData icon, bool isPassed, {bool isRejected = false}) {
    Color color = isRejected ? AppColors.dangerRed : (isPassed ? AppColors.successGreen : AppColors.textMuted);
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: color)),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textMuted), maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _workflowArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.divider),
    );
  }

  void _showNewRequestDialog() {
    final titleCtrl = TextEditingController();
    final itemCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Materials / Supplies Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title / Subject')),
              TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'Item Specifications & Quantity')),
              TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'Educational Purpose')),
              TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated Cost (USD)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final deptId = auth.currentUser?.departmentId ?? 'default_dept';
              await ApiClient().post(ApiEndpoints.procurementRequests, data: {
                'department_id': deptId,
                'title': titleCtrl.text,
                'item_details': itemCtrl.text,
                'purpose': purposeCtrl.text,
                'quantity': 1,
                'estimated_cost_usd': double.tryParse(costCtrl.text) ?? 50.0,
                'required_by_date': DateTime.now().add(const Duration(days: 14)).toIso8601String().substring(0, 10),
                'priority': 'HIGH',
              });
              Navigator.pop(ctx);
              _loadRequests();
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}

