import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class ReceiptExport {
  static const channel = MethodChannel('coffee_shop/receipt');

  /// Returns false when the user dismisses the save dialog.
  static Future<bool> save(Uint8List bytes, String orderId) async {
    final safeId = orderId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final name = 'receipt-$safeId.pdf';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return await channel.invokeMethod<bool>('savePdf', {
            'bytes': bytes,
            'name': name,
          }) ??
          false;
    }
    return Printing.sharePdf(bytes: bytes, filename: name);
  }
}
