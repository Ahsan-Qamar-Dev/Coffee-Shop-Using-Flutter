# Supabase backend

This build is for private testing. Orders are stored, but coffee is not dispatched
and no online payment is collected. No paid subscription was enabled.

## Run

```sh
flutter pub get
flutter run
# Offline portfolio demo:
flutter run --dart-define=DEMO_MODE=true
```

For your own Supabase project, run migrations in filename order on a new database.
The initial migration is one-time; the seed preserves existing merchant edits.
Configure the exact auth redirect `coffeeshop://auth-callback`, keep email
confirmation enabled, and supply your project's public client configuration:

```sh
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Never embed service-role keys or database passwords. Customer state and orders
are isolated using RLS. Clients cannot directly write orders or modify prices;
ordering and cancellation use restricted PostgreSQL functions.

## Private accounts and email

Supabase's default sender only delivers to project team addresses. Register with
the project owner's team email for private verification; enter the password in
the app, not in a chat. Public registration requires custom SMTP. This project
does not disable verification to bypass that requirement. See the official
[SMTP documentation](https://supabase.com/docs/guides/auth/auth-smtp).

Mobile callbacks are configured for Android and iOS. Web/desktop callback flows
still require platform-specific configuration and testing.

## Owner test-order workflow

Use **Table Editor → orders** in Supabase as project owner. Review the payload
and change `status` from `confirmed` to `preparing`, then `ready`, then `completed`.
Use `cancelled` for an owner cancellation. Customers may cancel only confirmed
orders. The foreground app refreshes status every 30 seconds and when resumed.
Do not share project owner access with customers or put admin keys in the app.

Edit `coffees.price_cents`, `available`, or `sort_order` to manage the menu.
Prices are integer USD cents. Medium adds 50 cents and large adds 100 cents;
delivery is 150 cents. These are test rules. Photos use bundled asset paths.
Sign in again to refresh the catalog after merchant edits.

## Checks and limits

```sh
flutter analyze
flutter test
dart run tool/verify_backend_connection.dart
npm install --prefix .backend-test --no-audit --no-fund @electric-sql/pglite@0.3.14
node tool/test_backend.mjs
```

Writes are debounced; a failed save shows a retry banner. Do not close the app
while a sync error is displayed. State uses last-write wins across devices;
offline editing and conflict merging are not supported. History is limited to
200 recent orders. Background push, public email delivery, a dedicated staff app
and online payments remain separate production work.
