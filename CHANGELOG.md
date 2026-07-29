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
