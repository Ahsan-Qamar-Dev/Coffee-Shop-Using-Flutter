# Backend checkpoint — 23 September 2026

Status: database deployed; Flutter is connected for private testing.
Normal startup initializes Supabase; `--dart-define=DEMO_MODE=true` selects the
offline demo. Both SQL migrations were applied via
the Supabase SQL Editor to project `sxduvqxceyawunjonqaj` on 23 September 2026.
Hosted verification returned `coffees: 11`, `customer_state: 0`, `orders: 0`,
with row-level security enabled on all three tables. Hosted transactional tests
passed pricing, deduplication, cancellation and two-account isolation; synthetic
users/orders/state were rolled back. Real phone login is still pending.
Do not reapply the initial schema migration.
The user's requirement is a free service without subscriptions or billing setup.

## Prepared

- Supabase auth adapter (sign-in, sign-up, reset, profile name, password).
- Customer-scoped catalog/state repository and order repository.
- PostgreSQL tables and RLS policies for catalog, customer state and orders.
- Server-calculated prices, quantity validation, per-user request deduplication,
  checkout rate limit and ownership-checked cancellation.
- Eleven-product seed generated from the existing Flutter catalog. Reapplying
  the seed preserves merchant edits. Photos remain bundled in the app.
- Session restore, live catalog, serialized saves, sync retry banner, logout flush,
  cart/favorites/profile/address and notification read/dismiss persistence.
- Foreground order refresh every 30 seconds, stopped in background.
- Pending checkout UUID/hash persists across process restarts.
- Android/iOS deep links, recovery-password screen, cash-only private checkout.
- Callback `coffeeshop://auth-callback` saved after explicit user approval.

## Validation

- 121 Flutter tests passed, including backend codec and session/retry tests.
- Flutter static analysis: no issues found.
- Android profile APK built successfully after disabling Kotlin incremental
  caches for the Windows C:/D: plugin-cache layout. APK:
  `build/app/outputs/flutter-apk/app-profile.apk` (120.8 MB).
- 21 PostgreSQL checks passed in disposable PGlite: correct totals, tampered
  prices, invalid quantities, missing delivery address, duplicate requests,
  customer isolation, forbidden direct writes, cancellation and anonymous access.
- The app's public key
  reaches hosted Auth, and anonymous REST reads are denied for all three tables.
- Hosted authenticated-role tests passed as described above; these do not replace
  real email, phone and app relaunch verification.

Reproduce from the repository root:

```powershell
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
dart run tool/generate_catalog_seed.dart
npm install --prefix .backend-test --no-audit --no-fund @electric-sql/pglite@0.3.14
node tool/test_backend.mjs
```

## Next steps, in order

1. Reconnect the phone: ADB currently shows no device. Install the connected APK.
2. Register with the project's team email and privately entered password; verify
   confirmation, relaunch persistence, checkout, cancellation, recovery and PDF.
3. Public email delivery is intentionally deferred: the user chose private testing.
   Keep email confirmation enabled; do not activate billing or subscriptions.
4. Owners manage test orders in Supabase Table Editor (BACKEND_SETUP.md). Dedicated
   staff UI, background push, real store details, payments and production release
   preparation remain future work.

Preserve the current README/gallery/repository presentation. The earlier staging
copy has older documentation; do not copy its entire docs directory over the repo.
