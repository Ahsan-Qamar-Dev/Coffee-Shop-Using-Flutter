import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_coffee_shop/core/widgets/shop_motion.dart';

void main() {
  testWidgets(
    'compact add control keeps a full touch target and accepts rapid taps',
    (tester) async {
      var additions = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CompactActionButton(
                key: const ValueKey('add'),
                icon: Icons.add_rounded,
                tooltip: 'Add coffee',
                confirmAddition: true,
                onPressed: () => additions++,
              ),
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('add'))),
        const Size(48, 48),
      );
      expect(tester.widget<Icon>(find.byIcon(Icons.add_rounded)).size, 18);
      await tester.tap(find.byKey(const ValueKey('add')));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tap(find.byKey(const ValueKey('add')));
      await tester.pump(const Duration(milliseconds: 170));
      expect(additions, 2);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  for (final reduced in [false, true]) {
    testWidgets(
      'tab animation retains field state with reduced motion $reduced',
      (tester) async {
        final index = ValueNotifier(0);
        addTearDown(index.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Scaffold(
                body: ValueListenableBuilder<int>(
                  valueListenable: index,
                  builder: (_, value, _) => MotionTabStack(
                    index: value,
                    children: const [
                      TextField(),
                      Center(child: Text('Second tab')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), 'latte');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        index.value = 1;
        await tester.pump();
        if (reduced) {
          final fade = tester.widget<FadeTransition>(
            find
                .descendant(
                  of: find.byType(MotionTabStack),
                  matching: find.byType(FadeTransition),
                )
                .first,
          );
          expect(fade.opacity.value, 1);
        } else {
          // Pump at 120 Hz: motion follows elapsed time, not a fixed 60 Hz timer.
          for (var frame = 0; frame < 30; frame++) {
            await tester.pump(const Duration(microseconds: 8333));
          }
        }
        await tester.pumpAndSettle();
        expect(find.text('Second tab'), findsOneWidget);
        index.value = 0;
        await tester.pumpAndSettle();
        expect(find.text('latte'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(tester.binding.hasScheduledFrame, isFalse);
      },
    );
  }

  testWidgets('disposing an add button safely cancels its confirmation timer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CompactActionButton(
          icon: Icons.add_rounded,
          tooltip: 'Add',
          confirmAddition: true,
          onPressed: () {},
        ),
      ),
    );
    await tester.tap(find.byType(CompactActionButton));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
