# bc_ui

A Flutter design system with a cohesive theme, design tokens, and ready-to-use UI components built on Material 3.

## Features

- **Theme system** — Light and dark `ThemeData` via `BCTheme`, with optional color overrides for `primary`, `secondary`, and `error`
- **Typography** — Inter font via [google_fonts](https://pub.dev/packages/google_fonts), wired into Material `TextTheme`
- **UI components** — Buttons, cards, text fields, badges, avatars, separators, loading indicators, and skeleton placeholders
- **Context helpers** — `BCContext` extension for quick access to `theme`, `colors`, and `text`
- **Example app** — Interactive showcase for every component under `example/`

## Getting started

Add `bc_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  bc_ui: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Requirements

- Dart SDK `^3.12.1`
- Flutter `>=1.17.0`

## Usage

### Apply the theme

Build the theme inside a root widget's `build()` method (or call `WidgetsFlutterBinding.ensureInitialized()` first). `BCTheme` uses Google Fonts and requires the Flutter binding to be initialized.

```dart
import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: BCTheme.light(
        overrides: const BCThemeOverrides(
          primary: Color(0xFF0F766E),
          secondary: Color(0xFF7C3AED),
        ),
      ),
      darkTheme: BCTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
```

### Buttons

```dart
BCButton.primary(
  text: 'Continue',
  onPressed: () {},
  fullWidth: true,
)

BCButton.outline(
  text: 'Cancel',
  onPressed: () {},
  size: BCButtonSize.small,
)

BCButton.destructive(
  text: 'Delete',
  onPressed: () {},
  loading: true,
)
```

Variants: `primary`, `secondary`, `outline`, `text`, `destructive`  
Sizes: `small`, `medium`, `large`

### Cards

```dart
BCCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BCCardHeader(child: Text('Title')),
      BCCardBody(child: Text('Card content goes here.')),
      BCCardFooter(
        child: BCButton.primary(text: 'Action', onPressed: () {}),
      ),
    ],
  ),
)
```

### Text fields

`BCTextField` uses a compound API — compose labels, inputs, descriptions, and errors as children.

```dart
BCTextField(
  isRequired: true,
  isInvalid: hasError,
  children: [
    BCTextFieldLabel('Email'),
    BCTextFieldInput(
      hintText: 'you@example.com',
      variant: BCTextFieldVariant.primary,
    ),
    if (hasError)
      BCTextFieldError('Please enter a valid email address'),
  ],
)
```

### Other components

```dart
// Badge
BCBadge(label: 'New', variant: BCBadgeVariant.primary)

// Avatar
BCAvatar.withInitials('JD', size: BCAvatarSize.large)

// Separator
const BCSeparator(margin: EdgeInsets.symmetric(vertical: 16))

// Loading
const BCLoading(isLoading: true)

// Skeleton placeholder
BCSkeleton(
  isLoading: isLoading,
  width: 200,
  height: 20,
  child: Text(title),
)
```

### Context extension

```dart
Widget build(BuildContext context) {
  final colors = context.colors;
  final textTheme = context.text;

  return Text('Hello', style: textTheme.titleLarge);
}
```

## Components

| Component | Description |
|-----------|-------------|
| `BCButton` | Primary, secondary, outline, text, and destructive variants with sizes and loading state |
| `BCCard` | Surface container with header, body, and footer slots |
| `BCTextField` | Compound input with label, description, error, and variant support |
| `BCBadge` | Labels and chips with size, variant, and color options |
| `BCAvatar` | Image, initials, or icon with fallback and status handling |
| `BCSeparator` | Horizontal or vertical dividers with thickness variants |
| `BCLoading` | Spinner with size and color options |
| `BCSkeleton` | Shimmer and pulse loading placeholders |

## Example

Run the included showcase app to preview all components:

```bash
cd example
flutter run
```

## Additional information

This package is in early development (`0.0.1`). APIs may change between releases.

For issues, feature requests, or contributions, use the repository issue tracker.
