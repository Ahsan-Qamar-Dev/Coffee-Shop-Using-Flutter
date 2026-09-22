import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../profile/domain/customer_preferences.dart';
import '../domain/coffee_order.dart';

class ReceiptPdf {
  static const _ink = PdfColor.fromInt(0xFF29231F);
  static const _accent = PdfColor.fromInt(0xFFFFBF8D);
  static const _muted = PdfColor.fromInt(0xFF766A62);
  static const _line = PdfColor.fromInt(0xFFE8DED6);

  static Future<Uint8List> build(CoffeeOrder order) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/roboto-regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/roboto-bold.ttf'),
    );
    final display = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Poppins-Bold.ttf'),
    );
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    final draft = order.draft;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 14),
          child: pw.Text(
            'Preview receipt | No payment taken or order sent.  Page ${context.pageNumber} of ${context.pagesCount}',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(color: _muted, fontSize: 9),
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: _ink,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MY COFFEE SHOP',
                      style: pw.TextStyle(
                        font: display,
                        fontSize: 20,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Transaction receipt',
                      style: const pw.TextStyle(color: _accent, fontSize: 11),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: order.cancelled ? PdfColors.red200 : _accent,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    order.cancelled ? 'CANCELLED' : 'CONFIRMED',
                    style: pw.TextStyle(color: _ink, font: bold, fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 22),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _meta('Transaction', order.id, bold),
              _meta('Date', _date(order.createdAt), bold, alignEnd: true),
            ],
          ),
          pw.SizedBox(height: 22),
          pw.Text(
            'ORDER SUMMARY',
            style: pw.TextStyle(font: bold, fontSize: 10, color: _muted),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Coffee / size', 'Qty', 'Each', 'Amount'],
            data: [
              for (final line in draft.lines)
                [
                  '${line.coffee.name} · ${line.size}',
                  '${line.quantity}',
                  _money(line.unitPriceCents),
                  _money(line.totalCents),
                ],
            ],
            headerStyle: pw.TextStyle(font: bold, fontSize: 10, color: _ink),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: _accent),
            cellPadding: const pw.EdgeInsets.all(8),
            border: pw.TableBorder.all(color: _line, width: .5),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
            },
            cellAlignments: {
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 14),
          _amountRow('Subtotal', draft.subtotalCents),
          pw.SizedBox(height: 7),
          _amountRow(
            draft.delivery ? 'Delivery' : 'Pickup',
            draft.deliveryCents,
          ),
          pw.Divider(color: _line, height: 20),
          _amountRow('Total', draft.totalCents, emphasized: true),
          pw.SizedBox(height: 22),
          pw.Text(
            draft.delivery ? 'DELIVERY DETAILS' : 'PICKUP DETAILS',
            style: pw.TextStyle(font: bold, fontSize: 10, color: _muted),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFFFF5ED),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  draft.customerName,
                  style: pw.TextStyle(font: bold, fontSize: 11),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  draft.delivery
                      ? '${draft.address!.label}\n${draft.address!.summary}\n${draft.address!.phone}'
                      : 'Collect at the coffee counter.\nStore location and pickup times will be available for live orders.',
                  style: const pw.TextStyle(
                    color: _muted,
                    fontSize: 10,
                    lineSpacing: 4,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Payment: ${draft.payment.label}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (draft.note.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Order note: ${draft.note}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _meta(
    String label,
    String value,
    pw.Font bold, {
    bool alignEnd = false,
  }) => pw.Column(
    crossAxisAlignment: alignEnd
        ? pw.CrossAxisAlignment.end
        : pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        label.toUpperCase(),
        style: const pw.TextStyle(color: _muted, fontSize: 8),
      ),
      pw.SizedBox(height: 4),
      pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 10)),
    ],
  );

  static pw.Widget _amountRow(
    String label,
    int cents, {
    bool emphasized = false,
  }) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: emphasized ? 13 : 10,
          fontWeight: emphasized ? pw.FontWeight.bold : null,
        ),
      ),
      pw.Text(
        _money(cents),
        style: pw.TextStyle(
          fontSize: emphasized ? 15 : 10,
          fontWeight: emphasized ? pw.FontWeight.bold : null,
          color: emphasized ? _ink : _muted,
        ),
      ),
    ],
  );

  static String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
