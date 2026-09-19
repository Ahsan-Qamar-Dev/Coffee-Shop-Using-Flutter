# UI phase and backend handoff

## Completed UI

The app retains its coffee photography, orange accent and dark/light options, with consistent cards, typography, touch targets and responsive forms.

| Area | Behavior |
| --- | --- |
| Navigation | One scaffold owns the drawer for all four tabs. Profile, orders and help are reachable from the drawer. Tab selection and catalog scroll/filter state are retained. Back from a non-home tab returns Home. |
| Catalog | Search and category filters combine. Empty searches offer Clear filters. Quick add uses the small size whose price is displayed. Detail, cart and receipts share integer-cent pricing. |
| Details | Correct milk/black-coffee labels, size/price selection, live favorite state and a direct cart shortcut. Removed the invented review count. |
| Cart | Quantity controls, direct removal, accurate totals, checkout and an actionable empty state. |
| Checkout | Pickup or delivery, saved address form, payment preference, optional note, itemized total, duplicate-submit guard, failure feedback and cart preservation on failure. |
| Orders | Immutable receipt snapshots, history, cancellation, reordering and a true Continue shopping action. Confirmation clears the cart once. |
| Notifications | Created from preview orders; read/unread badges, mark all read, clear confirmation and links to the correct receipt. No fabricated promotions or orders. |
| Account | Name/phone editor, delivery address create/edit/delete, payment choices and password validation. Live name updates replace hard-coded customer identity. |
| Settings | Shared theme and in-app order-alert preference. Sign-out clears session shopping data. Theme remains an app preference. |
| Help | Reachable FAQs, preview explanation, allergen caveat and about information. |

## Integration boundaries

- `AuthRepository` -> `DemoAuthRepository`: sign-in, preview entry, signup, password recovery, profile name, password change and sign-out.
- `OrderRepository` -> `DemoOrderRepository`: place and cancel. `OrderController` owns UI loading/error state and session history.
- `Coffee.priceCentsFor(size)` is the single preview size-pricing rule. The backend must validate authoritative prices, stock, discounts, taxes, fees and allowed quantities.
- `OrderDraft` snapshots line items, fulfillment, customer name, payment choice, notes and address. `CoffeeOrder` stores the receipt snapshot independently of the mutable cart.
- `ProfileController`, `CartController`, `FavoriteController`, `NotificationController` currently keep data in memory. Add per-user repositories and persistence next.
- `ShopNavigation` owns the selected tab. `HomePage` is the only scaffold for embedded main-tab content.

## Intentional preview behavior

No real payment, store dispatch, push notification or reset email is performed. Card entry is represented by a clearly labeled demo choice, without collecting card credentials. A sample delivery fee of USD 1.50 is used; pickup has no fee. Store address, pickup scheduling, live order progression and service availability require backend/shop configuration.

Accounts and settings are not durable across process restarts. Signing out clears the cart, favorites, profile preferences/address, notifications and order history; preview accounts remain in memory until restart. The demo-entry button works even after changing the demo account's preview password.

## Backend phase

1. Implement production authentication, durable sessions, email recovery and secure profile updates. Disable demo entry for production.
2. Supply the live catalog, authoritative pricing, stock and fulfillment configuration.
3. Persist cart, favorites, addresses, notification preferences and order history per user.
4. Integrate a payment provider using its secure SDK; add wallet availability and payment failure/retry behavior backed by real provider responses.
5. Connect order creation/cancellation, staff processing, status progression, notifications and realtime updates.
6. Complete release identity/signing, production app icons, store configuration and native-device acceptance checks.

## Verification scope

Automated interaction regressions cover the main routes and actions. Fourteen screen layouts are exercised on a narrow phone at doubled text, landscape at doubled text and a tablet. Authentication has its existing layout/keyboard matrix. Phone previews are rendered in both themes for visual review. Native iOS/macOS builds require a Mac; Windows-based verification cannot certify those targets.

Validated on 20 September 2026: all 94 default tests passed; static analysis reported no issues; 16 phone previews rendered across dark/light themes; Android debug APK built successfully. No live backend services were used.
