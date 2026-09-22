
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_coffee_shop/features/orders/data/receipt_export.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReceiptExport.channel, null);
  });
  test(
    'Android saves PDF bytes and safe filename through the document picker',
    () async {
      MethodCall? received;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ReceiptExport.channel, (call) async {
            received = call;
            return true;
          });
      final bytes = Uint8List.fromList([37, 80, 68, 70]);
      expect(await ReceiptExport.save(bytes, 'CF/42'), isTrue);
      expect(received!.method, 'savePdf');
      expect(received!.arguments['name'], 'receipt-CF_42.pdf');
      expect(received!.arguments['bytes'], bytes);
    },
  );
  test('cancel is not reported as a successful save', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReceiptExport.channel, (_) async => false);
    expect(await ReceiptExport.save(Uint8List(4), 'CF-42'), isFalse);
  });
  test('storage failures propagate to the UI', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          ReceiptExport.channel,
          (_) async => throw PlatformException(code: 'save_failed'),
        );
    expect(
      ReceiptExport.save(Uint8List(4), 'CF-42'),
      throwsA(isA<PlatformException>()),
    );
  });
}
