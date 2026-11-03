import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/printing_service.dart';
import '../../../widgets/custom_badge.dart';

class DocumentPrintCenterView extends StatelessWidget {
  const DocumentPrintCenterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Generation & Print Center',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Student Smart ID Cards with QR • A4 Tuition Invoices • 80mm Thermal Cashier Receipts',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              CustomBadge(
                label: 'Direct Thermal & PDF Printing',
                backgroundColor: AppColors.lightBlue,
                textColor: AppColors.primaryBlue,
                icon: Icons.print,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cards Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Student Smart ID Card Preview & Print
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Student Smart ID Card (CR80)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 16),

                      // ID Card Physical Frame
                      Container(
                        width: 320,
                        height: 200,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryNavy, Color(0xFF1E3A8A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('PSI-VH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.primaryNavy)),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'PREAH SIHANOUK INTL SCHOOL',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 14),
                            Row(
                              children: [
                                // Photo Box
                                Container(
                                  width: 65,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.accentGold, width: 1.5),
                                  ),
                                  child: const Icon(Icons.person, size: 40, color: Colors.white70),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('SOK BOPHA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('សុខ បុប្ផា', style: TextStyle(color: AppColors.accentGold, fontSize: 11)),
                                      SizedBox(height: 4),
                                      Text('ID: PSI-G10-2026-042', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                      Text('Grade: 10-A (Science)', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                      Text('Valid: 2026 - 2027', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                    ],
                                  ),
                                ),
                                // Gate QR Code
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(4),
                                  child: QrImageView(
                                    data: 'QR-GATE-PSI-G10-042',
                                    version: QrVersions.auto,
                                    size: 60,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              'Authorized MoEYS / Cambridge Student Pass • Emergency: +855 34 933 888',
                              style: TextStyle(color: Colors.white60, fontSize: 7),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ID Card layout dispatched to card printer!')),
                          );
                        },
                        icon: const Icon(Icons.badge, size: 16),
                        label: const Text('Print Student ID Card', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // 2. Official A4 Invoice Preview & Print
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Official A4 School Tuition Invoice',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 280,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PSI-VH OFFICIAL INVOICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryNavy)),
                            const Text('No: INV-PSI-2026-TERM1', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                            const Divider(height: 12),
                            const Text('Bill to: Sok Bopha (Grade 10)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            _sampleRow('Term 1 Academic Tuition', '\$1,250.00'),
                            _sampleRow('School Bus Pass (Route 1)', '\$45.00'),
                            _sampleRow('Cambridge Textbooks Bundle', '\$78.00'),
                            const Divider(height: 12),
                            _sampleRow('TOTAL USD', '\$1,373.00', isBold: true),
                            _sampleRow('TOTAL KHR', '5,629,300 ៛', isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await PrintingService.printA4Invoice(
                            invoiceNumber: 'INV-PSI-2026-TERM1',
                            studentName: 'Sok Bopha',
                            studentCode: 'PSI-G10-2026-042',
                            programName: 'General Education Grade 10-A',
                            lineItems: [
                              {'name': 'Term 1 Academic Tuition', 'unit_price': 1250.0, 'qty': 1, 'total': 1250.0},
                              {'name': 'Monthly Bus Pass (Route 1)', 'unit_price': 45.0, 'qty': 1, 'total': 45.0},
                              {'name': 'Cambridge Textbooks Bundle', 'unit_price': 78.0, 'qty': 1, 'total': 78.0},
                            ],
                            totalUsd: 1373.0,
                            totalKhr: 1373.0 * 4100.0,
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text('Generate & Print A4 Invoice', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // 3. Thermal 80mm Receipt
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Thermal 80mm POS Slip',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: const [
                            Text('PSI-VH STORE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                            Text('Tel: +855 34 933 888', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                            Divider(height: 8),
                            Text('2x School Polo Shirt (M)', style: TextStyle(fontSize: 8)),
                            Text('Total: \$28.00 (114,800 ៛)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
                            SizedBox(height: 6),
                            Icon(Icons.barcode_reader, size: 36, color: AppColors.textPrimary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await PrintingService.printThermalReceipt(
                            invoiceNumber: 'INV-DEMO-80MM',
                            cashierName: 'Cashier 01',
                            timestamp: DateTime.now(),
                            items: [
                              {'name': 'School Polo Shirt (M)', 'qty': 2, 'total': 28.0},
                            ],
                            totalUsd: 28.0,
                            totalKhr: 114800.0,
                            paymentMethod: 'KHQR_BAKONG',
                          );
                        },
                        icon: const Icon(Icons.receipt, size: 16),
                        label: const Text('Print 80mm Thermal Slip', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
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

  Widget _sampleRow(String title, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 8, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontSize: 8, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

