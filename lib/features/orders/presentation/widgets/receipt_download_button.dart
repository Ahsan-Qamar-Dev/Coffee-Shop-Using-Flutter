import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../data/receipt_export.dart';
import '../../data/receipt_pdf.dart';
import '../../domain/coffee_order.dart';

class ReceiptDownloadButton extends StatefulWidget {
  const ReceiptDownloadButton({super.key, required this.order});
  final CoffeeOrder order;

  @override
  State<ReceiptDownloadButton> createState() => _ReceiptDownloadButtonState();
}

class _ReceiptDownloadButtonState extends State<ReceiptDownloadButton> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final bytes = await ReceiptPdf.build(widget.order);
      if (!mounted) return;
      final saved = await ReceiptExport.save(bytes, widget.order.id);
      if (mounted && saved) {
        AppFeedback.show(context, 'Receipt exported successfully.');
      }
    } catch (error, stack) {
      debugPrint('Receipt export failed: $error\n$stack');
      if (!mounted) return;
      AppFeedback.show(
        context,
        error is MissingPluginException
            ? 'Please close the app and install the latest update to save PDFs.'
            : error is PlatformException
            ? 'Could not save the PDF. Try another folder and check available storage.'
            : 'Could not create the receipt PDF. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const ValueKey('download-receipt'),
    onPressed: _saving ? null : _save,
    icon: _saving
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.download_outlined),
    label: Text(_saving ? 'Preparing receipt…' : 'Save receipt PDF'),
  );
}
