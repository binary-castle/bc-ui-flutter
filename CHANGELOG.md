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

**Fixes**

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
