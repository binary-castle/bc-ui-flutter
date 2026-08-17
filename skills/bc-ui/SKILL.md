---
name: bc-ui
description: >-
  Build Flutter UI with the bc_ui design system — BCButton, BCTextField, BCCard,
  BCAppHeader, BCSelect, BCToast, BCTheme and the context.bcTheme design tokens.
  Use whenever the project's pubspec.yaml depends on bc_ui, or a file imports
  package:bc_ui/bc_ui.dart, and you are writing, editing, styling or reviewing a
  screen or widget — including when the request sounds generic ("add a login
  screen", "make this a card", "style this button"), because in a bc_ui project
  the right answer is a BC component reading theme tokens, not a Material widget
  with a hard-coded colour. Also use for wiring the theme, setting a custom
  accent, or looking up a component's props, variants, sizes or enums. Not for
  Flutter projects that do not depend on bc_ui.
---

# bc_ui

A Flutter design system: ~67 components on a Material 3 base, every colour,
radius and duration coming from one token set. This skill routes you to exact,
generated signatures — it does not restate them, because guessing a prop name
is the failure mode it exists to prevent.

## 1. Check the project first

Read the consumer's `pubspec.lock` (it names the resolved version) or
`pubspec.yaml`. If `bc_ui` isn't a dependency, this skill doesn't apply — say
so and stop.

Compare the resolved version against the one stamped at the top of every file
in `references/`. If they differ, the installed package wins: its own
`doc/api.md` ships inside the pub archive, at the `bc_ui` `rootUri` recorded in
`.dart_tool/package_config.json`. Read that for props and enums, keep using
this skill for conventions and traps, and mention the mismatch once. A `path:`
or `git:` dependency means the same thing — read its `lib/src` directly.

## 2. Setup

One import, `import 'package:bc_ui/bc_ui.dart';`, and one wiring block:

```dart
MaterialApp(
  theme: BCTheme.light(),
  darkTheme: BCTheme.dark(),
  themeMode: ThemeMode.system,
  builder: (context, child) => BCToastProvider(child: child!), // only for BCToast
  home: const HomeScreen(),
);
```

Check whether the app is already wired before adding it. `BCToastProvider` is
the only provider in the library, and only `BCToast` needs it. A custom accent
goes through `BCTheme.light(overrides: BCThemeOverrides(accent: ...))`, which
recomputes the derived hover/soft/focus tokens for you — never set them by
hand. Details in `references/setup.md`.

## 3. Conventions — these let you guess right

The library is deliberately uniform, so a handful of rules cover 67 components:

- **`variant` picks the look, `size` picks the metrics.** Both are enums named
  after the component: `BCButtonVariant`, `BCButtonSize`, `BCChipColor`.
- **State is controlled.** Widgets take a value plus a change callback —
  `value` + `onValueChange`, `isSelected` + `onSelectedChange` — and never hold
  their own state unless you hand them a controller.
- **Disabled is `isDisabled`, invalid is `isInvalid`.** Never `enabled: false`.
- **`defaultVariant` and `defaultColor`** stand in for heroui's `default`,
  which is a reserved word in Dart.
- **Compound components are composed, not configured.** `BCCard`,
  `BCTextField`, `BCInputOTP`, `BCDialog` and `BCMenu` take named part widgets
  as children (`BCCardHeader`, `BCTextFieldLabel`, …) rather than title/subtitle
  props.
- **The three pickers share one `presentation`** — `dialog`, `popover` or
  `bottomSheet` — so swapping one for another never changes how it opens.
- **Corners are continuous.** Radii come from `BCRadius`, drawn with
  `BCShapes.continuous(...)`. Not `BorderRadius.circular`.

## 4. Find the component, then read its file

Pick the row that covers what you're building and read **that one file** before
writing the widget. Each is a few hundred lines with every prop, default and
enum value; that is cheap, and it is the difference between working code and a
plausible-looking constructor that doesn't compile. Do not write bc_ui props
from memory, and if a component isn't listed here it isn't part of bc_ui.

<!-- BEGIN GENERATED: catalog -->

Generated from bc_ui 0.5.0-beta.1.

| Read this file | For these components |
|---|---|
| `references/setup.md` | `BCTheme`, `BCThemeOverrides`, `BCToastProvider` |
| `references/tokens.md` | `context.bcTheme` colours, `BCSpacing`, `BCRadius`, `BCShapes`, `BCTypography`, `BCSizes`, `BCMotion`, `BCDuration`, `BCBreakpoints` |
| `references/navigation.md` | `BCAppHeader`, `BCSliverAppHeader`, `BCHeaderIconButton`, `BCBottomNav`, `BCNavRail`, `BCNavDrawer`, `BCToolbar`, `BCTabs`, `BCTabView` |
| `references/actions.md` | `BCButton`, `BCSocialAuthButton`, `BCBrandLogo`, `BCLinkButton`, `BCCloseButton`, `BCFab`, `BCSpeedDial`, `BCToggleButton`, `BCToggleButtonGroup`, `BCPressable` |
| `references/containers.md` | `BCSurface`, `BCCard`, `BCListGroup`, `BCAccordion`, `BCFlipCard`, `BCScrollShadow` |
| `references/data-display.md` | `BCText`, `BCAvatar`, `BCChip`, `BCRibbon`, `BCTagGroup`, `BCSeparator`, `BCSkeleton`, `BCSpinner`, `BCProgress`, `BCLoadingOverlay`, `BCRating`, `BCEmptyState` |
| `references/forms.md` | `BCInput`, `BCTextField`, `BCTextArea`, `BCPasswordInput`, `BCSearchField`, `BCInputOTP`, `BCPhoneField`, `BCSelect`, `BCControlField` |
| `references/pickers.md` | `BCDateField`, `BCTimeField`, `BCDateTimePicker`, `BCDateTimeWheel`, `BCCalendar`, `BCTimeWheel` |
| `references/selection.md` | `BCCheckbox`, `BCRadioGroup`, `BCSwitch`, `BCSlider`, `BCRangeSlider` |
| `references/overlays.md` | `BCDialog`, `BCPopover`, `BCMenu`, `BCToast` |
| `references/ai-chat.md` | `BCAIChat`, `BCChatThread`, `BCChatComposer`, `BCChatMarkdown`, `BCAgentStepList`, `BCVoiceOverlay` |
| `references/gotchas.md` | Silent failures, asserts, internal-only names |

<!-- END GENERATED -->

## 5. Tokens, never literals

```dart
final bc = context.bcTheme;

DecoratedBox(
  decoration: ShapeDecoration(
    color: bc.accentSoft,
    shape: BCShapes.continuous(BCRadius.xxl),
    shadows: bc.surfaceShadow.shadows,
  ),
);
```

Colours come from `context.bcTheme`, spacing from `BCSpacing`, radii from
`BCRadius`, durations from `BCDuration`, type from `BCText` or `BCTypography`.
A literal `Color(0xFF...)`, a bare `EdgeInsets.all(15)` or a hand-picked
`Duration` is a bug: it won't follow the theme into dark mode and it won't move
when the accent changes. Every token name is listed in `references/tokens.md` —
if it isn't there, it doesn't exist, so compose from what does.

Prefer bc_ui over the Material equivalent when one exists — `BCButton` over
`ElevatedButton`, `BCTextField` over `TextField`, `BCAppHeader` over `AppBar`,
`BCCard` over `Card`. Material widgets still work (bc_ui returns a real
`ThemeData`) and are the right call for anything the library doesn't cover:
`Scaffold`, `Navigator`, layout widgets, `ListView`.

## 6. Traps

These compile and run, so nothing will tell you they're wrong:

- **`context.bcTheme` ends in a null assertion.** Any BC widget outside a
  `MaterialApp` built with `BCTheme.light()`/`.dark()` throws — including in
  widget tests, which must pump `MaterialApp(theme: BCTheme.light(), ...)`.
- **`BCTextFieldError` renders nothing** unless its parent `BCTextField` also
  has `isInvalid: true`. Set both.
- **Compound parts degrade silently outside their parent.** A `BCRadio` outside
  a `BCRadioGroup` just ignores taps; a `BCTextFieldLabel` on its own loses its
  required/invalid state. No error either way.
- **`BCToast.show` without a `BCToastProvider`** asserts in debug and is a
  silent no-op in release.

The full list, plus every constructor assert extracted from the source, is in
`references/gotchas.md`. Read it when a widget renders but looks wrong.

If you are ever unsure whether a prop exists, the analyzer settles it —
`flutter analyze` on the file you just wrote.
