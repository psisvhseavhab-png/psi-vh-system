import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintingService {
  /// Generates and prints an 80mm thermal receipt
  static Future<void> printThermalReceipt({
    required String invoiceNumber,
    required String cashierName,
    required DateTime timestamp,
    required List<Map<String, dynamic>> items,
    required double totalUsd,
    required double totalKhr,
    required String paymentMethod,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 4 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('PREAH SIHANOUK INTL SCHOOL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.Text('PSI-VH CAMPUS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text('Tel: +855 34 933 888 | www.psivh.edu.kh', style: const pw.TextStyle(fontSize: 7)),
              pw.Divider(thickness: 0.5),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Inv #: $invoiceNumber', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('Date: ${timestamp.toString().substring(0, 19)}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('Cashier: $cashierName', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('Method: $paymentMethod', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
              pw.Divider(thickness: 0.5),
              // Items Table
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Item', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Qty', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      pw.Text('Total', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                    ],
                  ),
                  ...items.map((item) => pw.TableRow(
                    children: [
                      pw.Text(item['name'] ?? '', style: const pw.TextStyle(fontSize: 7)),
                      pw.Text('${item['qty']}', style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
                      pw.Text('\$${(item['total'] as num).toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.right),
                    ],
                  )),
                ],
              ),
              pw.Divider(thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL USD:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${totalUsd.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL KHR:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${totalKhr.toStringAsFixed(0)} Riel', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.BarcodeWidget(
                data: invoiceNumber,
                barcode: pw.Barcode.code128(),
                width: 140,
                height: 35,
              ),
              pw.SizedBox(height: 6),
              pw.Text('Thank you for choosing PSI-VH!', style: const pw.TextStyle(fontSize: 7)),
              pw.Text('No returns without valid receipt.', style: const pw.TextStyle(fontSize: 6)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt-$invoiceNumber',
    );
  }

  /// Generates and prints an official A4 School Tuition / Services Invoice
  static Future<void> printA4Invoice({
    required String invoiceNumber,
    required String studentName,
    required String studentCode,
    required String programName,
    required List<Map<String, dynamic>> lineItems,
    required double totalUsd,
    required double totalKhr,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PREAH SIHANOUK INTERNATIONAL SCHOOL (PSI-VH)',
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text('Cambodia MoEYS & Cambridge Academic Center', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        pw.Text('TIN: K008-90234812 | Tel: +855 34 933 888', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('OFFICIAL INVOICE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.amber800)),
                        pw.Text('No: $invoiceNumber', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date: ${DateTime.now().toString().substring(0, 10)}', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                pw.SizedBox(height: 12),
                pw.Text('BILL TO:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text('Student Name: $studentName ($studentCode)', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Enrolled Program: $programName', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 16),
                // Table of charges
                pw.TableHelper.fromTextArray(
                  headers: ['No', 'Item Description', 'Unit Price (USD)', 'Qty', 'Total (USD)'],
                  data: List<List<dynamic>>.generate(
                    lineItems.length,
                    (index) => [
                      '${index + 1}',
                      lineItems[index]['name'],
                      '\$${(lineItems[index]['unit_price'] as num).toStringAsFixed(2)}',
                      '${lineItems[index]['qty']}',
                      '\$${(lineItems[index]['total'] as num).toStringAsFixed(2)}',
                    ],
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  cellHeight: 28,
                ),
                pw.SizedBox(height: 16),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Grand Total USD: \$${totalUsd.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Grand Total KHR: ${totalKhr.toStringAsFixed(0)} Riel',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                      pw.Text('(Exchange Rate: 1 USD = 4,100 KHR)', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('_______________________', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Student / Guardian Signature', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('_______________________', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Authorized School Cashier / Seal', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice-$invoiceNumber',
    );
  }
}

