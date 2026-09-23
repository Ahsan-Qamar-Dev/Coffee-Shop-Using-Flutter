# Backend checkpoint — 23 September 2026

Status: tested local foundation, NOT a deployed or connected backend.
The application still starts in demo mode. No cloud migrations have been applied.
The user's requirement is a free service without subscriptions or billing setup.

## Prepared

- Supabase auth adapter (sign-in, sign-up, reset, profile name, password).
- Customer-scoped catalog/state repository and order repository.
- PostgreSQL tables and RLS policies for catalog, customer state and orders.
- Server-calculated prices, quantity validation, per-user request deduplication,
  checkout rate limit and ownership-checked cancellation.
- Eleven-product seed generated from the existing Flutter catalog. Reapplying
  the seed preserves merchant edits. Photos remain bundled in the app.
- Controller integration hooks and order snapshot decoding, including server fees.

## Validation

- 117 Flutter tests passed, including three new backend codec tests.
- Flutter static analysis: no issues found.
- 21 PostgreSQL checks passed in disposable PGlite: correct totals, tampered
  prices, invalid quantities, missing delivery address, duplicate requests,
  customer isolation, forbidden direct writes, cancellation and anonymous access.
- These are local checks, not verification of the hosted Supabase configuration.

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

1. Implement versioned customer state serialization and session synchronization:
   cart, favorites, profile/address, notifications; debounced writes, retry UI,
   account isolation and safe logout. Hooks currently have no callbacks attached.
2. Connect app startup/bindings, load the live catalog instead of sample data,
   restore auth sessions and fetch order history. Keep demo mode explicit.
3. Configure confirmation/reset links and mobile deep links. Resolve production
   email delivery on a free option; do not silently disable verification.
4. Replace preview-only messaging and hide demo-card checkout in live mode.
   Add recoverable loading/offline/error states and refresh server order status.
5. Persist pending order request IDs across process restarts. Current retry
   deduplication survives network retries in memory, but not app restarts.
6. Review and apply both migrations to project `sxduvqxceyawunjonqaj`, then verify
   hosted grants/RLS and two-account isolation. The public client key is already
   in BackendConfig; never put a service-role key or database password in Flutter.
7. Run real account, checkout, cancellation, relaunch and receipt tests on phone.
   A store/admin workflow is still needed to move orders through preparation.

Preserve the current README/gallery/repository presentation. The earlier staging
copy has older documentation; do not copy its entire docs directory over the repo.
