# Free development and future handoff

Checked 24 September 2026. No paid plan, subscription, card billing, SMTP account
or push service was activated during this work. The app remains a private test
project, with payment on collection/delivery only.

## Services

| Service | Current use | Free option and boundary |
| --- | --- | --- |
| Supabase PostgreSQL + Auth | Connected; customer data, catalog, orders and role-checked staff/owner functions | Free plan includes a 500 MB database; quotas and free-project operational limits apply. Review [pricing](https://supabase.com/pricing) before a commercial launch. |
| PostgreSQL | Database engine inside Supabase | Open-source software does not include free unlimited hosting or operations. |
| Brevo transactional email | Candidate only; not connected | [Free plan](https://help.brevo.com/hc/en-us/articles/208580669-FAQs-What-are-the-limits-of-the-Free-plan) currently offers 300 emails/day, without rollover. Sender verification/approval and applicable branding restrictions still apply. A sending domain may have its own cost. |
| Firebase Cloud Messaging | Optional candidate; not connected | [Cloud Messaging is no-cost](https://firebase.google.com/pricing). Requires app configuration, notification permission and a trusted sender; it does not make unrelated Firebase products free. |
| Bundled images and local PDF export | Implemented | No image hosting, maps, SMS, receipt API or payment subscription is required for current flows. |

Supabase's [default SMTP](https://supabase.com/docs/guides/auth/auth-smtp) restricts
mail to project team addresses. Keep email verification enabled. Private testing
was explicitly chosen; public sign-up needs a configured email provider.

## Available now

- Customer shopping, persisted state, server-priced cash orders and PDF receipts.
- Staff order queue, status transitions, cancellation and foreground refresh.
- Owner editing of existing menu items and availability; staff access management.
- Server-enforced roles and private customer data; no admin key in the client.
- Offline demonstration of the staff and owner screens without registering an owner.

## Before handing this to a real shop

1. Use the buyer's own Supabase project or arrange a controlled project transfer.
   Apply the four migrations in order on a fresh database and set the public app
   configuration. Keep seller test/customer data separate.
2. Register a confirmed owner and assign that account using the administrator
   procedure in [backend setup](BACKEND_SETUP.md). Owners can then manage staff.
3. Configure branding, menu/photos, currency, size pricing, delivery fee/coverage,
   operating hours, contact information and receipt business details. Current USD
   prices and delivery rules are examples; store settings are not yet an owner UI.
4. Configure verified email delivery and test confirmation and password recovery
   on devices. Add push only if the shop needs alerts while the app is closed.
5. Test customer checkout through staff fulfilment on separate real accounts and
   devices, including reconnection, app restart, role revocation and receipt saving.
   Connected phone verification and iOS testing are still outstanding.
6. Prepare release signing, store accounts/distribution, privacy and retention
   policies, backup/restore procedures, monitoring and operational support.
   App store or domain charges are outside the free development setup.
7. Review quotas and upgrade only if usage, uptime or backup requirements warrant
   it. An upgrade alone does not complete the business configuration or testing.

Remaining product extensions include an owner UI for store settings, adding new
products/photos, stock quantities, date-range reporting beyond the latest 200
orders, and a separately hosted staff web portal if requested. The current
dashboard is responsive and lives inside the Flutter app. No card payment,
delivery dispatch or fiscal/accounting system is represented as implemented.
