<div align="center">

# Coffee Shop · Flutter

**A complete coffee-ordering UI, from the first browse to the final receipt.**

Flutter · Dart · GetX · Android & iOS project structure

[Screenshots](#screenshots) · [Features](#features) · [Get started](#get-started) · [Roadmap](docs/ROADMAP.md)

</div>

Coffee Shop is a Flutter portfolio project with an 11-drink menu, warm café styling, dark and light themes, and connected shopping flows. Browse coffees, customize a cup, manage a cart, place a demo order, and export its receipt as a PDF.

> **Project status:** Supabase authentication, saved shopping data, the database catalog and server-priced orders are connected for **private testing**. Public email delivery and on-device backend verification remain pending. No real payment is collected or coffee dispatched. An explicit offline demo mode is also available.

## Screenshots

Actual app screens captured by Flutter widget previews.

<table>
  <tr>
    <th>Discover your coffee</th>
    <th>Iced favorites</th>
    <th>Product details · light</th>
  </tr>
  <tr>
    <td><img src="docs/images/home-dark.png" alt="Dark theme coffee catalog with search and category filters" width="250"></td>
    <td><img src="docs/images/iced-dark.png" alt="Iced Latte and Cold Brew category" width="250"></td>
    <td><img src="docs/images/detail-light.png" alt="White Chocolate Mocha product details in light mode" width="250"></td>
  </tr>
  <tr>
    <th>Your cart</th>
    <th>Checkout</th>
    <th>Order receipt</th>
  </tr>
  <tr>
    <td><img src="docs/images/cart-dark.png" alt="Shopping cart with size, quantity and price controls" width="250"></td>
    <td><img src="docs/images/checkout-light.png" alt="Checkout with pickup and delivery options" width="250"></td>
    <td><img src="docs/images/receipt-light.png" alt="Order confirmation and receipt" width="250"></td>
  </tr>
</table>

## Features

| Area | Included |
| --- | --- |
| Menu | 11 coffees, individual photography and descriptions, combined search and category filters, iced and milk labels |
| Product details | Small/medium/large sizing, updated prices, favorites and add to cart |
| Cart | Quantity controls, removal with undo, totals and empty states |
| Checkout | Pickup/delivery selection, address validation, payment preference and order notes |
| Orders | Saved order history, itemized receipts, cancellation, status refresh and reorder |
| Staff & owner | Role-protected order dashboard, fulfilment actions, menu prices/availability and staff management |
| PDF export | Styled receipts, multi-page item tables and Android's native Save PDF picker |
| Account | Supabase sign-in/registration, session restoration, saved profile/address/cart/favorites |
| Navigation | Shared drawer, home/favorites/cart/alerts tabs and contextual cart actions |
| Appearance | Dark/light themes, responsive layouts, larger-text support and smooth transitions |
| Motion | Compact animated controls, reduced-motion support and an Android refresh-rate preference up to 120 Hz on supported devices |

The menu includes Cappuccino, Latte, Espresso, Americano, Mocha, Flat White, Caramel Latte, Iced Latte, Cold Brew, White Chocolate Mocha and Cortado. Menu ratings and prices are demo data.

## Get started

### Requirements

- Flutter with Dart **3.13.1 or newer, below 4.0.0**, as required by `pubspec.yaml`.
- An Android device/emulator and Android SDK, or macOS with Xcode for iOS development.
- The latest recorded development build used **Flutter 3.47.4 / Dart 3.13.3**.

```sh
git clone https://github.com/Ahsan-Qamar-Dev/Coffee-Shop-Using-Flutter.git
cd Coffee-Shop-Using-Flutter
flutter pub get
flutter run
```

Normal startup connects to Supabase. The bundled key is publishable; database RLS protects customer data. Never place a service-role key in Flutter. See [backend setup](docs/BACKEND_SETUP.md). On Windows, enable Developer Mode if Flutter reports that desktop plugin symlinks are unavailable.

### Try the demo

```sh
flutter run --dart-define=DEMO_MODE=true
```

Choose **Try demo account** on the login screen, or use:

| Field | Demo value |
| --- | --- |
| Email | `demo@coffee.test` |
| Password | `Coffee123!` |

These credentials and session-only behavior apply to **offline demo mode**. Connected private testing uses real Supabase accounts and saved shopping data. Use test customer details and the project's authorized team email until custom email delivery is configured.

For the shop side, place an offline demo order, then open **Demo store dashboard** in the drawer. Use the gear icon for Owner tools. Live access requires an assigned, confirmed owner/staff account; no owner is preassigned. See [free services and buyer handoff](docs/RESALE_READINESS.md).

**Suggested walkthrough:** browse the Iced category → open a drink → select a size → add it to the cart → complete demo checkout → save the receipt PDF → view the order from Alerts.

## Architecture

The app groups code by feature. GetX controllers hold UI state; repository interfaces separate authentication and ordering from Supabase and offline demo implementations.

```text
lib/
├── app/                 # App bindings, shared navigation and drawer
├── core/                # Theme, motion, feedback and reusable widgets
└── features/
    ├── auth/            # Demo authentication and account flows
    ├── catalog/         # Coffee data, filtering and product screens
    ├── cart/            # Cart state and quantity controls
    ├── checkout/        # Address, payment preference and confirmation
    ├── favorites/       # Saved coffees for the current session
    ├── notifications/   # In-app order notifications
    ├── orders/          # Orders, PDF generation and export
    └── profile/         # Account details, settings and help
```

**Stack:** Flutter and Dart for UI, GetX for state management, `pdf` for receipt generation, `printing` for supported export flows, and Kotlin for Android document saving and refresh-rate preferences. Fonts and coffee images are bundled for offline display.

## Quality checks

The connected backend checkpoint passed **125 automated tests**, local SQL tests and hosted pricing/isolation checks. The earlier UI checkpoint includes **20 light/dark preview captures** and physical Android receipt verification. Backend login and recovery still need phone verification. These are recorded checks, not a live CI badge.

```sh
flutter analyze
flutter test
flutter build apk --profile
```

Tests cover navigation, authentication previews, catalog filtering, pricing, checkout, orders, profile changes, motion and receipt export. Responsive checks include narrow phones, landscape layouts, tablets and larger text.

To intentionally regenerate the visual previews after a UI change:

```sh
flutter test --dart-define=CAPTURE_UI=true --update-goldens test/ui_preview_test.dart
```

Platform folders are present for Android, iOS, web and desktop. **Android is the device-tested target; iOS, web and desktop still need platform-specific validation.** A 120 Hz preference does not guarantee every frame renders at 120 FPS.

## What's next

- [x] Supabase authentication and persistent customer data
- [x] PostgreSQL catalog and server-validated order pricing
- [x] Persistent carts, favorites and order history
- [x] Foreground status refresh and role-protected staff/owner dashboard
- [ ] Public email delivery and on-device backend validation
- [x] Owner menu editing, availability and staff access management
- [ ] Background push notifications and buyer-specific store configuration
- [ ] iOS and wider platform validation
- [ ] Production release preparation (online payments intentionally excluded)

See the [roadmap](docs/ROADMAP.md) for current boundaries and the [documentation index](docs/README.md) for implementation notes.

## Contributing

Bug reports and focused improvements are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) for setup, checks and what to include in a pull request. Use the repository's issue templates to report a reproducible bug or suggest a feature.

## Author

Built by **[Ahsan Qamar](https://github.com/Ahsan-Qamar-Dev)** as a Flutter mobile development portfolio project.

Coffee image provenance is documented in [MENU_CATALOG.md](docs/MENU_CATALOG.md). Bundled fonts retain their license files in `assets/fonts/`.
