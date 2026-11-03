import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/custom_badge.dart';
import '../../auth/providers/auth_provider.dart';

class StudentPortalView extends StatefulWidget {
  final Function(int) onNavigate;
  const StudentPortalView({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<StudentPortalView> createState() => _StudentPortalViewState();
}

class _StudentPortalViewState extends State<StudentPortalView> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Student / Parent Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student & Parent Portal • PSI-VH',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                  ),
                  Text(
                    'Student: Sok Bopha (PSI-G10-2026-042) • Grade 10-A Bilingual Program',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              CustomBadge.success('Gate Status: On Campus (Gate A)', icon: Icons.check_circle),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Top Row: Digital Smart ID Card & Gate Telemetry
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Digital ID Card
              Container(
                width: 380,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryNavy, Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('PSI-VH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.primaryNavy)),
                            ),
                            const SizedBox(width: 8),
                            const Text('STUDENT PASS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                        const Icon(Icons.nfc, color: Colors.white70, size: 20),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 16),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accentGold, width: 1.5),
                          ),
                          child: const Icon(Icons.person, size: 38, color: Colors.white70),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('SOK BOPHA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('សុខ បុប្ផា', style: TextStyle(color: AppColors.accentGold, fontSize: 11)),
                              SizedBox(height: 4),
                              Text('ID: PSI-G10-2026-042', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              Text('Grade: 10-A (Science & Tech)', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              Text('Academic Year: 2026-2027', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(4),
                          child: QrImageView(
                            data: 'QR-GATE-PSI-G10-042',
                            version: QrVersions.auto,
                            size: 65,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Authorized MoEYS / Cambridge Student', style: TextStyle(color: Colors.white60, fontSize: 8)),
                        Text('Emergency: +855 34 933 888', style: TextStyle(color: Colors.white60, fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Gate Activity & School Bus Tracking
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Today Safety & Transportation Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          CustomBadge(label: 'Telegram Push Active', backgroundColor: AppColors.lightGreen, textColor: AppColors.successGreen, icon: Icons.notifications_active),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _telemetryItem(
                        icon: Icons.login,
                        color: AppColors.successGreen,
                        title: 'Campus Arrival Check-In',
                        subtitle: 'Scanned through Main Gate A at 07:42 AM. Push delivered to parent phone.',
                      ),
                      const SizedBox(height: 10),
                      _telemetryItem(
                        icon: Icons.directions_bus,
                        color: AppColors.primaryBlue,
                        title: 'School Bus Route 1 (Active Pass)',
                        subtitle: 'Bus Plate: SH-3A-4819 • Driver: Phorn Samnang (+855 11 223 344) • Seat #14',
                      ),
                      const SizedBox(height: 10),
                      _telemetryItem(
                        icon: Icons.restaurant,
                        color: AppColors.accentGold,
                        title: 'Canteen & Dietary Alert',
                        subtitle: 'Diet: Regular menu (No peanut allergy recorded). Clean bill of health.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Middle Section: Academic Performance & Tuition Invoices
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Transcripts & GPA
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
                          const Text('Academic Transcripts & Gradebook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          CustomBadge.success('GPA: 3.85 / 4.0 (Honor Roll)'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _subjectGradeRow('Mathematics & Calculus', 'Score: 92% • Letter Grade: A (4.0 GPA)'),
                      _subjectGradeRow('Cambridge Academic English', 'Score: 87% • Letter Grade: A (4.0 GPA)'),
                      _subjectGradeRow('Khmer Literature & History', 'Score: 80% • Letter Grade: B (3.0 GPA)'),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Promotion Status for Next Academic Year:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('QUALIFIED & PROMOTED ➔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.successGreen)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Tuition & Services Billing (Bakong KHQR)
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
                          Text('Tuition & Services Billing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          CustomBadge(label: 'All Paid Up', backgroundColor: AppColors.lightGreen, textColor: AppColors.successGreen),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _billingRow('Term 1 Academic Tuition', '\$1,250.00', 'PAID'),
                      _billingRow('Monthly Bus Pass (Oct-Nov)', '\$45.00', 'PAID'),
                      _billingRow('Uniform & Cambridge Books', '\$78.00', 'PAID'),
                      const Divider(height: 16),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => _showBakongPaymentModal(),
                          icon: const Icon(Icons.qr_code, size: 16),
                          label: const Text('Pay via National Bakong KHQR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _telemetryItem({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
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
    );
  }

  Widget _subjectGradeRow(String subject, String details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Text(details, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _billingRow(String title, String amount, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11)),
          Row(
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(width: 6),
              CustomBadge.success(status),
            ],
          ),
        ],
      ),
    );
  }

  void _showBakongPaymentModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.qr_code, color: AppColors.dangerRed),
            SizedBox(width: 8),
            Text('National Bakong KHQR Payment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Scan with any Cambodian Mobile Banking App (ABA, ACLEDA, Wing, Canadia, Bakong):',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.dangerRed, width: 2),
              ),
              child: Column(
                children: [
                  const Text('KHQR', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.dangerRed, fontSize: 16)),
                  const SizedBox(height: 6),
                  QrImageView(
                    data: 'KHQR:00020101021229370016A00000072703270101100203001520448125303840540545.005802KH5918PSI-VH INTL SCHOOL6014SIHANOUKVILLE6304E8A9',
                    version: QrVersions.auto,
                    size: 150,
                  ),
                  const SizedBox(height: 4),
                  const Text('Preah Sihanouk Intl School', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const Text('Amount: \$45.00 (184,500 ៛)', style: TextStyle(fontSize: 11, color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment verified via Bakong webhook! Receipt updated.')),
              );
            },
            child: const Text('Simulate Instant Payment'),
          ),
        ],
      ),
    );
  }
}

