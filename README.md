# Coffee Shop

A Flutter coffee ordering UI with dark/light themes, responsive layouts, GetX state management and session-only demo adapters. The UI phase is complete; live services are the next phase.

## Run

```sh
flutter pub get
flutter run
```

Choose **Try demo account**, or sign in with `demo@coffee.test` / `Coffee123!`. Registration and password changes work in memory. Use test details. Nothing is charged, dispatched or emailed.

## Connected flows

- Shared navigation shell: Home, Favorites, Cart and Alerts; the drawer works on every tab.
- Catalog: combined search/category filtering, details, size-dependent prices, favorites and quick add.
- Cart: quantity changes, removal, empty-state recovery and checkout.
- Checkout: pickup/delivery, address validation, payment preference, order notes and itemized totals.
- Orders: confirmation receipt, history, cancellation, reorder and navigation from notifications.
- Account: editable name/phone, delivery address, payment preference, password change, theme, in-app notification preference, help and sign-out.

## Verification

```sh
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

Tests cover authentication, shared-drawer navigation, filtering, pricing, checkout, delivery validation, receipts, notifications, reorder, profile edits, password changes, theme updates and session cleanup. The responsive matrix covers 14 screens at 320x568 and 844x390 with doubled text, plus 1024x768.

Optional visual previews:

```sh
flutter test --no-pub --dart-define=CAPTURE_UI=true --update-goldens test/ui_preview_test.dart
```

See `docs/UI_PHASE.md` for architecture boundaries and the backend handoff.
