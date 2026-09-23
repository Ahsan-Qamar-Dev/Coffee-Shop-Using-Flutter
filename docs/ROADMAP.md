# Roadmap

## Implemented: UI and demo shopping flows

- Eleven-drink catalog with bundled photos and descriptions
- Search, categories, sizes, favorites and cart actions
- Pickup/delivery checkout with validated addresses
- Demo order history, receipts, cancellation and reorder
- Native Android PDF saving and multi-page receipts
- Profile/settings, shared navigation, dark/light themes and accessible motion
- Automated logic, widget and responsive-layout checks

The UI has been tested on Android hardware. Connected backend verification on a phone is pending; the app does not process real payments or dispatch orders.

## Connected: private Supabase backend

Supabase with PostgreSQL is connected by default. The original demo remains available with `--dart-define=DEMO_MODE=true`. See [setup and current limits](BACKEND_SETUP.md).

- [x] Real authentication and session restoration
- [x] Private customer profiles, addresses, carts and favorites
- [x] Managed catalog with availability
- [x] Order creation with server-calculated prices and retry protection
- [x] Customer order history and foreground status updates
- [x] Database access policies and hosted isolation tests
- [x] Mobile recovery callback configuration
- [ ] Public email delivery and real-device confirmation/recovery verification

The initial connected checkout is planned for payment on collection/delivery. Online card payments remain a separate integration.

## Before production

- [ ] Staff workflow for accepting, preparing and completing orders
- [ ] Real store details, prices, delivery rules and operating hours
- [ ] Network failure, recovery and account lifecycle checks
- [ ] iOS device testing and platform-specific export validation
- [ ] Release signing, privacy documentation and distribution setup

Free hosting has quotas and operational limits. No paid subscription is part of the planned initial backend setup.
