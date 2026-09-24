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

## Staff and owner dashboard

Open **Store orders** from the drawer after signing in with an assigned staff or
owner account. Staff see the latest 200 orders, active/completed summaries,
customer delivery details and order notes. Move orders from confirmed to
preparing, ready and completed, or cancel active orders. Every change is checked
by the database. Customers may cancel only confirmed orders. Foreground screens
refresh every 30 seconds and on resume; background push is not configured.

Owners also get **Owner tools** (gear icon): edit existing coffee names,
descriptions, prices and availability, and add/remove staff by their confirmed
account email. Staff cannot edit the menu, manage the team, grant themselves
access or change owner roles. Completed order value is not verified payment
revenue. No account has been assigned owner access yet.

For personal exploration, run offline demo mode, complete a customer order and
open **Demo store dashboard** in the drawer. Owner menu/team changes are a local
simulation that resets when the dashboard is reopened; they do not change the
demo customer catalog or any live accounts.

### Assign the first owner later

Register and confirm the intended owner's account first. The project administrator
can run this in Supabase SQL Editor, replacing the example email with that exact
confirmed account. Never put this SQL or administrative credentials in the app:

```sql
insert into public.store_staff(user_id, role)
select id, 'owner' from auth.users
where lower(email) = lower('OWNER_EMAIL_HERE')
  and email_confirmed_at is not null
on conflict (user_id) do update set role = 'owner';
```

Verify exactly one intended account was assigned, then sign out/in to reveal the
drawer entry. Subsequent staff access is managed through Owner tools. Ownership
transfer stays an administrator operation. Do not share Supabase dashboard access
with ordinary shop staff.

Edit `coffees.price_cents`, `available`, or `sort_order` to manage the menu.
Prices are integer USD cents. Medium adds 50 cents and large adds 100 cents;
delivery is 150 cents. These are test rules. Photos use bundled asset paths.
Use **Refresh menu** on the customer home screen after merchant edits; cart and
favorites use the current available products and prices. Existing receipts retain
their original snapshots. Adding products/photos and changing delivery/size rules
still require project configuration.

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
200 recent orders. Background push, public email delivery, a separate staff web
deployment and production distribution remain separate work. Online payments are
intentionally excluded. See [resale readiness](RESALE_READINESS.md).
