# Motion and high-refresh UI

Implemented on 22 September 2026.

- Catalog and cart controls use 32dp rounded visual surfaces and 18dp icons inside 48dp accessible tap targets. Press feedback is brief; quick add confirms with a temporary checkmark without blocking repeated additions.
- Main tabs use a 220ms fade/short slide while retaining their widget state and scroll position. Hidden-tab tickers are disabled. Page transitions on Android/Windows/Linux use a subtle fade/slide; Cupertino platforms retain their native transitions.
- Quantities, detail prices and favorites animate over 160ms. Motion respects `MediaQuery.disableAnimations`; animations stop when settled, with no continuous idle ticker.
- Catalog/cart/detail photos are decoded at appropriate display sizes to reduce decoded-image memory and upload work. The original artwork is unchanged.
- Android requests the highest supported refresh rate up to 120 Hz at the current resolution on resume/focus. A tolerance handles rates reported as 120.00001 Hz. It uses `preferredRefreshRate`, leaving Android in control of battery, thermal and user display constraints. No global device setting is modified.
- Flutter animations are driven by vsync and elapsed time, without 60 Hz timer loops. This enables high-refresh rendering; it does not promise that every frame on every device takes less than 8.33ms.
- iOS already has `CADisableMinimumFrameDurationOnPhone` enabled. Native iOS performance is not verified on this Windows host.

Validation includes compact touch-target/rapid-tap tests, 120Hz-spaced test frames, tab-state retention, reduced-motion behavior, timer disposal, the existing UI regression suite, rendered screenshots, and an Android profile build.

References: [Android refresh-rate preference](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#preferredRefreshRate), [Flutter vsync animations](https://api.flutter.dev/flutter/animation/AnimationController-class.html).
