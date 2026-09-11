# Coffee Shop — Day 1

## Implemented
- Replaced Provider with GetX controllers and explicit dependency registration in lib/app/app_binding.dart.
- Organized screens by feature. Authentication separates presentation/controllers, domain repository contract and entities, and a demo data adapter. Shared themes/widgets are in core; application composition and sign-out coordination are in app.
- Preserved coffee artwork, dark/light modes, orange accent and rounded visual treatment.
- Added responsive sign-in, registration and recovery preview screens with validation, confirmation matching, password visibility, loading states, keyboard scrolling, duplicate-submit protection and error feedback.
- Demo login and registration reach the existing home. Profile text reads the current preview user. Sign-out clears session cart/favorites.
- Centralized styled snackbars for authentication and catalog actions.
- Made detail-page size controls and purchase bar responsive.
- Bundled existing Poppins heading font and Roboto body fonts, including licenses, eliminating runtime font downloads and the now-unneeded Google Fonts dependency.

## Architecture boundaries
UI -> GetX controller -> AuthRepository interface -> DemoAuthRepository.
The domain layer has no Flutter or GetX imports. Replace the demo repository with a remote adapter when connecting the backend. Controllers expose state/results; views handle navigation and feedback. Existing catalog/cart/favorites behavior was retained while moving it to feature folders; backend repositories for those features are future work.

## Try it
Open the existing project at D:\flutter_projects\Day 1\my_coffee_shop and run flutter run. Fully restart the app after this refactor; hot reload alone cannot replace the old Provider setup.
On the login screen choose Try demo account, or use demo@coffee.test / Coffee123!.
Registration creates an in-memory preview account for the current process only. Use test credentials. Password recovery explicitly simulates submission and does not send email. Do not deploy this adapter as production authentication.

## Validation
flutter analyze --no-pub: passed.
42 checks passed in the test run including four rendered previews. Authentication layout matrix: 320x568, 390x844, 844x390, 1024x768, at normal and doubled text scaling. Also tested keyboard/validation, preview registration and sign-in, duplicate submission, error feedback, cart quantity/size behavior, GetX cart/favorite rebuilding, and the detail screen at 320px width with normal/doubled text.
Rendered login (dark/light), sign-up and recovery previews were visually reviewed. This is not an exhaustive device test of every existing screen.
Normal test command: flutter test --no-pub.
Optional preview generation: flutter test --no-pub --dart-define=CAPTURE_DAY1=true --update-goldens.

## Preserved checkpoint
D:\Development\Backups\CoffeeShop-Day1-20260911-173852 contains the pre-change lib, test, pubspec.yaml and pubspec.lock, including the user's uncommitted detail-page changes. No git commits or resets were performed.

## Next session
Polish and test the full catalog/cart/checkout flow across screen sizes. Move filtering/pricing logic behind the appropriate boundaries as needed. Replace static notifications, payment success and profile settings with meaningful implementations in their respective stages. Real authentication, persistence, server-side pricing/order validation, staff order management and realtime updates require backend work.
