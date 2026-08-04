## 0.3.0

**Accordion**

* `BCAccordion` ports heroui-native's Accordion: a column of collapsible
  sections, one open at a time or several with
  `selectionMode: BCAccordionSelectionMode.multiple`. Compose each section
  from `BCAccordionItem`, `BCAccordionTrigger` and `BCAccordionContent`;
  `variant: BCAccordionVariant.surface` wraps the stack in a rounded surface
  and insets the hairline separators, and `hideSeparator` drops them.
* State is yours: pass `value` + `onValueChange`, or hand it a
  `BCAccordionController` — heroui's uncontrolled `defaultValue` is that
  controller's `initialValue`. `isCollapsible: false` keeps whatever is open
  from closing.
* Content springs open on heroui's layout-transition spring while it fades in
  over 200ms, and the chevron rotates counter-clockwise to match. The body is
  built on first expand and dropped once a collapse settles, so lift any state
  that lives inside it. Reduced-motion settings skip all three animations.
* `BCAccordionIndicator` renders the chevron; give it a `child` to replace it,
  in which case it is not rotated for you — read the state with
  `BCAccordionItem.isExpandedOf(context)`, the equivalent of heroui's
  `useAccordionItem()` hook.

## 0.2.1

**Speed dial**

* `BCSpeedDial` opens into the root overlay rather than the nearest one. Inside
  a nested `Navigator` — a shell branch, a tab view — the nearest overlay
  covers only that screen's slot, so the backdrop stopped short of any
  surrounding chrome: a bottom navigation bar kept painting over the open dial,
  undimmed, and still took taps.

## 0.2.0

**App header**

* `filledIconButtons` on `BCAppHeader` and `BCSliverAppHeader` renders every
  `BCHeaderIconButton` in the leading and actions slots filled, so a screen
  picks the style once instead of at each button. It reaches the back button
  the header implies, which no call site could style before.
* **Breaking:** `BCHeaderIconButton.filled` is now `bool?` and defaults to
  null, which defers to the enclosing header (and to false where there is
  none). Passing `filled: true` or `filled: false` is unchanged and still
  wins over the header; only code that *reads* the field needs a null check.
* The header's inherited style is now installed unconditionally. It used to
  be skipped unless `foregroundColor` was set, so a header that only wanted
  the default colours had no channel to its buttons at all.

## 0.1.0

**Select**

* Three presentations: the anchored `popover` it always had, a `bottomSheet`
  with room for a long list, and a `wheel` for short ordered ones, committed
  with Done. Set with `presentation`.
* Search. `isSearchable` filters on label and description; `onSearch` replaces
  that with your own lookup — debounced by `searchDebounce`, awaited with a
  spinner, and rendered exactly as returned, so it can hit the network.
* Pagination. `onLoadMore` fires as the list nears its end, once per page;
  `isLoadingMore` shows a spinner under the last row.
* Rows take `leading` and `trailing` widgets, a per-item `onTap` that runs
  alongside the value change, and `isDisabled`. `itemBuilder` hands the whole
  row over, selection state included.
* `emptyPlaceholder` and `maxListHeight` for the rest.

The version jumps to 0.1.0 so `^0.1.0` resolves the way callers expect;
`^0.0.x` had pinned them to a single patch.

**Agent skill**

* `skills/bc-ui/` teaches an AI agent to use the library — setup, the naming
  conventions, a routing table to per-category references, and the traps that
  fail silently. Install with `npx skills add binary-castle/bc-ui-flutter`, or
  copy it into `.claude/skills/`; it ships in the package either way.
* Its references come out of `tool/gen_api_doc.py`, the same script that writes
  `doc/api.md`, so they cannot drift. `--check` fails when either is stale and
  `--check-coverage` lists public symbols nothing documents.

**Fixes**

* The generated prop tables dropped every named parameter of a constructor that
  led with a positional one, so `BCText` was documented as taking only `data`,
  and `BCLabel`, `BCDescription`, `BCFieldError` and `BCTextFieldLabel` were
  each missing their flags. `BCTextFieldError`'s argument was listed as `text`
  when it is `message`. All now generated correctly, along with the previously
  undocumented `BCTextWeight`, `BCInputOTPSlot*`, `BCSkeleton*Animation`,
  `BCNavDrawerItem` and `BCAnchoredOverlayController`.
* The README's License section still said the license was a placeholder, left
  over from before the package was licensed. It now states Apache-2.0 and
  credits heroui-native. pub.dev's own metadata was already correct.

## 0.0.2

* Fixed the README on pub.dev: images and repository links are absolute now.
  pub.dev strips raw `<img>` tags and drops repo-relative links, so the banner,
  the light/dark screenshots and every entry in the component table rendered
  without them.
* Install instructions now point at the published package rather than a local
  path dependency.

## 0.0.1

First release — a Flutter port of
[heroui-native](https://github.com/heroui-inc/heroui-native), covering 50+
components on a Material 3 base.

**Foundation**

* `BCTheme.light()` / `BCTheme.dark()` return a `ThemeData`, so Material
  widgets keep working alongside bc_ui.
* 64 semantic colour tokens in `BCThemeExtension`, precomputed from
  heroui-native's oklch sources including every `color-mix` derived hover and
  soft shade. `BCThemeOverrides` recomputes the accent-derived tokens from a
  single colour.
* Continuous (squircle) corners via `RoundedSuperellipseBorder`, layered
  surface and overlay shadows, and the ported motion constants in `BCMotion`.
* Inter is bundled; no font setup.

**Components**

* Navigation — `BCAppHeader`, `BCSliverAppHeader`, `BCBottomNav`, `BCNavRail`,
  `BCNavDrawer`, `BCToolbar`, `BCTabs` with a swipeable `BCTabView`.
* Actions — `BCButton`, `BCSocialAuthButton` (10 providers, vector brand marks,
  no assets), `BCLinkButton`, `BCCloseButton`, `BCFab`, `BCSpeedDial`,
  `BCToggleButton`, and the `BCPressable` feedback engine.
* Containers and data display — `BCSurface`, `BCCard`, `BCListGroup`,
  `BCFlipCard`, `BCScrollShadow`, `BCAvatar`, `BCChip`, `BCRibbon`,
  `BCTagGroup`, `BCSkeleton`, `BCSpinner`, `BCProgress`, `BCLoadingOverlay`,
  `BCRating`, `BCEmptyState`.
* Forms and selection — `BCInput`, `BCTextField`, `BCTextArea`,
  `BCPasswordInput`, `BCSearchField`, `BCInputOTP`, `BCDateField`,
  `BCTimeField`, `BCDateTimePicker`, `BCSelect`, `BCControlField`,
  `BCCheckbox`, `BCRadioGroup`, `BCSwitch`, `BCSlider`, `BCRangeSlider`.
* Overlays — `BCDialog`, `BCPopover`, `BCMenu`, and `BCToast` with top/bottom
  placement and an interactive swipe-to-dismiss.

Full prop tables in [doc/api.md](doc/api.md); the example app has one screen
per component.
