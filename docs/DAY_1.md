# Initial UI milestone — historical notes

This document records the first UI refactor. For current setup and status, use the [main README](../README.md) and [roadmap](ROADMAP.md).

## Initial changes

- Replaced Provider with GetX controllers and explicit dependency registration.
- Grouped application code by feature, separating authentication presentation, domain contracts and demo data.
- Added responsive sign-in, registration and recovery preview screens.
- Added input validation, loading states, password visibility and duplicate-submit protection.
- Bundled Poppins and Roboto fonts with their license files.
- Connected demo login, profile identity, cart/favorites cleanup and shared feedback.

The initial checkpoint passed 42 checks. Later milestones expanded the catalog, connected the shopping flows, added animations and introduced PDF receipts. See the documentation index for those updates.
