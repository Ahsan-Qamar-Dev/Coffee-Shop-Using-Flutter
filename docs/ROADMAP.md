# Roadmap

## Implemented: UI and demo shopping flows

- Eleven-drink catalog with bundled photos and descriptions
- Search, categories, sizes, favorites and cart actions
- Pickup/delivery checkout with validated addresses
- Demo order history, receipts, cancellation and reorder
- Native Android PDF saving and multi-page receipts
- Profile/settings, shared navigation, dark/light themes and accessible motion
- Automated logic, widget and responsive-layout checks

Android has been tested on a physical device. The app currently stores account and shopping state in memory; it does not process real payments or dispatch orders.

## Next: free backend integration

Supabase with PostgreSQL is the selected direction. Integration is not yet part of the runnable app on `main`.

- [ ] Real authentication and session restoration
- [ ] Private customer profiles, addresses, carts and favorites
- [ ] Managed catalog with availability
- [ ] Order creation with server-calculated prices and retry protection
- [ ] Customer order history and status updates
- [ ] Database access policies and isolation tests
- [ ] Authentication email delivery and recovery configuration

The initial connected checkout is planned for payment on collection/delivery. Online card payments remain a separate integration.

## Before production

- [ ] Staff workflow for accepting, preparing and completing orders
- [ ] Real store details, prices, delivery rules and operating hours
- [ ] Network failure, recovery and account lifecycle checks
- [ ] iOS device testing and platform-specific export validation
- [ ] Release signing, privacy documentation and distribution setup

Free hosting has quotas and operational limits. No paid subscription is part of the planned initial backend setup.
