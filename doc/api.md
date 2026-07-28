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
- [Containers](#containers) — `BCSurface`, `BCCard`, `BCListGroup`, `BCFlipCard`, `BCScrollShadow`
- [Data display](#data-display) — `BCText`, `BCAvatar`, `BCChip`, `BCRibbon`, `BCTagGroup`, `BCSeparator`, `BCSkeleton`, `BCSpinner`, `BCProgress`, `BCLoadingOverlay`, `BCRating`, `BCEmptyState`
- [Forms](#forms) — `BCInput`, `BCTextField`, `BCTextArea`, `BCPasswordInput`, `BCSearchField`, `BCInputOTP`, `BCDateField`, `BCTimeField`, `BCDateTimePicker`, `BCDateTimeWheel`, `BCCalendar`, `BCTimeWheel`, `BCSelect`, `BCControlField`
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
| `filled` | `bool` | `false` | Paints a circle behind the icon, so it stays legible over photos. |
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
| `label` | `String` | — |  |

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
| `prefix` | `Widget?` | — |  |
| `suffix` | `Widget?` | — |  |

**`BCInputVariant`** — `primary`, `secondary`

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

**`BCInputVariant`** — `primary`, `secondary`

</details>

<details><summary><code>BCTextFieldDescription</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCTextFieldError</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `message` | `String` | — |  |

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

**`BCInputVariant`** — `primary`, `secondary`

### BCPasswordInput

Input with a reveal toggle.

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
| `textInputAction` | `TextInputAction?` | — |  |

**`BCInputVariant`** — `primary`, `secondary`

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

**`BCInputVariant`** — `primary`, `secondary`

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

**`BCInputVariant`** — `primary`, `secondary`

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

**`BCInputVariant`** — `primary`, `secondary`

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

**`BCInputVariant`** — `primary`, `secondary`

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

### BCSelect

Anchored dropdown select.

```dart
BCSelect<String>(
  value: plan,
  onValueChange: (value) => setState(() => plan = value),
  listLabel: 'Plans',
  items: const [
    BCSelectItem(value: 'free', label: 'Free', description: 'For trying things out'),
    BCSelectItem(value: 'pro', label: 'Pro', description: r'$12 / month'),
  ],
);
```

| Prop | Type | Default | Notes |
|---|---|---|---|
| `items` | `List<BCSelectItem<T>>` | required |  |
| `value` | `T?` | — |  |
| `onValueChange` | `ValueChanged<T>?` | — |  |
| `placeholder` | `String` | `'Select an option'` |  |
| `listLabel` | `String?` | — | Optional label above the option list (select__list-label). |
| `isDisabled` | `bool` | `false` |  |
| `placement` | `BCOverlayPlacement` | `BCOverlayPlacement.auto` |  |

**`BCOverlayPlacement`** — `bottom`, `top`, `auto`

<details><summary><code>BCSelectItem</code></summary>

| Prop | Type | Default | Notes |
|---|---|---|---|
| `value` | `T` | required |  |
| `label` | `String` | required |  |
| `description` | `String?` | — |  |

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

</details>

<details><summary><code>BCDescription</code></summary>

HeroUI Native Description: muted helper text that fades in on mount (description.css, 150ms ease-out).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

</details>

<details><summary><code>BCFieldError</code></summary>

HeroUI Native FieldError: danger-colored validation message that fades in on mount (field-error.css, 150ms ease-out).

| Prop | Type | Default | Notes |
|---|---|---|---|
| `text` | `String` | required | First positional argument. |

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
| `start` | `double` | — |  |
| `end` | `double` | — |  |

</details>

---

## Overlays

### BCDialog

Modal dialog (static `show`, plus content/title/description parts).

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

- `static Future<R?> show<R>(BuildContext context, {required WidgetBuilder builder, bool barrierDismissible = true})` — Presents `builder` over the themed backdrop with the scale + fade transition.

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
| `bottomInset` | `double` | `16` | Distance from the bottom safe area to a `BCToastPlacement.bottom` toast. |
| `horizontalInset` | `double` | `16` | Distance from the left and right edges. |
| `isSwipeable` | `bool` | `true` | Whether toasts can be swiped away, unless `BCToastData.isSwipeable` says otherwise. |

**`BCToastPlacement`** — `top`, `bottom`

</details>

---
