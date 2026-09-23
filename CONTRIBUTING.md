# Contributing

Thanks for helping improve Coffee Shop. The current version is a demo app; see the [roadmap](docs/ROADMAP.md) before proposing backend or payment changes.

## Development

1. Fork and clone the repository.
2. Use a Flutter SDK that satisfies the Dart constraint in `pubspec.yaml`.
3. Run `flutter pub get` and `flutter run`.
4. Use **Try demo account** to explore the app without external services.
5. Create a branch for a focused change.

## Before opening a pull request

```sh
dart format lib test
flutter analyze
flutter test
```

- Explain the problem and the behavior after your change.
- Include screenshots for visible UI changes, ideally in both themes.
- Check narrow layouts and larger text when changing screen structure.
- Add regression coverage for meaningful logic or navigation fixes.
- Only update golden images after reviewing the visual difference.
- Keep credentials, personal data, generated builds and machine-specific paths out of commits.
- Preserve demo behavior until a backend migration explicitly replaces it.

## Bug reports

Include reproduction steps, expected/actual behavior, device and OS, `flutter --version`, and a screenshot or sanitized log when relevant. Do not include real passwords, private tokens or customer information.

## Feature proposals

Describe the user problem, proposed behavior and affected screens. For large changes, open an issue before implementation so scope and architecture can be discussed.
