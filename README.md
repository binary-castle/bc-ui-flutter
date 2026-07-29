![bc_ui — HeroUI Native, ported to Flutter](https://raw.githubusercontent.com/binary-castle/bc-ui-flutter/main/doc/assets/banner.png)

<p align="center">
  <b>A Flutter design system that ports <a href="https://github.com/heroui-inc/heroui-native">heroui-native</a> 1:1</b><br>
  Same tokens, same variants, same motion — on a Material 3 base, so the rest of the Material ecosystem keeps working.
</p>

<p align="center">
  <a href="https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md"><b>API reference</b></a> ·
  <a href="#components">Components</a> ·
  <a href="#theming">Theming</a> ·
  <a href="#example-app">Example app</a>
</p>

---

## Why

- **One token system, 64 semantic color slots.** Every color is precomputed from
  heroui-native's oklch sources — including each `color-mix` derived hover/soft
  shade — into a light and a dark palette. No component hard-codes a color.
- **iOS-grade surfaces.** Continuous ("squircle") corners via
  `RoundedSuperellipseBorder`, layered surface/overlay shadows, and frosted
  headers built on real `BackdropFilter` blur.
- **The motion is ported, not approximated.** Press scale 0.985 with width
  compensation, switch thumb spring (mass 2 / stiffness 1600 / damping 120),
  tab indicator that tracks your finger, 1500ms shimmer — see `BCMotion`.
- **Material stays available.** `BCTheme.light()` returns a `ThemeData`, so
  `Scaffold`, `Navigator`, `showDialog` and every Material widget still work.
- **Inter is bundled.** No font setup, no missing-glyph surprises.
- **50+ components**, all light/dark aware, all documented in the
  [API reference](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md).

| Light | Dark |
|:---:|:---:|
| ![Light theme](https://raw.githubusercontent.com/binary-castle/bc-ui-flutter/main/doc/assets/demo-light.png) | ![Dark theme](https://raw.githubusercontent.com/binary-castle/bc-ui-flutter/main/doc/assets/demo-dark.png) |

<sub>The screen above is assembled entirely from bc_ui — header, card, buttons,
tabs, list group, chips, bottom nav. Its source is
<a href="https://github.com/binary-castle/bc-ui-flutter/blob/main/example/lib/showcase/screens/demo_app_screen.dart"><code>example/lib/showcase/screens/demo_app_screen.dart</code></a>.</sub>

## Install

```bash
flutter pub add bc_ui
```

or add it by hand:

```yaml
dependencies:
  bc_ui: ^0.0.2
```

Requires Dart SDK `^3.12.1`. No other runtime dependencies.

## Setup

```dart
import 'package:bc_ui/bc_ui.dart';

MaterialApp(
  theme: BCTheme.light(),
  darkTheme: BCTheme.dark(),
  themeMode: ThemeMode.system,
  // Only needed if you use BCToast:
  builder: (context, child) => BCToastProvider(child: child!),
  home: const HomeScreen(),
);
```

That's the whole setup — every component reads its colors from the
`BCThemeExtension` those two factories install.

## Quick start

```dart
// Buttons: 7 variants x 3 sizes
BCButton(
  variant: BCButtonVariant.secondary,
  onPressed: () {},
  startContent: const Icon(Icons.add, size: 18),
  child: const Text('Add item'),
);

// A frosted app header — pair with extendBodyBehindAppBar so there is
// something to blur. The hairline appears only once content scrolls under.
Scaffold(
  extendBodyBehindAppBar: true,
  appBar: BCAppHeader(
    title: const Text('Inbox'),
    subtitle: const Text('12 unread'),
    actions: [
      BCHeaderIconButton(icon: const Icon(Icons.search), onPressed: () {}),
    ],
  ),
  body: ListView(children: const []),
);

// Swipeable tabs: the bar and the panels share one controller, so a drag
// switches tabs and carries the indicator with it.
final tabs = BCTabsController<String>(values: const ['music', 'podcasts']);

Column(
  children: [
    BCTabs(items: items, controller: tabs, fullWidth: true),
    Expanded(
      child: BCTabView(
        controller: tabs,
        children: const [MusicPanel(), PodcastsPanel()],
      ),
    ),
  ],
);

// Compound form field with built-in validation states
BCTextField(
  isRequired: true,
  children: [
    const BCTextFieldLabel('Email'),
    const BCTextFieldInput(hintText: 'you@example.com'),
    const BCTextFieldDescription("We'll never share your email."),
  ],
);

// Toast
BCToast.show(context, const BCToastData(
  title: 'Changes saved',
  variant: BCToastVariant.success,
));
```

## Components

Full props, defaults and enums for every entry: **[API reference](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md)**.

| Category | Components |
|---|---|
| **Navigation** | [`BCAppHeader`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcappheader) · [`BCSliverAppHeader`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcsliverappheader) · [`BCHeaderIconButton`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcheadericonbutton) · [`BCBottomNav`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcbottomnav) · [`BCNavRail`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcnavrail) · [`BCNavDrawer`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcnavdrawer) · [`BCToolbar`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctoolbar) · [`BCTabs`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctabs) · [`BCTabView`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctabview) |
| **Actions** | [`BCButton`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcbutton) · [`BCSocialAuthButton`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcsocialauthbutton) · [`BCBrandLogo`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcbrandlogo) · [`BCLinkButton`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bclinkbutton) · [`BCCloseButton`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcclosebutton) · [`BCFab`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcfab) · [`BCSpeedDial`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcspeeddial) · [`BCToggleButton`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctogglebutton) · [`BCToggleButtonGroup`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctogglebuttongroup) · [`BCPressable`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcpressable) |
| **Containers** | [`BCSurface`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcsurface) · [`BCCard`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bccard) · [`BCListGroup`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bclistgroup) · [`BCFlipCard`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcflipcard) · [`BCScrollShadow`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcscrollshadow) |
| **Data display** | [`BCText`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctext) · [`BCAvatar`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcavatar) · [`BCChip`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcchip) · [`BCRibbon`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcribbon) · [`BCTagGroup`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctaggroup) · [`BCSeparator`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcseparator) · [`BCSkeleton`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcskeleton) · [`BCSpinner`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcspinner) · [`BCProgress`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcprogress) · [`BCLoadingOverlay`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcloadingoverlay) · [`BCRating`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcrating) · [`BCEmptyState`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcemptystate) |
| **Forms** | [`BCInput`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcinput) · [`BCTextField`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctextfield) · [`BCTextArea`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctextarea) · [`BCPasswordInput`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcpasswordinput) · [`BCSearchField`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcsearchfield) · [`BCInputOTP`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcinputotp) · [`BCDateField`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcdatefield) · [`BCTimeField`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctimefield) · [`BCDateTimePicker`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcdatetimepicker) · [`BCSelect`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcselect) · [`BCControlField`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bccontrolfield) |
| **Selection** | [`BCCheckbox`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bccheckbox) · [`BCRadioGroup`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcradiogroup) · [`BCSwitch`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcswitch) · [`BCSlider`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcslider) · [`BCRangeSlider`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcrangeslider) |
| **Overlays** | [`BCDialog`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcdialog) · [`BCPopover`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcpopover) · [`BCMenu`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bcmenu) · [`BCToast`](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#bctoast) |

The three pickers — `BCDateField`, `BCTimeField`, `BCDateTimePicker` — share a
`presentation` prop (`dialog`, `popover`, `bottomSheet`), so swapping one for
another never changes how it opens.

Naming is predictable across the library: `variant` picks the look, `size`
picks the metrics, state is controlled (`value` + `onValueChange`), and
disabled/invalid are always `isDisabled` / `isInvalid`.

## Theming

### Custom accent

```dart
BCTheme.light(
  overrides: BCThemeOverrides(accent: const Color(0xFF0F766E)),
);
```

Accent-derived tokens (hover, soft, soft-foreground, focus) are recomputed for
you, so a single color change stays consistent everywhere.

### Reading tokens in your own widgets

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

### Design tokens

`BCColorsLight`/`BCColorsDark` (raw palettes) · `BCRadius` (2→32, `field` 14) ·
`BCSpacing` (4px unit) · `BCTypography` (tailwind text scale) · `BCShadows`
(layered surface/overlay shadows) · `BCMotion` (springs and timings) ·
`BCShapes` (continuous corners) · `BCSizes` · `BCDuration` · `BCBreakpoints`.

See [Theme and tokens](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md#theme-and-tokens) for the full list.

## Example app

`example/` mirrors heroui-native's demo: a full demo screen plus one page per
component, each with vertically paged usage variants and a pagination rail.

```bash
cd example && flutter run
```

## Documentation

- **[API reference](https://github.com/binary-castle/bc-ui-flutter/blob/main/doc/api.md)** — every component, prop, default and enum.
  The prop tables are generated from the source, so they track the code.
- `dart doc` generates the full dartdoc site from the inline documentation.

## Tests

```bash
flutter test
```

## License

The `LICENSE` file is still a placeholder — pick a license before publishing.
