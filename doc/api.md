# bc_ui API reference

Every component, its props and its enums. Prop tables are generated from the
source, so they track the code.

- New here? Start with the [README](../README.md).
- These tables are generated: `python3 tool/gen_api_doc.py` re-extracts them
  from `lib/src` after an API change.
- Looking for a live version of a component? `cd example && flutter run` —
  one screen per component, each with paged usage variants.

## Contents

- [Conventions](#conventions)
- [Theme and tokens](#theme-and-tokens)
- [Navigation](#navigation) — `BCAppHeader`, `BCSliverAppHeader`, `BCHeaderIconButton`, `BCBottomNav`, `BCNavRail`, `BCNavDrawer`, `BCToolbar`, `BCTabs`, `BCTabView`
- [Actions](#actions) — `BCButton`, `BCSocialAuthButton`, `BCBrandLogo`, `BCLinkButton`, `BCCloseButton`, `BCFab`, `BCSpeedDial`, `BCToggleButton`, `BCToggleButtonGroup`, `BCPressable`
- [Containers](#containers) — `BCSurface`, `BCCard`, `BCListGroup`, `BCAccordion`, `BCFlipCard`, `BCScrollShadow`
- [Data display](#data-display) — `BCText`, `BCAvatar`, `BCChip`, `BCRibbon`, `BCTagGroup`, `BCSeparator`, `BCSkeleton`, `BCSpinner`, `BCProgress`, `BCLoadingOverlay`, `BCRating`, `BCEmptyState`
- [Forms](#forms) — `BCInput`, `BCTextField`, `BCTextArea`, `BCPasswordInput`, `BCSearchField`, `BCInputOTP`, `BCDateField`, `BCTimeField`, `BCDateTimePicker`, `BCDateTimeWheel`, `BCCalendar`, `BCTimeWheel`, `BCPhoneField`, `BCSelect`, `BCControlField`
- [Selection](#selection) — `BCCheckbox`, `BCRadioGroup`, `BCSwitch`, `BCSlider`, `BCRangeSlider`
- [Overlays](#overlays) — `BCDialog`, `BCPopover`, `BCMenu`, `BCToast`

---

## Conventions

A few rules hold across the whole library, so you can guess most APIs:

- **Every component reads its colors from the theme**, never from hard-coded
  values. Reach the tokens yourself with `context.bcTheme`.
- **`variant` picks the look, `size` picks the metrics.** Both are enums named
  after the component (`BCButtonVariant`, `BCButtonSize`).
- **State is controlled.** Widgets take a value plus a change callback
  (`isSelected` + `onSelectedChange`, `value` + `onValueChange`) and never own
  their state, except where a controller is explicitly provided.
- **Disabled is `isDisabled`, invalid is `isInvalid`** — never `enabled: false`.
- **Compound components** (Card, TextField, InputOTP, Dialog, Menu) are built
  from named parts you compose as children, mirroring heroui-native.
- **Pickers share one `presentation`.** `BCDateField`, `BCTimeField` and
  `BCDateTimePicker` all take a `BCPickerPresentation` — `dialog`,
  `popover` or `bottomSheet` — and behave the same way in each.
- **Continuous corners everywhere.** Radii come from `BCRadius` and are drawn
  with `BCShapes.continuous` (Apple-style squircles), not plain circles.

## Theme and tokens

### Installing the theme

```dart
MaterialApp(
  theme: BCTheme.light(),
  darkTheme: BCTheme.dark(),
  themeMode: ThemeMode.system,
  // Only needed if you use BCToast:
  builder: (context, child) => BCToastProvider(child: child!),
  home: const HomeScreen(),
);
```

### `BCThemeOverrides`

```dart
BCTheme.light(
  overrides: BCThemeOverrides(
    accent: const Color(0xFF0F766E), // hover/soft/focus tokens are recomputed
    fontFamily: 'SF Pro Text',       // defaults to the bundled Inter
  ),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `accent` | `Color?` | — | Overrides HeroUI's `accent` token. Accent-derived tokens (hover, soft, soft-foreground, focus) are recomputed automatically. |
| `fontFamily` | `String?` | — | Replaces the default bundled Inter family. Declare the font in your app's `pubspec.yaml` when using a custom family. |
| `textTheme` | `TextTheme?` | — | Full typography override; takes precedence over `fontFamily`. |

### Reading tokens

```dart
final bc = context.bcTheme; // BCThemeExtension

Container(color: bc.surface);
Text('Hi', style: TextStyle(color: bc.muted));
DecoratedBox(
  decoration: ShapeDecoration(
    color: bc.accentSoft,
    shape: BCShapes.continuous(BCRadius.xxl),
    shadows: bc.surfaceShadow.shadows,
  ),
);
```

`context` also exposes `theme`, `colors` (Material `ColorScheme`) and `text`
(`TextTheme`) for the Material widgets you mix in.

### Color tokens

The 64 semantic slots mirror heroui-native's `--color-*` variables. Grouped:

| Group | Tokens |
|---|---|
| Page | `background`, `backgroundSecondary`, `backgroundTertiary`, `backgroundInverse`, `foreground` |
| Surfaces | `surface`, `surfaceForeground`, `surfaceHover`, `surfaceSecondary(+Foreground)`, `surfaceTertiary(+Foreground)` |
| Overlays | `overlay`, `overlayForeground`, `backdrop` |
| Accent | `accent`, `accentForeground`, `accentHover`, `accentSoft(+Foreground, +Hover)`, `focus`, `link` |
| Neutral | `defaultColor`, `defaultForeground`, `defaultHover`, `defaultSoft(+Foreground, +Hover)`, `muted`, `segment`, `segmentForeground` |
| Status | `success`, `warning`, `danger` — each with `Foreground`, `Hover`, `Soft`, `SoftForeground`, `SoftHover` |
| Fields | `field`, `fieldForeground`, `fieldPlaceholder`, `fieldBorder`, `fieldHover`, `fieldFocus`, `fieldBorderHover`, `fieldBorderFocus` |
| Lines | `border`, `borderSecondary`, `borderTertiary`, `separator`, `separatorSecondary`, `separatorTertiary` |
| Elevation | `surfaceShadow`, `overlayShadow`, `fieldShadow` (`BCShadowSet`: `shadows` + optional `innerBorder`) |
| Metrics | `borderWidth` (1), `opacityDisabled` (0.5) |

### Design tokens

| Class | What it holds |
|---|---|
| `BCSpacing` | 4px base unit: `xxs` 2, `xs` 4, `sm` 8, `md` 16, `lg` 24, `xl` 32, `xxl` 48, plus `unit(n)` |
| `BCRadius` | `xs` 2 → `xxxxl` 32, `field` 14, `full` 999 (base 8) |
| `BCShapes` | `continuous(radius)` / `continuousFrom(borderRadius)` — squircle borders |
| `BCTypography` | Inter + tailwind scale: `textXs`…`text4xl`, weights, `trackingTight(size)` |
| `BCSizes` | Button/input/avatar/spinner metrics |
| `BCMotion` | heroui timings and spring descriptions (press scale, switch thumb, tabs indicator…) |
| `BCDuration` | `fast` 150ms, `normal` 250ms, `slow` 400ms |
| `BCShadows` | Raw light/dark shadow sets behind the theme tokens |
| `BCBreakpoints` | Layout breakpoints |

---

## Navigation

### BCAppHeader

Top app bar with four backgrounds (frosted, solid, transparent, floating), an optional subtitle and a hairline separator that fades in when content scrolls under it. Drop it into `Scaffold.appBar`.

```dart
Scaffold(
  extendBodyBehindAppBar: true, // so there is something to blur
  appBar: BCAppHeader(
    title: const Text('Inbox'),
    subtitle: const Text('12 unread'),
    actions: [
      BCHeaderIconButton(icon: const Icon(Icons.search), onPressed: () {}),
      BCHeaderIconButton(
        icon: const Icon(Icons.notifications_none),
        badgeCount: 3,
        onPressed: () {},
      ),
    ],
  ),
  body: ListView(children: const []),
);

// Over a photo or hero: no background, white content, matching status bar.
BCAppHeader(
  variant: BCAppHeaderVariant.transparent,
  showSeparator: false,
  foregroundColor: Colors.white,
  title: const Text('Trip to Kyoto'),
  leading: BCHeaderIconButton(
    icon: const Icon(Icons.arrow_back_ios_new),
    filled: true,
    backgroundColor: const Color(0x40000000), // scrim
    onPressed: () {},
  ),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `title` | `Widget?` | — | Styled with a 16px semibold `BCTypography` style when it is a `Text`. |
| `subtitle` | `Widget?` | — | Secondary line under `title`, muted 12px. |
| `leading` | `Widget?` | — | Defaults to a back button when the route can be popped (a close button for fullscreen dialogs), unless `automaticallyImplyLeading` is false. |
| `actions` | `List<Widget>` | `const []` |  |
| `bottom` | `Widget?` | — | Optional row under the toolbar — tabs, a search field, filter chips. |
| `bottomHeight` | `double` | `48` | Height reserved for `bottom`. Ignored when `bottom` is a `PreferredSizeWidget`, which reports its own height. |
| `variant` | `BCAppHeaderVariant` | `BCAppHeaderVariant.blurred` |  |
| `centerTitle` | `bool` | `false` |  |
| `automaticallyImplyLeading` | `bool` | `true` |  |
| `filledIconButtons` | `bool` | `false` | Renders every `BCHeaderIconButton` in the leading and actions slots `BCHeaderIconButton.filled`, including the back button this header implies — so a screen picks the style once instead of at each button. A button that sets `filled` itself still wins. |
| `showSeparator` | `bool` | `true` | Draws the hairline `BCThemeExtension.border` separator along the bottom edge (never used by `BCAppHeaderVariant.floating`). |
| `separatorOnScrollOnly` | `bool` | `true` | Fades the separator in only while content is scrolled under the header. |
| `materializeOnScroll` | `bool` | `false` | Starts fully see-through and fades the blur + tint in once content is scrolled under — the iOS "hero materializes into a bar" behavior. Only meaningful for `BCAppHeaderVariant.blurred` and `BCAppHeaderVariant.floating`. |
| `backgroundColor` | `Color?` | — | Defaults to `BCThemeExtension.background` (blurred/solid) or `BCThemeExtension.surface` (floating). |
| `foregroundColor` | `Color?` | — | Colors the title, subtitle and any `BCHeaderIconButton` in the leading / actions slots — use it when the header sits over a photo or a dark hero. Defaults to `BCThemeExtension.foreground`. |
| `backgroundOpacity` | `double` | `0.72` | Alpha applied to `backgroundColor` behind the blur. |
| `blurSigma` | `double` | `24` |  |
| `systemOverlayStyle` | `SystemUiOverlayStyle?` | — | Status bar icon brightness while this header is on screen. Defaults to whatever contrasts with the resolved `foregroundColor` — a white-on-photo header gets light glyphs without any extra wiring. |
| `toolbarHeight` | `double` | `56` |  |

**`BCAppHeaderVariant`** — `blurred`, `solid`, `transparent`, `floating`

### BCSliverAppHeader

Pinned sliver header with an iOS-style large title that collapses into the compact toolbar title. Put it first in a `CustomScrollView`.

```dart
CustomScrollView(
  slivers: [
    BCSliverAppHeader(
      largeTitle: const Text('Library'),
      title: const Text('Library'), // compact title; defaults to largeTitle
      actions: [
        BCHeaderIconButton(icon: const Icon(Icons.add), onPressed: () {}),
      ],
    ),
    SliverList.builder(itemCount: 20, itemBuilder: (c, i) => Text('Row $i')),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `largeTitle` | `Widget` | required | Expanded 30px bold title. |
| `title` | `Widget?` | — | Compact title that fades in once collapsed. Defaults to `largeTitle`. |
| `leading` | `Widget?` | — |  |
| `actions` | `List<Widget>` | `const []` |  |
| `bottom` | `Widget?` | — |  |
| `bottomHeight` | `double` | `48` |  |
| `variant` | `BCAppHeaderVariant` | `BCAppHeaderVariant.blurred` |  |
| `automaticallyImplyLeading` | `bool` | `true` |  |
| `filledIconButtons` | `bool` | `false` | See `BCAppHeader.filledIconButtons`. |
| `showSeparator` | `bool` | `true` |  |
| `backgroundColor` | `Color?` | — |  |
| `foregroundColor` | `Color?` | — | See `BCAppHeader.foregroundColor`. |
| `backgroundOpacity` | `double` | `0.72` |  |
| `blurSigma` | `double` | `24` |  |
| `systemOverlayStyle` | `SystemUiOverlayStyle?` | — | See `BCAppHeader.systemOverlayStyle`. |
| `toolbarHeight` | `double` | `56` |  |
| `largeTitleHeight` | `double` | `56` | Height of the large-title row that collapses away. |

**`BCAppHeaderVariant`** — `blurred`, `solid`, `transparent`, `floating`

### BCHeaderIconButton

Round 40px icon button for header leading/action slots, with optional fill and badges.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `icon` | `Widget` | required |  |
| `onPressed` | `VoidCallback?` | — |  |
| `filled` | `bool?` | — | Paints a circle behind the icon, so it stays legible over photos.  Null defers to the enclosing header's `BCAppHeader.filledIconButtons`, and false where there is none — so a header can set the style for all of its buttons while a single button still opts in or out. |
| `size` | `double` | `40` |  |
| `iconSize` | `double` | `22` |  |
| `color` | `Color?` | — | Defaults to the header's `foregroundColor`, else the foreground token. |
| `backgroundColor` | `Color?` | — | Circle color when `filled`. Defaults to the `default` token; a translucent black reads better over a photo. |
| `badgeCount` | `int?` | — | Shows a small count badge (e.g. unread notifications). |
| `showDot` | `bool` | `false` | Shows a small dot badge (ignored when `badgeCount` is set). |
| `semanticLabel` | `String?` | — |  |
| `isDisabled` | `bool` | `false` |  |

### BCBottomNav

Bottom navigation bar — full-width or detached/floating — with an accent-soft pill indicator and badges.

```dart
BCBottomNav(
  currentIndex: index,
  onTap: (i) => setState(() => index = i),
  variant: BCBottomNavVariant.floating,
  items: const [
    BCBottomNavItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BCBottomNavItem(icon: Icon(Icons.mail_outline), label: 'Inbox', badgeCount: 5),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `items` | `List<BCBottomNavItem>` | required |  |
| `currentIndex` | `int` | required |  |
| `onTap` | `ValueChanged<int>` | required |  |
| `variant` | `BCBottomNavVariant` | `BCBottomNavVariant.standard` |  |
| `labels` | `BCBottomNavLabels` | `BCBottomNavLabels.all` |  |
| `showIndicator` | `bool` | `true` | Shows the accent-soft pill behind the selected icon. |

**`BCBottomNavVariant`** — `standard`, `floating`

**`BCBottomNavLabels`** — `all`, `selected`, `none`

<details><summary><code>BCBottomNavItem</code></summary>

A single destination in a `BCBottomNav`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `icon` | `Widget` | required |  |
| `label` | `String` | required |  |
| `activeIcon` | `Widget?` | — | Optional distinct icon for the selected state (defaults to `icon`). |
| `badgeCount` | `int?` | — | Shows a small count badge on the icon when non-null and > 0. |
| `showDot` | `bool` | `false` | Shows a small dot badge (ignored when `badgeCount` is set). |

</details>

### BCNavRail

Vertical navigation for medium and larger windows — the counterpart to `BCBottomNav` on compact ones. Collapsed it is an 80px icon strip; `extended` widens it so labels sit beside the icons, and the width change animates.

```dart
Row(
  children: [
    BCNavRail(
      selectedIndex: index,
      onDestinationSelected: (i) => setState(() => index = i),
      // Widen it once the window is big enough; the change animates.
      extended: MediaQuery.sizeOf(context).width >= 1240,
      leading: BCFab(icon: const Icon(Icons.edit), size: 48, onPressed: () {}),
      trailing: BCHeaderIconButton(
        icon: const Icon(Icons.settings_outlined),
        onPressed: () {},
      ),
      destinations: const [
        BCNavRailDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: 'Inbox',
          badgeCount: 12,
        ),
        BCNavRailDestination(icon: Icon(Icons.send_outlined), label: 'Sent'),
      ],
    ),
    const Expanded(child: Body()),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `destinations` | `List<BCNavRailDestination>` | required |  |
| `selectedIndex` | `int` | required |  |
| `onDestinationSelected` | `ValueChanged<int>` | required |  |
| `extended` | `bool` | `false` | Widens the rail and moves labels beside their icons. |
| `labels` | `BCNavRailLabels` | `BCNavRailLabels.all` | Label visibility while collapsed; the extended rail always shows them. |
| `leading` | `Widget?` | — | Pinned above the destinations — typically a FAB or a menu button. |
| `trailing` | `Widget?` | — | Pinned below the destinations — settings, an avatar, a theme toggle. |
| `groupAlignment` | `double` | `-1` | Vertical placement of the destination group: -1 top, 0 center, 1 bottom. |
| `showIndicator` | `bool` | `true` | Paints the accent-soft pill behind the selected destination. |
| `showSeparator` | `bool` | `true` | Hairline border on the trailing edge, separating rail from content. |
| `backgroundColor` | `Color?` | — |  |
| `width` | `double` | `80` |  |
| `extendedWidth` | `double` | `232` |  |

**`BCNavRailLabels`** — `all`, `selected`, `none`

<details><summary><code>BCNavRailDestination</code></summary>

A destination in a `BCNavRail`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `icon` | `Widget` | required |  |
| `label` | `String` | required |  |
| `selectedIcon` | `Widget?` | — | Optional distinct icon for the selected state (defaults to `icon`). |
| `badgeCount` | `int?` | — | Shows a small count badge on the icon when non-null and > 0. |
| `showDot` | `bool` | `false` | Shows a small dot badge (ignored when `badgeCount` is set). |

</details>

### BCNavDrawer

Wide vertical navigation, inline on large windows (`standard`) or sliding over content from `Scaffold.drawer` (`modal`). Items mix destinations with section labels and dividers; `selectedIndex` counts destinations only.

```dart
Scaffold(
  drawer: BCNavDrawer(
    variant: BCNavDrawerVariant.modal,
    selectedIndex: index,
    onDestinationSelected: (i) => setState(() => index = i),
    header: const Text('Binary Castle'),
    items: const [
      BCNavDrawerSection('Mail'),
      BCNavDrawerDestination(
        icon: Icon(Icons.inbox_outlined),
        selectedIcon: Icon(Icons.inbox),
        label: 'Inbox',
        badgeCount: 24,
      ),
      BCNavDrawerDivider(),
      BCNavDrawerSection('Labels'),
      BCNavDrawerDestination(icon: Icon(Icons.work_outline), label: 'Work'),
    ],
  ),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `items` | `List<BCNavDrawerItem>` | required |  |
| `selectedIndex` | `int` | required | Index among the `BCNavDrawerDestination` entries only. |
| `onDestinationSelected` | `ValueChanged<int>` | required |  |
| `variant` | `BCNavDrawerVariant` | `BCNavDrawerVariant.standard` |  |
| `header` | `Widget?` | — | Above the items — a product name, an account row, a search field. |
| `footer` | `Widget?` | — | Below the items, pinned to the bottom edge. |
| `width` | `double` | `320` |  |
| `showIndicator` | `bool` | `true` | Paints the accent-soft pill behind the selected destination. |
| `backgroundColor` | `Color?` | — |  |
| `closeOnSelect` | `bool` | `true` | Pops the enclosing route (the `Scaffold` drawer) after a selection. Only applies to `BCNavDrawerVariant.modal`. |

**`BCNavDrawerVariant`** — `standard`, `modal`

<details><summary><code>BCNavDrawerItem</code></summary>

An entry in a `BCNavDrawer`: a destination, a section label, or a rule.

</details>

<details><summary><code>BCNavDrawerDestination</code></summary>

A selectable destination. Only these count towards `selectedIndex`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `icon` | `Widget` | required |  |
| `label` | `String` | required |  |
| `selectedIcon` | `Widget?` | — | Optional distinct icon for the selected state (defaults to `icon`). |
| `badgeCount` | `int?` | — |  |
| `showDot` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |

</details>

<details><summary><code>BCNavDrawerSection</code></summary>

A muted heading above a group of destinations.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `label` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCNavDrawerDivider</code></summary>

A hairline rule between groups.

</details>

### BCToolbar

A bar of actions for the current screen — the bottom-of-screen counterpart to `BCAppHeader`. Docked to the edge or floating as a rounded pill, horizontal or vertical, optionally frosted.

```dart
Scaffold(
  bottomNavigationBar: BCToolbar(
    primaryAction: BCFab(icon: const Icon(Icons.check), size: 48, onPressed: () {}),
    children: [
      BCHeaderIconButton(icon: const Icon(Icons.undo), onPressed: () {}),
      BCHeaderIconButton(icon: const Icon(Icons.redo), onPressed: () {}),
      BCHeaderIconButton(icon: const Icon(Icons.palette_outlined), onPressed: () {}),
    ],
  ),
);

// Floating pill over the content, frosted so it reads over anything.
BCToolbar(
  variant: BCToolbarVariant.floating,
  blurred: true,
  children: [...],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `children` | `List<Widget>` | required | The action buttons, in reading order. |
| `variant` | `BCToolbarVariant` | `BCToolbarVariant.docked` |  |
| `axis` | `BCToolbarAxis` | `BCToolbarAxis.horizontal` | Vertical toolbars sit along the side of the content, e.g. a canvas editor's tool strip. |
| `primaryAction` | `Widget?` | — | Emphasized action, placed after `children` and separated from them. |
| `alignment` | `MainAxisAlignment` | `MainAxisAlignment.spaceEvenly` | How `children` are distributed along the bar. |
| `blurred` | `bool` | `false` | Frosts the bar so content scrolls visibly underneath it. |
| `blurSigma` | `double` | `24` |  |
| `backgroundOpacity` | `double` | `0.72` | Alpha applied to the background when `blurred`. |
| `backgroundColor` | `Color?` | — | Defaults to `background` (docked) or `surface` (floating). |
| `showSeparator` | `bool` | `true` | Hairline along the leading edge of a docked toolbar. |
| `spacing` | `double` | `BCSpacing.xs` |  |
| `padding` | `EdgeInsetsGeometry?` | — |  |

**`BCToolbarVariant`** — `docked`, `floating`

**`BCToolbarAxis`** — `horizontal`, `vertical`

### BCTabs

Segmented control. Drive it with `value` + `onValueChange`, or hand it a `BCTabsController` to pair it with a swipeable `BCTabView`.

```dart
// Uncontrolled: you own the value.
BCTabs<String>(
  value: tab,
  onValueChange: (value) => setState(() => tab = value),
  items: const [
    BCTabItem(value: 'all', label: 'All'),
    BCTabItem(value: 'open', label: 'Open'),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `items` | `List<BCTabItem<T>>` | required |  |
| `value` | `T?` | — | Selected value when driving the bar yourself. Omit when using `controller`. |
| `controller` | `BCTabsController<T>?` | — | Ties this bar to a `BCTabView`; the indicator then follows the swipe. |
| `onValueChange` | `ValueChanged<T>?` | — | Called on tap, and on swipe when a `controller` is attached. |
| `variant` | `BCTabsVariant` | `BCTabsVariant.primary` |  |
| `fullWidth` | `bool` | `false` | Stretches the list to fill the available width, distributing triggers evenly. |

**`BCTabsVariant`** — `primary`, `secondary`

<details><summary><code>BCTabItem</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `T` | required |  |
| `label` | `String` | required |  |
| `icon` | `Widget?` | — |  |

</details>

<details><summary><code>BCTabsController</code></summary>

Shared state for a `BCTabs` bar and the `BCTabView` it drives.  The controller owns the `PageController`, which makes the swipe position the single source of truth: dragging the view moves the tab indicator continuously (it tracks the finger, it does not just snap at the end), and tapping a trigger animates the view to that page. Dispose it with the `State` that created it.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `values` |  | required |  |
| `initialValue` |  | — |  |

- `BCTabsController({required List<T> values, T? initialValue})` — Create one per tab bar + view pair and dispose it with your `State`.
- `T value` — The settled tab.
- `int index` — Index of the settled tab.
- `double offset` — Continuous position — `1.4` halfway through a swipe from tab 1 to 2. Drives the indicator.
- `List<T> values` — The tab values, in panel order.
- `PageController pageController` — Owned by the controller; hand it to `BCTabView`, not to a bare `PageView`.
- `Future<void> animateTo(T value, {Duration duration, Curve curve})` — Animate bar + panels to a tab.
- `void jumpTo(T value)` — Switch without animating.
- `void dispose()` — Disposes the page controller too.

</details>

### BCTabView

The swipeable panels behind a `BCTabs` bar. Sharing a controller means a drag switches tabs and carries the indicator with it.

```dart
// Swipeable: bar + panels share one controller.
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
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `controller` | `BCTabsController<T>` | required |  |
| `children` | `List<Widget>` | required | One panel per value in `BCTabsController.values`, in the same order. |
| `swipeEnabled` | `bool` | `true` | Set false to keep the panels in sync with the bar but only switchable by tapping a trigger. |
| `physics` | `ScrollPhysics?` | — | Overrides the scroll physics; ignored when `swipeEnabled` is false. |
| `clipBehavior` | `Clip` | `Clip.hardEdge` |  |

---

## Actions

### BCButton

The primary action component: 7 variants x 3 sizes, optional leading/trailing content, icon-only and full-width modes.

```dart
BCButton(
  variant: BCButtonVariant.secondary,
  size: BCButtonSize.lg,
  onPressed: () {},
  startContent: const Icon(Icons.add, size: 18),
  child: const Text('Add item'),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `onPressed` | `VoidCallback?` | — |  |
| `variant` | `BCButtonVariant` | `BCButtonVariant.primary` |  |
| `size` | `BCButtonSize` | `BCButtonSize.md` |  |
| `isIconOnly` | `bool` | `false` | Square button with no horizontal padding (aspect-ratio 1). |
| `isDisabled` | `bool` | `false` |  |
| `fullWidth` | `bool` | `false` | Stretches the button to the available width. |
| `feedback` | `BCPressFeedback` | `BCPressFeedback.scaleHighlight` |  |
| `startContent` | `Widget?` | — |  |
| `endContent` | `Widget?` | — |  |

**`BCButtonVariant`** — `primary`, `secondary`, `tertiary`, `outline`, `ghost`, `danger`, `dangerSoft`

**`BCButtonSize`** — `sm`, `md`, `lg`

**`BCPressFeedback`** — `scaleHighlight`, `scaleRipple`, `scale`, `highlight`, `material`, `none`

### BCSocialAuthButton

Sign-in button for an identity provider — a `BCButton` with the provider's brand mark as start content, so it lines up with every other button on the screen. Ten providers ship with the package; logos are vector data, not assets.

```dart
// A stack of sign-in options: outline buttons, full width by default.
Column(
  spacing: 12,
  children: [
    BCSocialAuthButton(
      provider: BCSocialProvider.google,
      onPressed: signInWithGoogle,
    ),
    BCSocialAuthButton(
      provider: BCSocialProvider.apple,
      label: 'Continue with Apple',
      isLoading: isAuthenticating, // logo -> spinner, presses blocked
      onPressed: signInWithApple,
    ),
  ],
);

// Any BCButton variant and size works; on tinted variants the mark
// goes monochrome so it does not clash with the background.
BCSocialAuthButton(
  provider: BCSocialProvider.microsoft,
  variant: BCButtonVariant.primary,
  size: BCButtonSize.lg,
  onPressed: () {},
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `provider` | `BCSocialProvider` | required |  |
| `onPressed` | `VoidCallback?` | — |  |
| `label` | `String?` | — | Defaults to the provider's name ('Google', 'GitHub', …). Pass a full phrase for the common 'Continue with X' framing. |
| `variant` | `BCButtonVariant` | `BCButtonVariant.outline` |  |
| `size` | `BCButtonSize` | `BCButtonSize.md` |  |
| `logoStyle` | `BCBrandLogoStyle` | `BCBrandLogoStyle.auto` |  |
| `isIconOnly` | `bool` | `false` | Drops the label and renders a square, logo-only button. |
| `isLoading` | `bool` | `false` | Swaps the logo for a spinner and blocks presses while a sign-in is in flight. |
| `isDisabled` | `bool` | `false` |  |
| `fullWidth` | `bool` | `true` | Stretches the button to the available width — the usual layout for a stack of sign-in options. Ignored when `isIconOnly` is set. |
| `feedback` | `BCPressFeedback` | `BCPressFeedback.scaleHighlight` |  |
| `endContent` | `Widget?` | — |  |

**`BCSocialProvider`** — `google`, `apple`, `github`, `facebook`, `microsoft`, `x`, `discord`, `slack`, `notion`, `linear`

**`BCButtonVariant`** — `primary`, `secondary`, `tertiary`, `outline`, `ghost`, `danger`, `dangerSoft`

**`BCButtonSize`** — `sm`, `md`, `lg`

**`BCBrandLogoStyle`** — `auto`, `brand`, `monochrome`

**`BCPressFeedback`** — `scaleHighlight`, `scaleRipple`, `scale`, `highlight`, `material`, `none`

### BCBrandLogo

A provider's brand mark painted as vector art at any size, in official colours or as a single-colour glyph. Used by `BCSocialAuthButton`; usable on its own for account rows and settings.

```dart
const BCBrandLogo(provider: BCSocialProvider.github, size: 24);

// Single-colour glyph instead of the brand colours.
BCBrandLogo(
  provider: BCSocialProvider.slack,
  color: context.bcTheme.foreground,
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `provider` | `BCSocialProvider` | required |  |
| `size` | `double` | `20` | Side of the square the mark is fitted into, preserving its aspect ratio. |
| `color` | `Color?` | — | Paints the mark as a single-colour glyph.  When null the official brand colours are used; providers whose mark is monochrome by design (`BCSocialProvider.hasMonochromeMark`) fall back to the theme foreground so they stay legible in dark mode. |

**`BCSocialProvider`** — `google`, `apple`, `github`, `facebook`, `microsoft`, `x`, `discord`, `slack`, `notion`, `linear`

### BCLinkButton

Text-only action that reads as a link.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `onPressed` | `VoidCallback?` | — |  |
| `size` | `BCLinkButtonSize` | `BCLinkButtonSize.md` |  |
| `isDisabled` | `bool` | `false` |  |
| `feedback` | `BCPressFeedback` | `BCPressFeedback.scale` |  |
| `startContent` | `Widget?` | — |  |
| `endContent` | `Widget?` | — |  |

**`BCLinkButtonSize`** — `sm`, `md`, `lg`

**`BCPressFeedback`** — `scaleHighlight`, `scaleRipple`, `scale`, `highlight`, `material`, `none`

### BCCloseButton

32px tertiary icon button used by dialogs and dismissible surfaces.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `onPressed` | `VoidCallback?` | — |  |
| `iconSize` | `double` | `18` |  |
| `iconColor` | `Color?` | — | Defaults to the muted token. |
| `isDisabled` | `bool` | `false` |  |
| `feedback` | `BCPressFeedback` | `BCPressFeedback.scaleHighlight` |  |

**`BCPressFeedback`** — `scaleHighlight`, `scaleRipple`, `scale`, `highlight`, `material`, `none`

### BCFab

Floating action button.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `icon` | `Widget` | required |  |
| `onPressed` | `VoidCallback?` | — |  |
| `backgroundColor` | `Color?` | — | Defaults to the accent token. |
| `foregroundColor` | `Color?` | — | Defaults to the accent-foreground token. |
| `size` | `double` | `56` |  |
| `isDisabled` | `bool` | `false` |  |
| `tooltip` | `String?` | — |  |

### BCSpeedDial

FAB that expands into a labelled action list over a dimmed or blurred backdrop.

```dart
BCSpeedDial(
  items: [
    BCSpeedDialItem(label: 'New note', icon: const Icon(Icons.note_add), onPressed: () {}),
    BCSpeedDialItem(label: 'Delete', icon: const Icon(Icons.delete), isDanger: true, onPressed: () {}),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `items` | `List<BCSpeedDialItem>` | required |  |
| `icon` | `Widget` | `const Icon(Icons.add)` | Icon shown when closed. |
| `openIcon` | `Widget` | `const Icon(Icons.close)` | Icon shown when open (defaults to a close X). |
| `alignment` | `BCFabAlignment` | `BCFabAlignment.right` |  |
| `backdrop` | `BCFabBackdrop` | `BCFabBackdrop.dim` |  |
| `size` | `double` | `56` |  |
| `isDisabled` | `bool` | `false` |  |
| `onOpenChange` | `ValueChanged<bool>?` | — |  |

**`BCFabAlignment`** — `right`, `left`

**`BCFabBackdrop`** — `dim`, `blur`, `none`

<details><summary><code>BCSpeedDialItem</code></summary>

A single action inside a `BCSpeedDial`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `label` | `String` | required |  |
| `icon` | `Widget?` | — |  |
| `onPressed` | `VoidCallback?` | — |  |
| `isDanger` | `bool` | `false` | Renders the label/icon in the danger color (e.g. "Delete"). |

</details>

### BCToggleButton

Two-state button (icon, label, or both).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `isSelected` | `bool` | required |  |
| `onSelectedChange` | `ValueChanged<bool>?` | — |  |
| `icon` | `Widget?` | — |  |
| `selectedIcon` | `Widget?` | — | Shown instead of `icon` while selected (e.g. a filled variant). |
| `label` | `String?` | — |  |
| `size` | `BCToggleButtonSize` | `BCToggleButtonSize.md` |  |
| `variant` | `BCToggleButtonVariant` | `BCToggleButtonVariant.standard` |  |
| `isIconOnly` | `bool` | `false` | Circular, label-free form. |
| `isDisabled` | `bool` | `false` |  |
| `feedback` | `BCPressFeedback` | `BCPressFeedback.scale` |  |

**`BCToggleButtonSize`** — `sm`, `md`, `lg`

**`BCToggleButtonVariant`** — `standard`, `accent`, `ghost`

**`BCPressFeedback`** — `scaleHighlight`, `scaleRipple`, `scale`, `highlight`, `material`, `none`

### BCToggleButtonGroup

Row of toggle buttons with single or multiple selection.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `options` | `List<BCToggleButtonOption<T>>` | required |  |
| `selectedValues` | `Set<T>` | required |  |
| `onSelectionChange` | `ValueChanged<Set<T>>?` | — |  |
| `allowMultiple` | `bool` | `false` | Allows more than one option to be selected at a time. |
| `allowEmpty` | `bool` | `true` | When false, the last selected option can't be deselected. |
| `size` | `BCToggleButtonSize` | `BCToggleButtonSize.md` |  |
| `variant` | `BCToggleButtonVariant` | `BCToggleButtonVariant.standard` |  |
| `isIconOnly` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `spacing` | `double` | `8` |  |

**`BCToggleButtonSize`** — `sm`, `md`, `lg`

**`BCToggleButtonVariant`** — `standard`, `accent`, `ghost`

<details><summary><code>BCToggleButtonOption</code></summary>

One option inside a `BCToggleButtonGroup`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `T` | required |  |
| `icon` | `Widget?` | — |  |
| `selectedIcon` | `Widget?` | — |  |
| `label` | `String?` | — |  |

</details>

### BCPressable

The press-feedback engine every interactive component is built on — scale, highlight and ripple, with heroui-native's exact timings.

```dart
BCPressable(
  feedback: BCPressFeedback.scaleRipple,
  onPressed: () {},
  shape: BCShapes.continuous(BCRadius.xxl),
  background: DecoratedBox(
    decoration: ShapeDecoration(
      color: context.bcTheme.surface,
      shape: BCShapes.continuous(BCRadius.xxl),
    ),
  ),
  child: const Padding(padding: EdgeInsets.all(16), child: Text('Tap me')),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `background` | `Widget?` | — | Painted behind the highlight/ripple layers, which in turn sit behind `child`. Put the component's background decoration here so press highlights never cover the content (heroui renders its Highlight between background and children the same way). |
| `onPressed` | `VoidCallback?` | — |  |
| `onLongPress` | `VoidCallback?` | — |  |
| `feedback` | `BCPressFeedback` | `BCPressFeedback.scaleHighlight` |  |
| `shape` | `ShapeBorder?` | — | Shape used to clip the highlight/ripple layers. When null the layers fill the child's rect unclipped. |
| `highlightColor` | `Color?` | — | Highlight overlay color. Defaults to HeroUI's theme-aware gray; pass a component's `*-hover` token to reproduce CSS hover-style highlights. |
| `highlightOpacityRange` | `(double, double)?` | — | (unpressed, pressed) highlight opacity. Defaults to (0, 0.1). |
| `scaleTarget` | `double` | `0.985` |  |
| `ignoreScaleCoefficient` | `bool` | `false` | Disables the 300/width scale compensation. |
| `enabled` | `bool` | `true` |  |
| `behavior` | `HitTestBehavior` | `HitTestBehavior.opaque` |  |

**`BCPressFeedback`** — `scaleHighlight`, `scaleRipple`, `scale`, `highlight`, `material`, `none`

---

## Containers

### BCSurface

Base container: 16px padding, 24px continuous corners, surface shadow.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `variant` | `BCSurfaceVariant` | `BCSurfaceVariant.defaultVariant` |  |
| `padding` | `EdgeInsetsGeometry?` | — | Defaults to `EdgeInsets.all(16)`. |
| `borderRadius` | `double?` | — | Defaults to `BCRadius.xxxl` (24). |
| `clipBehavior` | `Clip` | `Clip.antiAlias` |  |
| `width` | `double?` | — |  |
| `height` | `double?` | — |  |
| `child` | `Widget` | required |  |

**`BCSurfaceVariant`** — `defaultVariant`, `secondary`, `tertiary`, `transparent`

### BCCard

Surface with the compound header/body/footer/title/description parts.

```dart
BCCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const BCCardHeader(child: BCCardTitle('Total balance')),
      const BCCardBody(child: BCCardDescription('Across all accounts')),
      BCCardFooter(
        child: BCButton(onPressed: () {}, child: const Text('Add money')),
      ),
    ],
  ),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `variant` | `BCCardVariant` | `BCCardVariant.defaultVariant` |  |
| `padding` | `EdgeInsetsGeometry?` | — |  |

**`BCCardVariant`** — `defaultVariant`, `secondary`, `tertiary`, `transparent`

<details><summary><code>BCCardHeader</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |

</details>

<details><summary><code>BCCardBody</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |

</details>

<details><summary><code>BCCardFooter</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |

</details>

<details><summary><code>BCCardTitle</code></summary>

Card title: text-lg, medium weight, foreground (card.css `card__label`).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCCardDescription</code></summary>

Card description: text-base, muted (card.css `card__description`).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

### BCListGroup

Grouped rows inside one rounded surface, with hairline separators.

```dart
BCListGroup(
  children: [
    BCListGroupItem(
      title: 'Figma',
      description: 'Design tools',
      prefix: const Icon(Icons.brush_outlined),
      suffix: const Text(r'-$15.00'),
      onPressed: () {},
    ),
    BCListGroupItem(title: 'Notifications', content: BCSwitch(isSelected: on, onSelectedChange: (v) {})),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `children` | `List<Widget>` | required |  |
| `variant` | `BCSurfaceVariant` | `BCSurfaceVariant.defaultVariant` |  |
| `showSeparators` | `bool` | `true` |  |

**`BCSurfaceVariant`** — `defaultVariant`, `secondary`, `tertiary`, `transparent`

<details><summary><code>BCListGroupItem</code></summary>

A list row: prefix | title/description | suffix, 16px padding, gap 12, press highlight (no scale).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `title` | `String?` | — |  |
| `description` | `String?` | — |  |
| `prefix` | `Widget?` | — |  |
| `suffix` | `Widget?` | — |  |
| `content` | `Widget?` | — | Custom middle content; replaces `title`/`description`. |
| `onPressed` | `VoidCallback?` | — |  |
| `isDisabled` | `bool` | `false` |  |

</details>

### BCAccordion

Collapsible sections stacked in one column — one open at a time, or several with `selectionMode`. Plain by default; `surface` wraps the stack in a rounded surface. Each `BCAccordionItem` pairs a `BCAccordionTrigger` with a `BCAccordionContent` that springs open as it fades in, and a chevron that rotates with it. Drive it with `value` + `onValueChange`, or hand it a `BCAccordionController`.

```dart
// You own the set of expanded values.
BCAccordion(
  value: expanded,
  onValueChange: (value) => setState(() => expanded = value),
  variant: BCAccordionVariant.surface,
  children: const [
    BCAccordionItem(
      value: 'shipping',
      children: [
        BCAccordionTrigger(child: Text('How much does shipping cost?')),
        BCAccordionContent(child: Text('Free over $50.')),
      ],
    ),
    BCAccordionItem(
      value: 'returns',
      children: [
        BCAccordionTrigger(child: Text('Can I return an item?')),
        BCAccordionContent(child: Text('Within 30 days.')),
      ],
    ),
  ],
);

// Or let a controller own it, with several sections open at once.
final faq = BCAccordionController(initialValue: const {'shipping'});

BCAccordion(
  controller: faq,
  selectionMode: BCAccordionSelectionMode.multiple,
  children: [...],
);

// A custom indicator is not rotated for you — read the state yourself.
BCAccordionTrigger(
  child: const Text('Details'),
  indicator: Builder(
    builder: (context) => Icon(
      BCAccordionItem.isExpandedOf(context) ? Icons.remove : Icons.add,
      size: 16,
    ),
  ),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `children` | `List<Widget>` | required | The `BCAccordionItem`s. Anything else is rendered as-is and still counts for separator placement, matching heroui's `Children.map`. |
| `value` | `Set<String>?` | — | The expanded item values; empty means everything is closed. Mutually exclusive with `controller`. |
| `onValueChange` | `ValueChanged<Set<String>>?` | — | Called with the next expanded set. Pair it with `value`. |
| `controller` | `BCAccordionController?` | — | Owns the expanded set instead of `value`. Dispose it with the `State` that created it. |
| `selectionMode` | `BCAccordionSelectionMode` | `BCAccordionSelectionMode.single` |  |
| `variant` | `BCAccordionVariant` | `BCAccordionVariant.defaultVariant` |  |
| `hideSeparator` | `bool` | `false` | Hides the hairline lines drawn between items. |
| `isCollapsible` | `bool` | `true` | When false, tapping the open item leaves it open (heroui's `isCollapsible`), so the accordion always has something expanded once the first item is opened. |
| `isDisabled` | `bool` | `false` | Dims every item and stops them responding to taps. |

**`BCAccordionSelectionMode`** — `single`, `multiple`

**`BCAccordionVariant`** — `defaultVariant`, `surface`

<details><summary><code>BCAccordionItem</code></summary>

One collapsible section: usually a `BCAccordionTrigger` followed by a `BCAccordionContent`.  Outside a `BCAccordion` it still renders, but nothing can ever expand it — the house behaviour for compound parts.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `String` | required | Identifies this item in `BCAccordion.value`. Two items sharing a value expand together — heroui behaves the same way. |
| `children` | `List<Widget>?` | — | The section's parts, stacked in a column. Mutually exclusive with `builder`. |
| `builder` | `Widget Function(BuildContext context, bool isExpanded)?` | — | heroui's render-function child: rebuilt with this item's expanded state. Reach for it when the whole section changes shape when open; for a single part that cares, `isExpandedOf` is lighter. |
| `isDisabled` | `bool` | `false` | Dims this item and stops it responding to taps. |

</details>

<details><summary><code>BCAccordionTrigger</code></summary>

The row that toggles its `BCAccordionItem`: `child` on the leading side, the indicator flush to the trailing edge.  16px vertical padding, 12px horizontal (20px in the surface variant), 16px gap — `.accordion__trigger`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required | Leading content. It expands to fill, so the indicator sits flush right (heroui's `justify-content: space-between`). |
| `indicator` | `Widget?` | — | Defaults to a `BCAccordionIndicator` — a chevron that rotates with the item. |
| `hideIndicator` | `bool` | `false` | Renders no indicator at all. Distinct from `indicator: null`, which just falls back to the default. |
| `isDisabled` | `bool` | `false` |  |
| `onPressed` | `VoidCallback?` | — | Runs after the item has toggled — heroui's `onPress` passthrough. |
| `feedback` | `BCPressFeedback` | `BCPressFeedback.highlight` | Defaults to `BCPressFeedback.highlight`: a full-width row that scales looks wrong, and it is what heroui's own example uses. |

**`BCPressFeedback`** — `scaleHighlight`, `scaleRipple`, `scale`, `highlight`, `material`, `none`

</details>

<details><summary><code>BCAccordionIndicator</code></summary>

The chevron at the trailing edge of a `BCAccordionTrigger`, rotating 0 → -180° on a spring (mass 4, stiffness 1000, damping 140) as its item expands.  The rotation really is counter-clockwise. `INDICATOR_ROTATION` in heroui's `accordion.constants.ts` reads `180deg`, but nothing imports it — the live default rotates 0 to -180 degrees, in `accordion.animation.ts`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget?` | — | A custom indicator, which is **not** rotated — heroui does the same. Animate it yourself off `BCAccordionItem.isExpandedOf`. |
| `size` | `double` | `16` | heroui's `DEFAULT_ICON_SIZE`. |
| `color` | `Color?` | — | Defaults to the `foreground` token. |

</details>

<details><summary><code>BCAccordionContent</code></summary>

The body revealed when its `BCAccordionItem` expands.  Height springs on heroui's `ACCORDION_LAYOUT_TRANSITION` (mass 4, stiffness 1600, damping 140) while the body fades over 200ms — `easeOut` in, `easeIn` out, the exact equivalents of Reanimated's `Easing.out(Easing.ease)` / `Easing.in(Easing.ease)`.  The subtree is built on first expand and dropped once a collapse settles, mirroring heroui rendering `null` while closed. Anything stateful inside — a text field's contents, a scroll offset — is therefore rebuilt from scratch on the next expand; lift that state above the accordion. The content is also laid out at its natural height, so an unbounded-height child such as a bare `ListView` needs `shrinkWrap: true` or a fixed height.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `padding` | `EdgeInsetsGeometry?` | — | Defaults to 12px start/end (20px in the surface variant) and 16px bottom — `.accordion__content`. |

</details>

<details><summary><code>BCAccordionController</code></summary>

Owns a `BCAccordion`'s set of expanded item values, so the accordion can be driven from outside without lifting the set into your own `setState`.  Create one in a `State` and dispose it there: heroui's uncontrolled `defaultValue="2"` is `initialValue: {'2'}` here.  There is deliberately no `toggle`: toggling depends on `BCAccordion.selectionMode` and `BCAccordion.isCollapsible`, which live on the widget, so tapping a `BCAccordionTrigger` is the only thing that applies them. `expand` and `collapse` set one item without consulting either.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `initialValue` |  | `const <String>{}` |  |

- `BCAccordionController({Set<String> initialValue = const {}})` — Create one per accordion and dispose it with your `State`. heroui's uncontrolled `defaultValue` is `initialValue` here.
- `Set<String> value` — The expanded item values. The getter is an unmodifiable view — assign a new set to change them.
- `bool isExpanded(String value)` — Whether that item is open.
- `void expand(String value)` — Opens one item, leaving the others alone. Does not apply `selectionMode`.
- `void collapse(String value)` — Closes one item.
- `void collapseAll()` — Closes everything.

</details>

### BCFlipCard

Two faces that flip on tap or programmatically.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `front` | `Widget` | required |  |
| `back` | `Widget` | required |  |
| `isFlipped` | `bool?` | — | When non-null the card is controlled: it reflects this value and never changes it itself — call `onFlip` / update this value to flip. |
| `onFlip` | `ValueChanged<bool>?` | — |  |
| `flipOnTap` | `bool` | `true` | Whether tapping toggles the flip. Ignored while a tap would conflict with a controlled parent that sets `flipOnTap` false. |
| `direction` | `Axis` | `Axis.horizontal` | Rotation axis: horizontal flips around Y, vertical around X. |
| `duration` | `Duration` | `const Duration(milliseconds: 450)` |  |
| `curve` | `Curve` | `Curves.easeInOut` |  |

### BCScrollShadow

Fades a gradient in at the edges of a scrollable while there is more to scroll.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `size` | `double` | `40` | Extent of the fade gradient. |
| `color` | `Color?` | — | Defaults to the theme `background` color. |
| `direction` | `Axis` | `Axis.vertical` |  |

---

## Data display

### BCText

Typography primitive with the heroui type scale.

```dart
const BCText('Section title', type: BCTextType.h4);
const BCText('Muted caption', type: BCTextType.bodyXs, color: BCTextColor.muted);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `data` | `String` | required | First positional argument. |
| `type` | `BCTextType` | `BCTextType.body` |  |
| `color` | `BCTextColor` | `BCTextColor.foreground` |  |
| `weight` | `BCTextWeight?` | — | Explicit weight wins over the type's default weight. |
| `align` | `TextAlign?` | — |  |
| `maxLines` | `int?` | — |  |
| `overflow` | `TextOverflow?` | — |  |
| `style` | `TextStyle?` | — | Merged last, over the resolved style. |

**`BCTextType`** — `h1`, `h2`, `h3`, `h4`, `h5`, `h6`, `body`, `bodySm`, `bodyXs`, `code`

**`BCTextColor`** — `foreground`, `muted`

**`BCTextWeight`** — `normal`, `medium`, `semibold`, `bold`

### BCAvatar

Composable avatar: image with a fallback that shows initials while loading or on error.

```dart
BCAvatar(
  size: BCAvatarSize.large,
  children: [
    BCAvatarImage(image: NetworkImage(url)),
    const BCAvatarFallback(initials: 'RK'), // shown while loading / on error
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `children` | `List<Widget>` | required |  |
| `size` | `BCAvatarSize` | `BCAvatarSize.medium` |  |
| `variant` | `BCAvatarVariant` | `BCAvatarVariant.defaultVariant` |  |
| `color` | `BCAvatarColor` | `BCAvatarColor.accent` |  |

**`BCAvatarSize`** — `small`, `medium`, `large`

**`BCAvatarVariant`** — `defaultVariant`, `soft`

**`BCAvatarColor`** — `accent`, `defaultColor`, `success`, `warning`, `danger`

<details><summary><code>BCAvatarImage</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `image` | `ImageProvider` | required |  |
| `fit` | `BoxFit` | `BoxFit.cover` |  |

</details>

<details><summary><code>BCAvatarFallback</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget?` | — |  |
| `initials` | `String?` | — |  |
| `delayMs` | `int` | `0` |  |

</details>

### BCChip

Compact pill for status, filters and metadata.

```dart
BCChip(
  variant: BCChipVariant.soft,
  color: BCChipColor.success,
  startContent: const Icon(Icons.trending_up, size: 14),
  child: const Text('+12.4%'),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `variant` | `BCChipVariant` | `BCChipVariant.primary` |  |
| `size` | `BCChipSize` | `BCChipSize.md` |  |
| `color` | `BCChipColor` | `BCChipColor.accent` |  |
| `startContent` | `Widget?` | — |  |
| `endContent` | `Widget?` | — |  |
| `onPressed` | `VoidCallback?` | — |  |

**`BCChipVariant`** — `primary`, `secondary`, `tertiary`, `soft`

**`BCChipSize`** — `sm`, `md`, `lg`

**`BCChipColor`** — `accent`, `defaultColor`, `success`, `warning`, `danger`

### BCRibbon

Merchandising ribbon for product cards — 'Hot Sale', 'Nearby', '-30%'. Five forms — pill tag, edge flag, corner sash, full-width banner, bookmark — laid over a card and clipped to its corners where the form needs it. The corner band sizes itself to its label and takes `cornerOffset`/`cornerThickness`, so it runs from a thin floating stripe to a filled corner (`cornerOffset: 0`). The overlay never takes pointer events, so the card stays tappable.

```dart
// Wraps the card it decorates.
BCRibbon.label(
  'Hot Sale',
  form: BCRibbonForm.corner,
  cornerOffset: 0,                    // 0 fills the corner; larger floats the band inward
  position: BCRibbonPosition.topEnd,
  color: BCRibbonColor.danger,
  child: ProductCard(),
);

// Ribbons nest, so a card can carry more than one.
BCRibbon.label(
  'Best deal',
  form: BCRibbonForm.corner,
  position: BCRibbonPosition.topEnd,
  child: BCRibbon(
    label: const Text('Nearby'),
    variant: BCRibbonVariant.outline,
    color: BCRibbonColor.success,
    startContent: const Icon(Icons.near_me),
    child: ProductCard(),
  ),
);

// Standalone, for a Stack you already have.
const BCRibbon(label: Text('-30%'), form: BCRibbonForm.bookmark);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `label` | `Widget` | required |  |
| `form` | `BCRibbonForm` | `BCRibbonForm.tag` |  |
| `variant` | `BCRibbonVariant` | `BCRibbonVariant.solid` |  |
| `color` | `BCRibbonColor` | `BCRibbonColor.accent` |  |
| `size` | `BCRibbonSize` | `BCRibbonSize.md` |  |
| `position` | `BCRibbonPosition` | `BCRibbonPosition.topStart` |  |
| `startContent` | `Widget?` | — | Small leading icon, tinted to match the label. |
| `inset` | `double?` | — | Distance from the card edges. Defaults to 8/10/12 by `size`, and is ignored by `BCRibbonForm.corner` and `BCRibbonForm.banner`, which sit flush against the edges. |
| `cornerOffset` | `double?` | — | `BCRibbonForm.corner` only: gap between the card's corner and the near edge of the band.  Defaults to whatever keeps the band clear of the corner while still long enough for the label. Pass `0` to fill the corner completely, or a larger value to float the band further down the card. |
| `cornerThickness` | `double?` | — | `BCRibbonForm.corner` only: thickness of the band.  Defaults to the label's height plus padding — and, when `cornerOffset` pulls the band toward the corner where there is less room, to whatever the label needs to fit. |
| `borderRadius` | `double?` | — | Corner radius the ribbon is clipped to, i.e. the radius of the card it covers. Defaults to `BCRadius.xxxl` (24), matching `BCSurface`. |
| `child` | `Widget?` | — | The card the ribbon is laid over. Without one the ribbon sizes itself. |

**`BCRibbonForm`** — `tag`, `flag`, `corner`, `banner`, `bookmark`

**`BCRibbonVariant`** — `solid`, `soft`, `outline`

**`BCRibbonColor`** — `accent`, `defaultColor`, `success`, `warning`, `danger`

**`BCRibbonSize`** — `sm`, `md`, `lg`

**`BCRibbonPosition`** — `topStart`, `topEnd`, `bottomStart`, `bottomEnd`

### BCTagGroup

Wrapping list of selectable/removable tags.

```dart
BCTagGroup<String>(
  selectionMode: BCTagGroupSelectionMode.multiple,
  selectedValues: selected,
  onSelectionChange: (values) => setState(() => selected = values),
  items: const [
    BCTagItem(value: 'design', label: 'Design'),
    BCTagItem(value: 'code', label: 'Code'),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `items` | `List<BCTagItem<T>>` | required |  |
| `selectionMode` | `BCTagGroupSelectionMode` | `BCTagGroupSelectionMode.single` |  |
| `selectedValues` | `Set<T>` | `const {}` |  |
| `onSelectionChange` | `ValueChanged<Set<T>>?` | — |  |
| `onRemove` | `ValueChanged<T>?` | — | When provided, tags render a remove button. |
| `variant` | `BCTagVariant` | `BCTagVariant.defaultVariant` |  |
| `size` | `BCTagSize` | `BCTagSize.md` |  |
| `isDisabled` | `bool` | `false` |  |

**`BCTagGroupSelectionMode`** — `none`, `single`, `multiple`

**`BCTagVariant`** — `defaultVariant`, `surface`

**`BCTagSize`** — `sm`, `md`, `lg`

<details><summary><code>BCTagItem</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `T` | required |  |
| `label` | `String` | required |  |

</details>

### BCSeparator

Horizontal or vertical rule.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `variant` | `BCSeparatorVariant` | `BCSeparatorVariant.thin` |  |
| `orientation` | `BCSeparatorOrientation` | `BCSeparatorOrientation.horizontal` |  |
| `thickness` | `double?` | — |  |
| `color` | `Color?` | — |  |
| `margin` | `EdgeInsetsGeometry?` | — |  |

**`BCSeparatorVariant`** — `thin`, `thick`

**`BCSeparatorOrientation`** — `horizontal`, `vertical`

### BCSkeleton

Loading placeholder with shimmer or pulse.

```dart
BCSkeletonGroup(
  isLoading: loading,
  child: Column(
    children: const [
      BCSkeleton(width: 180, height: 20),
      SizedBox(height: 8),
      BCSkeleton(width: 240, height: 20),
    ],
  ),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget?` | — |  |
| `isLoading` | `bool` | `true` |  |
| `variant` | `BCSkeletonVariant` | `BCSkeletonVariant.shimmer` |  |
| `animation` | `BCSkeletonAnimation?` | — |  |
| `isAnimatedStyleActive` | `bool` | `true` |  |
| `width` | `double?` | — |  |
| `height` | `double?` | — |  |
| `borderRadius` | `BorderRadius?` | — |  |
| `decoration` | `BoxDecoration?` | — |  |

**`BCSkeletonVariant`** — `shimmer`, `pulse`, `none`

<details><summary><code>BCSkeletonGroup</code></summary>

HeroUI Native SkeletonGroup: cascades `isLoading`, `variant`, and `animation` to descendant `BCSkeleton`s via an inherited scope (skeleton-group.tsx passes the same values through context).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `isLoading` | `bool` | required |  |
| `variant` | `BCSkeletonVariant` | `BCSkeletonVariant.shimmer` |  |
| `animation` | `BCSkeletonAnimation?` | — |  |
| `child` | `Widget` | required |  |

**`BCSkeletonVariant`** — `shimmer`, `pulse`, `none`

</details>

<details><summary><code>BCSkeletonAnimation</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `shimmer` | `BCSkeletonShimmerAnimation?` | — |  |
| `pulse` | `BCSkeletonPulseAnimation?` | — |  |
| `enteringDuration` | `Duration?` | — |  |
| `exitingDuration` | `Duration?` | — |  |
| `disableAll` | `bool` | `false` |  |

</details>

<details><summary><code>BCSkeletonShimmerAnimation</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `duration` | `Duration?` | — |  |
| `speed` | `double?` | — |  |
| `highlightColor` | `Color?` | — |  |
| `curve` | `Curve?` | — |  |
| `disabled` | `bool` | `false` |  |

</details>

<details><summary><code>BCSkeletonPulseAnimation</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `duration` | `Duration?` | — |  |
| `minOpacity` | `double?` | — |  |
| `maxOpacity` | `double?` | — |  |
| `curve` | `Curve?` | — |  |
| `disabled` | `bool` | `false` |  |

</details>

### BCSpinner

Indeterminate loading indicator.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `size` | `BCSpinnerSize` | `BCSpinnerSize.md` |  |
| `color` | `BCSpinnerColor` | `BCSpinnerColor.defaultColor` |  |
| `customColor` | `Color?` | — | Overrides `color` with an arbitrary color. |
| `isLoading` | `bool` | `true` | When false the spinner fades out (200ms in / 100ms out). |

**`BCSpinnerSize`** — `sm`, `md`, `lg`

**`BCSpinnerColor`** — `defaultColor`, `success`, `warning`, `danger`

### BCProgress

Determinate and indeterminate progress, linear or circular, with an optional label and percentage. Determinate changes ease into place instead of snapping.

```dart
BCProgress(value: 0.4, label: 'Uploading', showValueLabel: true);

// Indeterminate until you know the total.
const BCProgress(variant: BCProgressVariant.circular);

BCProgress(
  value: bytes / total,
  size: BCProgressSize.lg,
  color: BCProgressColor.success,
  formatValue: (v) => '${(v * total / 1e6).round()} MB',
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `double?` | — | Progress in the 0–1 range, or null for indeterminate. |
| `variant` | `BCProgressVariant` | `BCProgressVariant.linear` |  |
| `size` | `BCProgressSize` | `BCProgressSize.md` |  |
| `color` | `BCProgressColor` | `BCProgressColor.accent` |  |
| `label` | `String?` | — | Caption above a linear bar / below a circular one. |
| `showValueLabel` | `bool` | `false` | Shows the percentage next to `label`. Ignored while indeterminate. |
| `formatValue` | `String Function(double value)?` | — | Defaults to whole percent, e.g. `40%`. |
| `trackColor` | `Color?` | — | Defaults to the `default` token. |
| `valueColor` | `Color?` | — | Overrides `color`. |
| `thickness` | `double?` | — | Bar height / ring stroke width. Defaults per `size`. |

**`BCProgressVariant`** — `linear`, `circular`

**`BCProgressSize`** — `sm`, `md`, `lg`

**`BCProgressColor`** — `accent`, `success`, `warning`, `danger`, `foreground`

### BCLoadingOverlay

Covers a page or section while work is in flight: fades in a dim or blurred backdrop, blocks input underneath, and centers an indicator with an optional label.

```dart
BCLoadingOverlay(
  isLoading: _saving,
  label: 'Saving changes',
  backdrop: BCLoadingBackdrop.blur,
  child: ProfileForm(),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `isLoading` | `bool` | required |  |
| `child` | `Widget` | required |  |
| `label` | `String?` | — | Caption under the indicator. With a label the indicator sits on a surface card; without one it floats bare. |
| `backdrop` | `BCLoadingBackdrop` | `BCLoadingBackdrop.dim` |  |
| `indicator` | `Widget?` | — | Defaults to a large `BCSpinner`. |
| `blurSigma` | `double` | `6` | Blur strength for `BCLoadingBackdrop.blur`. |
| `blockInput` | `bool` | `true` | Swallows pointer events aimed at `child` while loading. |
| `semanticLabel` | `String` | `'Loading'` |  |

**`BCLoadingBackdrop`** — `dim`, `blur`, `none`

### BCRating

Star rating, read-only or interactive, with optional halves.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `double` | required |  |
| `max` | `int` | `5` |  |
| `onChanged` | `ValueChanged<double>?` | — | Tap handler; when null the rating is read-only. |
| `size` | `BCRatingSize` | `BCRatingSize.md` |  |
| `itemSize` | `double?` | — | Overrides the `size` preset. |
| `spacing` | `double` | `4` |  |
| `color` | `Color?` | — | Filled color. Defaults to the warning (amber) token. |
| `emptyColor` | `Color?` | — | Unfilled color. Defaults to a muted translucent tint. |
| `icon` | `IconData` | `Icons.star_rounded` |  |
| `allowHalf` | `bool` | `false` | Allow half-value selection when interactive. |

**`BCRatingSize`** — `sm`, `md`, `lg`

### BCEmptyState

Empty/zero-state block: icon or illustration, title, description and actions.

```dart
BCEmptyState(
  icon: const Icon(Icons.inbox_outlined),
  title: 'No messages',
  description: 'When someone writes to you it will show up here.',
  actions: [BCButton(onPressed: () {}, child: const Text('Refresh'))],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `icon` | `Widget?` | — | Icon shown inside a muted circular badge. Ignored when `illustration` is provided. |
| `illustration` | `Widget?` | — | Fully custom visual shown above the title, replacing the `icon` badge. |
| `title` | `String` | required |  |
| `description` | `String?` | — |  |
| `actions` | `List<Widget>` | `const []` | Buttons stacked (full-width) below the text, in order. |
| `variant` | `BCEmptyStateVariant` | `BCEmptyStateVariant.plain` |  |
| `padding` | `EdgeInsetsGeometry?` | — | Content padding. Defaults to `EdgeInsets.all(32)` for `outline`, none otherwise. |
| `maxContentWidth` | `double` | `400` | Caps the content width so text and full-width buttons stay tidy on wide screens. |

**`BCEmptyStateVariant`** — `plain`, `outline`

<details><summary><code>BCEmptyStateAvatarCluster</code></summary>

Helper for a HeroUI-style overlapping avatar-group illustration, matching the "With avatar group" empty-state design. Purely decorative.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `size` | `double` | `64` |  |
| `overlap` | `double` | `24` |  |

</details>

---

## Forms

### BCInput

Single-line text input primitive.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `controller` | `TextEditingController?` | — |  |
| `focusNode` | `FocusNode?` | — |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `placeholder` | `String?` | — |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `obscureText` | `bool` | `false` |  |
| `readOnly` | `bool` | `false` |  |
| `autofocus` | `bool` | `false` |  |
| `maxLines` | `int?` | `1` |  |
| `minLines` | `int?` | — |  |
| `minHeight` | `double` | `48` |  |
| `verticalPadding` | `double?` | — | Vertical padding inside the field; used by multiline fields (TextArea uses 8). |
| `contentPadding` | `EdgeInsetsGeometry?` | — | Overrides the default `EdgeInsets.symmetric(horizontal: 12)`. |
| `keyboardType` | `TextInputType?` | — |  |
| `textInputAction` | `TextInputAction?` | — |  |
| `inputFormatters` | `List<TextInputFormatter>?` | — |  |
| `onChanged` | `ValueChanged<String>?` | — |  |
| `onSubmitted` | `ValueChanged<String>?` | — |  |
| `onTap` | `VoidCallback?` | — |  |
| `textCapitalization` | `TextCapitalization` | `TextCapitalization.none` |  |
| `autocorrect` | `bool` | `true` |  |
| `enableSuggestions` | `bool` | `true` |  |
| `autofillHints` | `Iterable<String>?` | — | What the OS should offer to fill in — `AutofillHints.email`, `AutofillHints.telephoneNumberNational`, and so on. Without it the keychain and iOS's one-tap SMS code are unavailable. |
| `prefix` | `Widget?` | — |  |
| `suffix` | `Widget?` | — |  |

**`BCInputVariant`** — `primary`, `secondary`, `plain`

### BCTextField

Compound field: label, input, description and error, wired together for validation state.

```dart
BCTextField(
  isRequired: true,
  isInvalid: emailError != null,
  children: [
    const BCTextFieldLabel('Email'),
    const BCTextFieldInput(hintText: 'you@example.com'),
    if (emailError == null)
      const BCTextFieldDescription("We'll never share your email.")
    else
      BCTextFieldError(emailError!),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `children` | `List<Widget>` | required |  |
| `isDisabled` | `bool` | `false` |  |
| `isInvalid` | `bool` | `false` |  |
| `isRequired` | `bool` | `false` |  |

<details><summary><code>BCTextFieldLabel</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |
| `isInvalid` | `bool?` | — |  |

</details>

<details><summary><code>BCTextFieldInput</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `controller` | `TextEditingController?` | — |  |
| `focusNode` | `FocusNode?` | — |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `isInvalid` | `bool?` | — |  |
| `isDisabled` | `bool?` | — |  |
| `hintText` | `String?` | — |  |
| `prefix` | `Widget?` | — |  |
| `suffix` | `Widget?` | — |  |
| `obscureText` | `bool` | `false` |  |
| `readOnly` | `bool` | `false` |  |
| `autofocus` | `bool` | `false` |  |
| `maxLines` | `int` | `1` |  |
| `minLines` | `int?` | — |  |
| `keyboardType` | `TextInputType?` | — |  |
| `textInputAction` | `TextInputAction?` | — |  |
| `inputFormatters` | `List<TextInputFormatter>?` | — |  |
| `onChanged` | `ValueChanged<String>?` | — |  |
| `onSubmitted` | `ValueChanged<String>?` | — |  |
| `onTap` | `VoidCallback?` | — |  |
| `textCapitalization` | `TextCapitalization` | `TextCapitalization.none` |  |
| `autocorrect` | `bool` | `true` |  |
| `enableSuggestions` | `bool` | `true` |  |

**`BCInputVariant`** — `primary`, `secondary`, `plain`

</details>

<details><summary><code>BCTextFieldDescription</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCTextFieldError</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `message` | `String` | required | First positional argument. |

</details>

### BCTextArea

Multi-line input.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `controller` | `TextEditingController?` | — |  |
| `focusNode` | `FocusNode?` | — |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `placeholder` | `String?` | — |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `height` | `double` | `128` |  |
| `keyboardType` | `TextInputType?` | — |  |
| `inputFormatters` | `List<TextInputFormatter>?` | — |  |
| `onChanged` | `ValueChanged<String>?` | — |  |
| `onSubmitted` | `ValueChanged<String>?` | — |  |
| `textCapitalization` | `TextCapitalization` | `TextCapitalization.none` |  |

**`BCInputVariant`** — `primary`, `secondary`, `plain`

### BCPasswordInput

Input with a reveal toggle.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `controller` | `TextEditingController?` | — |  |
| `focusNode` | `FocusNode?` | — |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `placeholder` | `String?` | — |  |
| `prefix` | `Widget?` | — | A leading widget shown before the text, mirroring `BCInput.prefix`. The trailing slot is taken by the visibility toggle. |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `onChanged` | `ValueChanged<String>?` | — |  |
| `onSubmitted` | `ValueChanged<String>?` | — |  |
| `textInputAction` | `TextInputAction?` | — |  |

**`BCInputVariant`** — `primary`, `secondary`, `plain`

### BCSearchField

Input with a search icon and a clear button.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `controller` | `TextEditingController?` | — |  |
| `focusNode` | `FocusNode?` | — |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `placeholder` | `String?` | — |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `onChanged` | `ValueChanged<String>?` | — |  |
| `onSubmitted` | `ValueChanged<String>?` | — |  |
| `onClear` | `VoidCallback?` | — |  |

**`BCInputVariant`** — `primary`, `secondary`, `plain`

### BCInputOTP

One-time-code field composed of slots, with a caret and separators.

```dart
BCInputOTP(
  maxLength: 6,
  onCompleted: (code) => verify(code),
  child: BCInputOTPGroup(
    children: [
      for (var i = 0; i < 6; i++) ...[
        BCInputOTPSlot(index: i),
        if (i == 2) const BCInputOTPSeparator(),
      ],
    ],
  ),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `maxLength` | `int` | required |  |
| `child` | `Widget` | required |  |
| `value` | `String?` | — |  |
| `onChanged` | `ValueChanged<String>?` | — |  |
| `onCompleted` | `ValueChanged<String>?` | — |  |
| `controller` | `TextEditingController?` | — |  |
| `focusNode` | `FocusNode?` | — |  |
| `isDisabled` | `bool` | `false` |  |
| `isInvalid` | `bool` | `false` |  |
| `variant` | `BCInputOTPVariant` | `BCInputOTPVariant.primary` |  |
| `keyboardType` | `TextInputType` | `TextInputType.number` |  |
| `inputFormatters` | `List<TextInputFormatter>?` | — |  |
| `placeholder` | `String?` | — |  |
| `autofocus` | `bool` | `false` |  |
| `onFocus` | `VoidCallback?` | — |  |
| `onBlur` | `VoidCallback?` | — |  |

**`BCInputOTPVariant`** — `primary`, `secondary`

<details><summary><code>BCInputOTPGroup</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `children` | `List<Widget>` | required |  |

</details>

<details><summary><code>BCInputOTPSlot</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `index` | `int` | required |  |
| `variant` | `BCInputOTPVariant?` | — |  |
| `child` | `Widget?` | — |  |

**`BCInputOTPVariant`** — `primary`, `secondary`

</details>

<details><summary><code>BCInputOTPSlotPlaceholder</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `String?` | — |  |

</details>

<details><summary><code>BCInputOTPSlotValue</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `String?` | — |  |

</details>

<details><summary><code>BCInputOTPSlotCaret</code></summary>

</details>

<details><summary><code>BCInputOTPSeparator</code></summary>

</details>

### BCDateField

Read-only field that opens a calendar in a dialog, a popover or a bottom sheet (`presentation`). Months change by swiping the grid or with the header arrows.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `DateTime?` | — |  |
| `onChanged` | `ValueChanged<DateTime>?` | — |  |
| `firstDate` | `DateTime?` | — | Earliest selectable date. Defaults to Jan 1, 100 years ago. |
| `lastDate` | `DateTime?` | — | Latest selectable date. Defaults to Dec 31, 100 years ahead. |
| `placeholder` | `String` | `'Select a date'` |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `formatDate` | `String Function(DateTime date)?` | — | Formats the selected value for display. Defaults to `MMMM d, y` (e.g. "July 26, 2026"). |
| `presentation` | `BCPickerPresentation` | `BCPickerPresentation.dialog` | Where the calendar appears: a dialog (default), a popover anchored to the field, or a bottom sheet. Selecting a day commits and closes in all three. |
| `icon` | `Widget` | `const Icon(Icons.calendar_today_outlined)` | Trailing icon; defaults to a calendar glyph. |

**`BCInputVariant`** — `primary`, `secondary`, `plain`

**`BCPickerPresentation`** — `popover`, `dialog`, `bottomSheet`

<details><summary><code>BCDatePickerDialog</code></summary>

The calendar in a modal dialog. Kept as a standalone entry point: `final date = await BCDatePickerDialog.show(context, ...);`

| Prop | Type | Default | Notes |
|---|---|---|---|
| `initialDate` | `DateTime?` | — |  |
| `firstDate` | `DateTime` | required |  |
| `lastDate` | `DateTime` | required |  |

</details>

<details><summary><code>BCCalendar</code></summary>

A month calendar: header with a month/year toggle and arrows, weekday row, and a swipeable grid of days.  This is the panel behind `BCDateField` in every presentation; use it directly to embed a calendar in a form or a sheet of your own.  Months are pages: swipe the grid horizontally to move between them, or use the header arrows, which animate the same pager. The grid is always six week-rows tall so the surface keeps a constant height.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `initialDate` | `DateTime?` | — | Month to open on. Defaults to `selectedDate`, else today. |
| `selectedDate` | `DateTime?` | — | Day drawn as selected. |
| `firstDate` | `DateTime` | required |  |
| `lastDate` | `DateTime` | required |  |
| `onDateSelected` | `ValueChanged<DateTime>` | required |  |

</details>

### BCTimeField

Read-only field that opens the hour/minute wheels in a dialog, a popover or a bottom sheet (`presentation`). The dialog commits on Confirm; popover and sheet apply each spin live.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `TimeOfDay?` | — |  |
| `onChanged` | `ValueChanged<TimeOfDay>?` | — |  |
| `placeholder` | `String` | `'Select a time'` |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `use24HourFormat` | `bool` | `false` | 24-hour wheel (no AM/PM) when true; 12-hour with AM/PM otherwise. |
| `minuteStep` | `int` | `1` | Minute increment shown on the wheel (e.g. 5 → 00, 05, 10 …). |
| `formatTime` | `String Function(TimeOfDay time)?` | — | Formats the selected value for display. Defaults to `h:mm AM/PM` (or `HH:mm` in 24-hour mode). |
| `presentation` | `BCPickerPresentation` | `BCPickerPresentation.dialog` | Where the wheels appear: a dialog with Cancel / Confirm (default), a popover anchored to the field, or a bottom sheet. Popover and sheet apply each spin live. |
| `icon` | `Widget` | `const Icon(Icons.access_time)` | Trailing icon; defaults to a clock glyph. |

**`BCInputVariant`** — `primary`, `secondary`, `plain`

**`BCPickerPresentation`** — `popover`, `dialog`, `bottomSheet`

<details><summary><code>BCTimePickerDialog</code></summary>

The time wheels in a modal dialog, with Cancel / Confirm. Kept as a standalone entry point: `final time = await BCTimePickerDialog.show(context, ...);`

| Prop | Type | Default | Notes |
|---|---|---|---|
| `initialTime` | `TimeOfDay?` | — |  |
| `use24HourFormat` | `bool` | `false` |  |
| `minuteStep` | `int` | `1` |  |

</details>

<details><summary><code>BCTimeWheel</code></summary>

Hour / minute (and AM/PM) scroll wheels.  This is the panel behind `BCTimeField` in every presentation; use it directly to embed time selection in a form or a sheet of your own.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `initialTime` | `TimeOfDay?` | — |  |
| `use24HourFormat` | `bool` | `false` |  |
| `minuteStep` | `int` | `1` | Minute increment shown on the wheel (e.g. 5 → 00, 05, 10 …). |
| `onChanged` | `ValueChanged<TimeOfDay>` | required | Fires as each wheel settles. |

</details>

### BCDateTimePicker

Date **and** time in one field: day, hour, minute (and AM/PM) wheels presented in a popover, a dialog or a bottom sheet, with built-in label, description and error slots.

```dart
BCDateTimePicker(
  label: 'Reminder',
  isRequired: true,
  description: 'Required to schedule the notification.',
  value: _reminder,
  onChanged: (value) => setState(() => _reminder = value),
);

// 24-hour wheels stepping in 5 minutes, shown as a bottom sheet.
BCDateTimePicker(
  presentation: BCDateTimePickerPresentation.bottomSheet,
  use24HourFormat: true,
  minuteInterval: 5,
  value: _departure,
  onChanged: (value) => setState(() => _departure = value),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `DateTime?` | — |  |
| `onChanged` | `ValueChanged<DateTime>?` | — |  |
| `firstDate` | `DateTime?` | — | Earliest selectable moment. Defaults to the start of today. |
| `lastDate` | `DateTime?` | — | Latest selectable moment. Defaults to five years out. |
| `presentation` | `BCPickerPresentation` | `BCPickerPresentation.popover` | Popover and bottom sheet apply each spin immediately; the dialog waits for Confirm. |
| `use24HourFormat` | `bool` | `false` |  |
| `minuteInterval` | `int` | `1` | Minute step, e.g. 5 for `00, 05, 10 …`. |
| `placeholder` | `String` | `'Choose a date & time'` |  |
| `label` | `String?` | — | Rendered above the field with `BCLabel`. |
| `description` | `String?` | — | Muted helper text under the field. Replaced by `errorText` when set. |
| `errorText` | `String?` | — | Error message under the field; also forces the invalid styling. |
| `isRequired` | `bool` | `false` |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `formatDateTime` | `String Function(DateTime value)?` | — | Formats the value in the field. Defaults to `Jul 26, 2026, 9:00 AM` (or 24-hour when `use24HourFormat`). |
| `formatDay` | `String Function(DateTime day)?` | — | Day column label inside the wheels. See `BCDateTimeWheel.formatDay`. |
| `icon` | `Widget` | `const Icon(Icons.calendar_today_outlined)` |  |
| `wheelHeight` | `double` | `220` |  |

**`BCPickerPresentation`** — `popover`, `dialog`, `bottomSheet`

**`BCInputVariant`** — `primary`, `secondary`, `plain`

<details><summary><code>BCDateTimeWheel</code></summary>

Scrolling day + time wheels, in the style of iOS pickers but built from bc_ui tokens.  This is the panel behind `BCDateTimePicker`; use it directly to embed the wheels in a form or a sheet of your own.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `DateTime` | required |  |
| `onChanged` | `ValueChanged<DateTime>` | required |  |
| `firstDate` | `DateTime` | required |  |
| `lastDate` | `DateTime` | required |  |
| `use24HourFormat` | `bool` | `false` | 24-hour wheels drop the AM/PM column and show `00`–`23`. |
| `minuteInterval` | `int` | `1` | Minute step, e.g. 5 for `00, 05, 10 …`. |
| `formatDay` | `String Function(DateTime day)?` | — | Day column label. Defaults to `Today` for the current date and `Wed, Jul 29` otherwise. |
| `height` | `double` | `220` |  |

</details>

### BCDateTimeWheel

The wheels behind `BCDateTimePicker`, usable on their own to embed day/time selection in a form or a sheet of your own.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `DateTime` | required |  |
| `onChanged` | `ValueChanged<DateTime>` | required |  |
| `firstDate` | `DateTime` | required |  |
| `lastDate` | `DateTime` | required |  |
| `use24HourFormat` | `bool` | `false` | 24-hour wheels drop the AM/PM column and show `00`–`23`. |
| `minuteInterval` | `int` | `1` | Minute step, e.g. 5 for `00, 05, 10 …`. |
| `formatDay` | `String Function(DateTime day)?` | — | Day column label. Defaults to `Today` for the current date and `Wed, Jul 29` otherwise. |
| `height` | `double` | `220` |  |

### BCCalendar

The month calendar behind `BCDateField`: header, weekday row and a swipeable six-row day grid. Usable on its own.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `initialDate` | `DateTime?` | — | Month to open on. Defaults to `selectedDate`, else today. |
| `selectedDate` | `DateTime?` | — | Day drawn as selected. |
| `firstDate` | `DateTime` | required |  |
| `lastDate` | `DateTime` | required |  |
| `onDateSelected` | `ValueChanged<DateTime>` | required |  |

### BCTimeWheel

The hour / minute (and AM/PM) wheels behind `BCTimeField`. Usable on its own.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `initialTime` | `TimeOfDay?` | — |  |
| `use24HourFormat` | `bool` | `false` |  |
| `minuteStep` | `int` | `1` | Minute increment shown on the wheel (e.g. 5 → 00, 05, 10 …). |
| `onChanged` | `ValueChanged<TimeOfDay>` | required | Fires as each wheel settles. |

### BCPhoneField

International phone input: a tappable flag and dial code in the field's prefix opening a searchable country list, and a number that groups itself as you type. Leave `initialCountry` null and it opens on the device's own region, the way a web form reads `navigator.language`. Validation is libPhoneNumber's, not a regex — it knows each country's real lengths and prefixes, so `+1 555 000 0000` comes back invalid. Nothing is blocked while you type; `onChanged` reports a `BCPhoneNumber` with `isValid` on every keystroke and the message waits for blur. The trunk prefix is dropped as you type, because it is not part of an international number.

```dart
// No initialCountry: opens on the device's own region,
// falling back to fallbackCountry when it reports none.
BCPhoneField(
  label: 'Mobile',
  fallbackCountry: IsoCode.BD,
  onChanged: (value) => setState(() => _phone = value),
);

BCPhoneField(
  label: 'Mobile',
  isRequired: true,
  initialCountry: IsoCode.BD,
  // The two or three countries your users actually live in, pinned on top.
  preferredCountries: const [IsoCode.BD, IsoCode.GB, IsoCode.US],
  onChanged: (value) => setState(() => _phone = value),
  onValidityChanged: (valid) => setState(() => _canSubmit = valid),
);

// _phone.e164        -> '+8801712345678', what you send to a server
// _phone.national    -> '1712-345678', what the field shows
// _phone.isoCode     -> IsoCode.BD, whatever the picker says
// _phone.isValid     -> checked against libPhoneNumber's metadata

// Restrict the list, and let the caller name the countries.
BCPhoneField(
  countries: const [IsoCode.BD, IsoCode.IN, IsoCode.PK],
  formatCountryName: (isoCode, name) => isoCode == IsoCode.US ? 'USA' : name,
);

// inline: a row of an iOS grouped form rather than a boxed field. The
// section draws the background and the hairlines, so the field draws
// neither, the label moves beside the number, and the row is padded the
// (20, 6, 6, 6) a native CupertinoFormRow uses -- so the two line up.
// Drop it straight into the section; do not wrap it in a form row as well.
CupertinoFormSection.insetGrouped(
  header: const Text('CONTACT'),
  children: [
    CupertinoTextFormFieldRow(prefix: const Text('Name')),
    BCPhoneField(
      label: 'Mobile',
      inline: true,
      initialCountry: IsoCode.BD,
      onChanged: (value) => setState(() => _phone = value),
    ),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `initialValue` | `BCPhoneNumber?` | — | Seeds the field. Its `BCPhoneNumber.isoCode` wins over `initialCountry`.  Read the value back through `onChanged` — like every other text input in the library this field is uncontrolled, because rebuilding it with re-grouped text would move the caret out from under the user. |
| `onChanged` | `ValueChanged<BCPhoneNumber>?` | — | Fires on every keystroke and on every country change, with validity already computed. |
| `onValidityChanged` | `ValueChanged<bool>?` | — | Fires only when validity flips, so a submit button can be driven straight from it without mirroring state. |
| `onSubmitted` | `ValueChanged<BCPhoneNumber>?` | — | The keyboard's action key. |
| `initialCountry` | `IsoCode?` | — | Country the field opens on. Ignored when `initialValue` is set.  Null — the default — reads the device's region, so a phone set to Bangladesh opens on Bangladesh. Resolved once when the field is created; changing the device region later does not move a field already on screen. |
| `fallbackCountry` | `IsoCode` | `IsoCode.US` | Used when `initialCountry` is null and the device reports no region the parser recognises — a bare `en` locale, or a UN M.49 region like `es_419`. |
| `onCountryChanged` | `ValueChanged<IsoCode>?` | — | Fires when a country is picked, and when pasting an international number changes it. |
| `countries` | `List<IsoCode>?` | — | Restricts and orders the picker. Null — or an empty list — offers every country `phone_numbers_parser` knows, sorted by name. |
| `preferredCountries` | `List<IsoCode>` | `const <IsoCode>[]` | Pinned above the rest, in the order given — the two or three countries your users actually live in. |
| `countryPresentation` | `BCSelectPresentation` | `BCSelectPresentation.bottomSheet` | How the country list opens. The sheet is the default: it has room for 245 rows and it lifts the search field clear of the keyboard. |
| `countryListLabel` | `String` | `'Select a country'` | Title above the country list, and the sheet's header. |
| `countrySearchPlaceholder` | `String` | `'Search'` |  |
| `formatCountryName` | `String Function(IsoCode isoCode, String defaultName)?` | — | Renames countries — your own localisation, or 'United States' shortened to 'USA'. Defaults are the English ISO 3166-1 short forms. |
| `label` | `String?` | — | Rendered above the field. |
| `description` | `String?` | — | Muted helper text under the field. Replaced by the error when there is one. |
| `errorText` | `String?` | — | Your error — from a server, say. Always beats the field's own `invalidNumberText`, and forces the invalid styling on its own. |
| `invalidNumberText` | `String?` | `'Enter a valid phone number'` | Shown under the field when a non-empty number fails validation and focus leaves. Set it to null to keep the field silent and report validity only through `onChanged`. |
| `placeholder` | `String?` | — | Defaults to an example number for the selected country, so the shape expected is visible before anything is typed. |
| `isRequired` | `bool` | `false` |  |
| `isInvalid` | `bool` | `false` | Forces the invalid ring without a message, the way every other bc_ui field takes it. |
| `isDisabled` | `bool` | `false` |  |
| `variant` | `BCInputVariant` | `BCInputVariant.primary` |  |
| `inline` | `bool` | `false` | Lays the field out as a row of an iOS grouped form: no box, no shadow, no focus ring, and the label beside the number rather than above it.  Made to be dropped straight into a `CupertinoFormSection`'s children. The section draws the row background and the hairlines between rows, so the field must not draw its own; the row padding is the (20, 6, 6, 6) SwiftUI's `Form` uses, which is what `CupertinoFormRow` uses too, so this field and the native rows beside it line up. Do not wrap it in a `CupertinoFormRow` as well — you would get that padding twice.  `variant` is ignored while this is on, and the country button drops its divider: that hairline marks the edge of a box, and a form row has none.  ```dart CupertinoFormSection.insetGrouped( header: const Text('CONTACT'), children: ` CupertinoTextFormFieldRow(prefix: const Text('Name')), BCPhoneField( label: 'Mobile', inline: true, initialCountry: IsoCode.BD, onChanged: (value) => setState(() => _phone = value), ), `, ) ``` |
| `controller` | `TextEditingController?` | — | Holds the *formatted national part* — `(201) 555-0123`, never the dial code. Create and dispose it yourself; the field only reads and rewrites it. Use `onChanged` for the number you send to a server. |
| `focusNode` | `FocusNode?` | — | Focus for the number, not for the country button. Blur on this node is what surfaces the validation message. |
| `textInputAction` | `TextInputAction?` | — |  |
| `autofocus` | `bool` | `false` |  |

- `static IsoCode? deviceCountry()` — The device's configured region — `en_GB` gives `IsoCode.GB`, and null when no preferred locale carries one the parser knows. What `initialCountry` uses when you leave it null. This is the phone's configured region, not where it physically is.
- `static String flagEmoji(IsoCode isoCode)` — The flag as a regional-indicator emoji pair — `IsoCode.BD` becomes 🇧🇩.

**`BCSelectPresentation`** — `popover`, `bottomSheet`, `wheel`

**`BCInputVariant`** — `primary`, `secondary`, `plain`

<details><summary><code>BCPhoneNumber</code></summary>

A phone number as a country plus a national significant number.  The `nsn` is always in its international form: digits only, no trunk prefix (a UK number is `7400123456`, not `07400123456`) and no dial code.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `isoCode` | `IsoCode` | required | The country this number belongs to.  Authoritative, and deliberately so: `+1` covers 25 countries and no parser can tell a US number from a Canadian one. Whatever the picker says wins. |
| `nsn` | `String` | required | National significant number — digits only. |

- `const BCPhoneNumber({required IsoCode isoCode, required String nsn})` — The `nsn` is the national significant number in international form — digits only, no trunk prefix, no dial code.
- `factory BCPhoneNumber.parse(String text, {IsoCode? country})` — Reads a number in any shape and never throws; an unreadable string comes back as the digits it could salvage under `country` (or `IsoCode.US`).
- `IsoCode isoCode` — The country. Authoritative — `+1` covers 25 countries, so the picker decides, not the parser.
- `String nsn` — National significant number, digits only.
- `String dialCode` — Without the plus — `880`.
- `String e164` — `+8801712345678`. Empty while `nsn` is.
- `String national` — Grouped the way the country writes it — `(201) 555-0123`.
- `String international` — `+880 1712-345678`.
- `bool isEmpty` — Whether `nsn` is empty.
- `bool isValid` — Length *and* pattern, against libPhoneNumber's metadata.
- `BCPhoneNumber copyWith({IsoCode? isoCode, String? nsn})` — A copy with either half replaced.

</details>

### BCSelect

Dropdown select with three presentations — an anchored popover, a bottom sheet, or a spinning wheel — plus search and pagination hooks for lists too long to scroll. `isSearchable` filters locally; `onSearch` hands the lookup to you (debounced and awaited, so it can hit the network); `onLoadMore` fires as the list nears its end. Rows take `leading`/`trailing` slots, a per-item `onTap` and `isDisabled`, or hand the whole row to `itemBuilder`. `triggerBuilder` replaces the trigger itself — pair it with `matchTriggerWidth: false` when the replacement is narrower than its list.

```dart
// The default: an anchored list under the trigger.
BCSelect<String>(
  placeholder: 'Select a country',
  items: const [
    BCSelectItem(value: 'bd', label: 'Bangladesh'),
    BCSelectItem(value: 'jp', label: 'Japan'),
  ],
  value: country,
  onValueChange: (value) => setState(() => country = value),
);

// A long list: a sheet gives it room, and search keeps it usable.
BCSelect<String>(
  presentation: BCSelectPresentation.bottomSheet,
  isSearchable: true,
  searchPlaceholder: 'Search timezones',
  listLabel: 'Timezones',
  items: timezones,
  value: zone,
  onValueChange: (value) => setState(() => zone = value),
);

// Your own lookup instead of the built-in filter — debounced, awaited,
// and free to hit the network. Pair it with onLoadMore to page.
BCSelect<String>(
  presentation: BCSelectPresentation.bottomSheet,
  items: page,
  onSearch: (query) => api.searchCities(query),
  onLoadMore: loadNextPage,
  isLoadingMore: isLoading,
  value: city,
  onValueChange: (value) => setState(() => city = value),
);

// Rows carry an avatar, a badge, their own errand.
BCSelectItem(
  value: 'ada',
  label: 'Ada Lovelace',
  description: 'Engineering',
  leading: BCAvatar.withInitials('AL', size: BCAvatarSize.small),
  trailing: BCChip.label('Owner', size: BCChipSize.sm),
  onTap: () => analytics.log('assignee_row_tapped'),
);

// Or take the row over entirely — selection is handed to you.
BCSelect<String>(
  items: tiers,
  value: tier,
  onValueChange: (value) => setState(() => tier = value),
  itemBuilder: (context, item, isSelected) => MyTierRow(
    item: item,
    isSelected: isSelected,
  ),
);

// Short and ordered? Spin it. Committed with Done.
BCSelect<int>(
  presentation: BCSelectPresentation.wheel,
  listLabel: 'Party size',
  items: [for (var i = 1; i <= 12; i++) BCSelectItem(value: i, label: '$i')],
  value: guests,
  onValueChange: (value) => setState(() => guests = value),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `items` | `List<BCSelectItem<T>>` | required |  |
| `value` | `T?` | — |  |
| `onValueChange` | `ValueChanged<T>?` | — |  |
| `placeholder` | `String` | `'Select an option'` |  |
| `listLabel` | `String?` | — | Optional label above the option list (select__list-label). Doubles as the header title in the sheet presentations. |
| `isDisabled` | `bool` | `false` |  |
| `placement` | `BCOverlayPlacement` | `BCOverlayPlacement.auto` | Where the list opens relative to the trigger. Popover only. |
| `presentation` | `BCSelectPresentation` | `BCSelectPresentation.popover` |  |
| `isSearchable` | `bool` | `false` | Shows a search field above the list, filtering `items` on label and description. Implied by `onSearch`. |
| `searchPlaceholder` | `String` | `'Search'` |  |
| `onSearch` | `Future<List<BCSelectItem<T>>> Function(String query)?` | — | Your own lookup, in place of the built-in filter — debounced by `searchDebounce` and awaited with a spinner while it runs. |
| `searchDebounce` | `Duration` | `const Duration(milliseconds: 250)` |  |
| `onLoadMore` | `VoidCallback?` | — | Called as the list scrolls within 200px of its end, once per page. Append to `items` and the list keeps going. |
| `isLoadingMore` | `bool` | `false` | Shows a spinner below the last option while a page is in flight. |
| `emptyPlaceholder` | `Widget?` | — | Shown when the list has nothing in it. Defaults to 'No results'. |
| `itemBuilder` | `Widget Function( BuildContext context, BCSelectItem<T> item, bool isSelected, )?` | — | Replaces the row layout wholesale — price columns, two-line meta, whatever the screen needs. Press feedback, the tap and the disabled state still come from the list, and `isSelected` is handed to you so the selection can be shown however you like.  Ignored by `BCSelectPresentation.wheel`, which spins labels. |
| `triggerBuilder` | `Widget Function( BuildContext context, BCSelectItem<T>? selected, bool isOpen, )?` | — | Replaces the trigger wholesale — a flag and a dial code inside a phone field, an avatar beside a name, a bare icon. The press feedback, the tap, the disabled dimming and the popover anchoring still come from the Select; `selected` is null until something is picked, and `isOpen` is handed to you so a chevron can rotate with the list.  A trigger narrower than its list wants `matchTriggerWidth` turned off. |
| `matchTriggerWidth` | `bool` | `true` | Sizes the popover list to the trigger. Turn it off when `triggerBuilder` makes the trigger narrower than its list — an 80px flag button would otherwise open an 80px-wide list with an unusable search field.  Popover only; the sheet presentations are routes and ignore it. |
| `triggerFeedback` | `BCPressFeedback` | `BCPressFeedback.scale` | Press feedback on the trigger. The scale is width-compensated, so a small `triggerBuilder` trigger pops harder than the default one — `BCPressFeedback.highlight` or `BCPressFeedback.none` suits an inline control better. |
| `maxListHeight` | `double?` | — | Cap on the popover list's height. Defaults to 280. |

**`BCOverlayPlacement`** — `bottom`, `top`, `auto`

**`BCSelectPresentation`** — `popover`, `bottomSheet`, `wheel`

**`BCPressFeedback`** — `scaleHighlight`, `scaleRipple`, `scale`, `highlight`, `material`, `none`

<details><summary><code>BCSelectItem</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `T` | required |  |
| `label` | `String` | required |  |
| `description` | `String?` | — |  |
| `leading` | `Widget?` | — | Prefix widget — an avatar, a flag, an icon. Sized by you; the row centres it against the label. |
| `trailing` | `Widget?` | — | Suffix widget — a price, a chip, a shortcut hint. Sits between the label and the selection check. |
| `onTap` | `VoidCallback?` | — | Runs when this row is picked, alongside `BCSelect.onValueChange`. Use it for the side errand a row sometimes carries: logging, prefetching, or pushing a 'manage…' route. |
| `isDisabled` | `bool` | `false` | Greys the row out and stops it being picked. |

</details>

### BCControlField

Row that pairs a control (switch, checkbox, radio) with a label and description.

```dart
BCControlField(
  label: 'Push notifications',
  description: 'Deals, order updates and reminders.',
  control: BCSwitch(isSelected: on, onSelectedChange: (v) => setState(() => on = v)),
  onPressed: () => setState(() => on = !on),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `control` | `Widget` | required |  |
| `label` | `String` | required |  |
| `description` | `String?` | — |  |
| `isDisabled` | `bool` | `false` |  |
| `controlAtEnd` | `bool` | `false` | Places the control after the text content (e.g. trailing switch rows). |
| `onPressed` | `VoidCallback?` | — | Called on tap anywhere in the field — toggle the control here. |

<details><summary><code>BCLabel</code></summary>

HeroUI Native Label: medium-weight field label with an optional required asterisk (label.css).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |
| `isRequired` | `bool` | `false` |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `isInsideField` | `bool` | `false` | Adds the horizontal padding used when the label sits inside a TextField layout. |

</details>

<details><summary><code>BCDescription</code></summary>

HeroUI Native Description: muted helper text that fades in on mount (description.css, 150ms ease-out).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `isInsideField` | `bool` | `false` |  |
| `animate` | `bool` | `true` |  |

</details>

<details><summary><code>BCFieldError</code></summary>

HeroUI Native FieldError: danger-colored validation message that fades in on mount (field-error.css, 150ms ease-out).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |
| `isInsideField` | `bool` | `false` |  |
| `animate` | `bool` | `true` |  |

</details>

---

## Selection

### BCCheckbox

Checkbox with a spring-animated indicator.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `isSelected` | `bool` | required |  |
| `onSelectedChange` | `ValueChanged<bool>?` | — |  |
| `variant` | `BCCheckboxVariant` | `BCCheckboxVariant.primary` |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |
| `icon` | `Widget?` | — | Custom indicator icon; defaults to a check. |

**`BCCheckboxVariant`** — `primary`, `secondary`

### BCRadioGroup

Radio group; wraps `BCRadio` children and owns the selected value.

```dart
BCRadioGroup<String>(
  value: plan,
  onValueChange: (value) => setState(() => plan = value),
  children: const [
    BCRadio(value: 'free', label: 'Free', description: 'For trying things out'),
    BCRadio(value: 'pro', label: 'Pro'),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `T?` | required |  |
| `onValueChange` | `ValueChanged<T>?` | required |  |
| `children` | `List<Widget>` | required |  |
| `isDisabled` | `bool` | `false` |  |
| `gap` | `double` | `16` |  |

<details><summary><code>BCRadio</code></summary>

HeroUI Native Radio (radio.css): a row with label/description content and a trailing 24px round indicator — field background when idle, accent when selected (danger when invalid), with a 10px fading thumb.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `T` | required |  |
| `label` | `String?` | — |  |
| `description` | `String?` | — |  |
| `child` | `Widget?` | — | Custom content shown instead of `label`/`description`. |
| `variant` | `BCRadioVariant` | `BCRadioVariant.primary` |  |
| `isInvalid` | `bool` | `false` |  |
| `isDisabled` | `bool` | `false` |  |

**`BCRadioVariant`** — `primary`, `secondary`

</details>

### BCSwitch

Switch with spring thumb motion and optional start/end content.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `isSelected` | `bool` | required |  |
| `onSelectedChange` | `ValueChanged<bool>?` | — |  |
| `isDisabled` | `bool` | `false` |  |
| `startContent` | `Widget?` | — | Shown inside the track near the left edge (visible when selected). |
| `endContent` | `Widget?` | — | Shown inside the track near the right edge (visible when unselected). |

### BCSlider

Slider with optional label, output readout and stepping.

```dart
BCSlider(
  value: volume,
  onChanged: (v) => setState(() => volume = v),
  label: 'Volume',
  showOutput: true,
  formatOutput: (v) => '${(v * 100).round()}%',
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `double` | required |  |
| `onChanged` | `ValueChanged<double>?` | — |  |
| `onChangeEnd` | `ValueChanged<double>?` | — |  |
| `minValue` | `double` | `0` |  |
| `maxValue` | `double` | `1` |  |
| `step` | `double?` | — |  |
| `label` | `String?` | — | Optional label shown above the track next to the output. |
| `showOutput` | `bool` | `false` | Shows the current value above the track (slider__output). |
| `formatOutput` | `String Function(double value)?` | — |  |
| `isDisabled` | `bool` | `false` |  |

### BCRangeSlider

Two-thumb slider for a start/end range — price filters, time windows, thresholds. Shares `BCSlider`'s metrics and spring.

```dart
BCRangeSlider(
  values: range,
  minValue: 0,
  maxValue: 500,
  step: 10,
  minSeparation: 50, // thumbs cannot come closer than this
  label: 'Price',
  showOutput: true,
  formatOutput: (value) => '\$${value.round()}',
  onChanged: (value) => setState(() => range = value),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `values` | `BCRange` | required |  |
| `onChanged` | `ValueChanged<BCRange>?` | — |  |
| `onChangeEnd` | `ValueChanged<BCRange>?` | — |  |
| `minValue` | `double` | `0` |  |
| `maxValue` | `double` | `1` |  |
| `step` | `double?` | — |  |
| `minSeparation` | `double?` | — | Smallest allowed gap between the thumbs. Defaults to `step`, else 0. |
| `label` | `String?` | — | Optional label shown above the track next to the output. |
| `showOutput` | `bool` | `false` | Shows the current range above the track. |
| `formatOutput` | `String Function(double value)?` | — | Formats each end of the range; the two are joined with an en dash. |
| `isDisabled` | `bool` | `false` |  |

<details><summary><code>BCRange</code></summary>

A start/end pair for `BCRangeSlider`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `start` | `double` | required | First positional argument. |
| `end` | `double` | required | Positional argument 2. |

</details>

---

## Overlays

### BCDialog

Modal dialog (static `show`, plus content/title/description parts). Built for forms as much as for confirmations: it sits above the on-screen keyboard, scrolls whatever no longer fits in the band that is left — focusing a field brings it into view rather than leaving it under the keyboard — and follows a downward swipe the way a bottom sheet does.

```dart
BCDialog.show<void>(
  context,
  builder: (context) => BCDialogContent(
    showCloseButton: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BCDialogTitle('Delete project?'),
        const BCDialogDescription('This cannot be undone.'),
        const SizedBox(height: 16),
        BCButton(
          variant: BCButtonVariant.danger,
          fullWidth: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Delete'),
        ),
      ],
    ),
  ),
);
```

- `static Future<R?> show<R>(BuildContext context, {required WidgetBuilder builder, bool barrierDismissible = true, bool isSwipeable = true})` — Presents `builder` over the themed backdrop with the scale + fade transition, above the keyboard and scrolling if it has to. `isSwipeable` gives it the drag-to-dismiss physics `BCToast` uses: the dialog tracks a downward drag 1:1, rubber-bands an upward one, and either springs back or keeps the momentum of the throw. While the content is tall enough to scroll, the scroll takes the drag.

<details><summary><code>BCDialogContent</code></summary>

Dialog surface (dialog.css): overlay background, 20px padding, 24px continuous corners, overlay shadow (1px white hairline in dark mode).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `showCloseButton` | `bool` | `false` |  |
| `width` | `double?` | — |  |

</details>

<details><summary><code>BCDialogTitle</code></summary>

Dialog title: text-lg, medium, foreground.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCDialogDescription</code></summary>

Dialog description: text-base, muted.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

### BCPopover

Anchored popover that flips and clamps to stay on screen.

```dart
BCPopover(
  trigger: (context, controller) =>
      BCButton(onPressed: controller.toggle, child: const Text('Details')),
  content: const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BCPopoverTitle('Shipping'),
      BCPopoverDescription('Arrives in 2-4 business days.'),
    ],
  ),
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `trigger` | `Widget Function( BuildContext context, BCAnchoredOverlayController controller, )` | required | Builds the trigger; call `controller.toggle()` from it. |
| `content` | `WidgetBuilder` | required |  |
| `controller` | `BCAnchoredOverlayController?` | — |  |
| `placement` | `BCOverlayPlacement` | `BCOverlayPlacement.auto` |  |
| `alignment` | `BCOverlayAlignment` | `BCOverlayAlignment.center` |  |
| `maxWidth` | `double` | `300` |  |
| `onOpenChange` | `ValueChanged<bool>?` | — |  |

**`BCOverlayPlacement`** — `bottom`, `top`, `auto`

**`BCOverlayAlignment`** — `start`, `center`, `end`

<details><summary><code>BCPopoverTitle</code></summary>

Popover title: text-lg, medium, foreground.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCPopoverDescription</code></summary>

Popover description: text-base, muted, 1.375 line-height.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCAnchoredOverlayController</code></summary>

Controller for a `BCAnchoredOverlay`.

- `BCAnchoredOverlayController()` — Create one per anchored overlay in a `State` and dispose it there. Drives `BCPopover`, `BCMenu` and `BCSelect`.
- `bool isOpen` — Whether the overlay is showing.
- `void open()` — Show the overlay.
- `void close()` — Hide it.
- `void toggle()` — The usual `onPressed` for a trigger.

</details>

### BCMenu

Anchored menu with items, labels, separators and a danger variant.

```dart
BCMenu(
  trigger: (context, controller) => BCHeaderIconButton(
    icon: const Icon(Icons.more_horiz),
    onPressed: controller.toggle,
  ),
  children: [
    const BCMenuLabel('Actions'),
    BCMenuItem(title: 'Edit', icon: const Icon(Icons.edit), onSelected: () {}),
    const BCMenuSeparator(),
    BCMenuItem(
      title: 'Delete',
      variant: BCMenuItemVariant.danger,
      onSelected: () {},
    ),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `trigger` | `Widget Function( BuildContext context, BCAnchoredOverlayController controller, )` | required |  |
| `children` | `List<Widget>` | required | Menu content: `BCMenuItem`, `BCMenuLabel`, `BCMenuSeparator`… |
| `controller` | `BCAnchoredOverlayController?` | — |  |
| `placement` | `BCOverlayPlacement` | `BCOverlayPlacement.auto` |  |
| `alignment` | `BCOverlayAlignment` | `BCOverlayAlignment.start` |  |
| `minWidth` | `double` | `200` |  |
| `maxWidth` | `double` | `320` | The menu never grows wider than this; it sizes to its content between `minWidth` and `maxWidth` rather than stretching to the screen. |
| `onOpenChange` | `ValueChanged<bool>?` | — |  |

**`BCOverlayPlacement`** — `bottom`, `top`, `auto`

**`BCOverlayAlignment`** — `start`, `center`, `end`

<details><summary><code>BCMenuItem</code></summary>

Menu row (menu.css `menu__item`): gap 10, px10/py8, radius 16, press highlight; danger variant colors the title/icon.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `title` | `String` | required |  |
| `description` | `String?` | — |  |
| `icon` | `Widget?` | — |  |
| `trailing` | `Widget?` | — |  |
| `variant` | `BCMenuItemVariant` | `BCMenuItemVariant.defaultVariant` |  |
| `isDisabled` | `bool` | `false` |  |
| `closeOnSelect` | `bool` | `true` |  |
| `onSelected` | `VoidCallback?` | — |  |

**`BCMenuItemVariant`** — `defaultVariant`, `danger`

</details>

<details><summary><code>BCMenuLabel</code></summary>

Section label (menu.css `menu__label`): text-sm, medium, muted.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCMenuSeparator</code></summary>

</details>

### BCToast

Transient message queue; `BCToastProvider` hosts it above the app. Toasts stack against the top or bottom edge (`placement`, per provider or per toast) and are swiped away toward that edge — the card tracks the finger, rubber-bands the other way, and keeps its momentum when it is thrown.

```dart
// Once, above the app. `placement` sets the edge every toast
// stacks against (heroui-native's own default is top).
MaterialApp(
  builder: (context, child) => BCToastProvider(
    placement: BCToastPlacement.top,
    child: child!,
  ),
  home: const HomeScreen(),
);

// Anywhere below it:
BCToast.show(context, const BCToastData(
  title: 'Changes saved',
  description: 'Your profile is up to date.',
  variant: BCToastVariant.success,
));

// One-off overrides: this toast comes up from the bottom and cannot
// be swiped away.
BCToast.show(context, const BCToastData(
  title: 'Uploading…',
  placement: BCToastPlacement.bottom,
  isSwipeable: false,
  showCloseButton: true,
  duration: Duration.zero,
));
```

- `static void show(BuildContext context, BCToastData data)` — Queues a toast. Requires a `BCToastProvider` above `context`.
- `static void hideAll(BuildContext context)` — Clears the queue.

<details><summary><code>BCToastData</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `title` | `String` | required |  |
| `description` | `String?` | — |  |
| `variant` | `BCToastVariant` | `BCToastVariant.defaultVariant` |  |
| `icon` | `Widget?` | — | Optional leading icon, tinted to match `variant` unless it carries its own color. |
| `actionLabel` | `String?` | — |  |
| `onAction` | `VoidCallback?` | — |  |
| `showCloseButton` | `bool` | `false` |  |
| `duration` | `Duration` | `const Duration(seconds: 4)` | Auto-dismiss delay; `Duration.zero` keeps the toast until dismissed. |
| `placement` | `BCToastPlacement?` | — | Overrides `BCToastProvider.placement` for this toast. |
| `isSwipeable` | `bool?` | — | Overrides `BCToastProvider.isSwipeable` for this toast. |

**`BCToastVariant`** — `defaultVariant`, `accent`, `success`, `warning`, `danger`

**`BCToastPlacement`** — `top`, `bottom`

</details>

<details><summary><code>BCToastProvider</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `child` | `Widget` | required |  |
| `maxVisible` | `int` | `3` | Older toasts beyond this count are dismissed immediately. |
| `placement` | `BCToastPlacement` | `BCToastPlacement.bottom` | Edge toasts stack against unless `BCToastData.placement` says otherwise.  Defaults to `BCToastPlacement.bottom`; heroui-native's own default is `top`, so pass `BCToastPlacement.top` to match it exactly. |
| `topInset` | `double` | `16` | Distance from the top safe area to a `BCToastPlacement.top` toast. |
| `bottomInset` | `double` | `16` | Distance from the bottom safe area — or from the keyboard, whenever it covers more — to a `BCToastPlacement.bottom` toast. |
| `horizontalInset` | `double` | `16` | Distance from the left and right edges. |
| `isSwipeable` | `bool` | `true` | Whether toasts can be swiped away, unless `BCToastData.isSwipeable` says otherwise. |

**`BCToastPlacement`** — `top`, `bottom`

</details>

---
