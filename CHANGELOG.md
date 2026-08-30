## 0.7.0

**Skeleton — text placeholders**

* `BCSkeleton.text` builds a text placeholder from the type scale instead of
  from hand-measured numbers. Each line takes the full line box of its
  `BCTextType` at the reader's text size, so the block stands exactly as tall
  as the text it replaces and nothing under it moves when the content lands.
  A hand-sized bar cannot promise that: `height: 14` is a guess against a
  `body` line box of 28, it drifts from the scale on a type resync, and it
  does not grow when the reader turns text size up — so the jump is worst for
  the readers least able to absorb it.

  ```dart
  BCSkeleton.text(type: BCTextType.h4)
  BCSkeleton.text(lines: 3)
  BCSkeleton.text(lines: 2, child: BCText(bio))
  ```
* Wrapping text in the plain constructor collapsed instead. With no `width`
  or `height` the painter's child is a zero-size box, so
  `BCSkeleton(child: BCText(...))` measured 0.0 x 0.0 while loading and
  snapped to full size on arrival. The text constructor takes its size from
  the type rather than from the child, so there is nothing left to collapse.
* The painted bar is shorter than its line box — `textBarHeightFactor`, 0.875
  of the font size — which leaves the type's own leading as the gap between
  lines, so no separate spacing prop is needed. Above one line the last line
  shortens to `lastLineFraction` (0.6 by default, and a prop where a call site
  wants a different ragged edge) so a paragraph reads as prose rather than as
  a stack of slabs.
* `BCText` renders `code` as a padded chip rather than a bare line, so its
  placeholder adds that same padding. Every one of the ten `BCTextType` values
  now measures identically to the text it stands in for.
* `BCSkeleton.text` carries `child`, `variant`, `animation` and the
  `BCSkeletonGroup` cascade exactly as the box constructor does, so a text
  placeholder drops into an existing group without special-casing.

**Skeleton — placeholder colour**

* The placeholder fill painted as solid `muted` instead of the 30% wash it was
  meant to be. `BCSkeletonTheme.backgroundColor` builds the base correctly, but
  the painter then reassigned its alpha — `Color.withValues(alpha:)` replaces
  the channel rather than scaling it — so the 0.3 was discarded on every
  variant. In light mode that painted `#71717A`, a *foreground* token darker
  than every surface and border in the palette, which is why a loading page read
  as a slab of dark bars against the screens around it. It now composites to
  `#D4D4D7` on a card and `#404046` in dark, where it belongs.
* Same line, same cause for `pulse`: it lerped opacity 0.5 to 1.0 against the
  raw colour, so it throbbed between half and fully opaque muted. It now scales
  the base and sweeps 0.15 to 0.30. `minOpacity` and `maxOpacity` keep their
  meaning — they were always a fraction of the base, never an absolute.
* The shimmer band was derived from the page `background` and lerped toward
  black in light mode. It only read as a highlight because it was sweeping over
  a wrongly-dark base; against a correct one it cleared it by about 2% in light
  and was *darker* than it in dark, an inverted sweep. The band is now white in
  both themes — 0.55 in light, 0.12 in dark — so fixing the base did not leave
  the shimmer invisible.
* The band also faded to `Colors.transparent` at both ends. Gradient stops
  interpolate unpremultiplied, so transparent *black* pulled the ramp toward
  grey and fringed the sweep darker than the base either side of its centre; it
  was a highlight only at the exact midpoint. It now fades to a transparent copy
  of the highlight, leaving alpha as the only thing that varies across the band.
* Nothing in the API changes, which is why this is a patch — but every skeleton
  on every screen looks different. `BCSkeletonShimmerAnimation.highlightColor`
  still overrides the band, and a `decoration.color` still overrides the base,
  including its alpha, which is now respected instead of forced opaque.

## 0.6.1

**App header**

* The compact toolbar title goes from 16px to 20px semibold. It sat beside a
  20px back chevron, which left the arrow as the loudest thing in the bar, and
  a header title should lead over the control that leaves the screen. On
  `BCSliverAppHeader` it read worse still: the compact title is what the 30px
  large title folds into, and at 16px the fold gave up more than the scroll
  had earned.
* `BCAppHeader` and the collapsed `BCSliverAppHeader` share one toolbar, and
  the large title has always collapsed *into* the compact title, so the two
  move together. Splitting them would have put a 16px title on one screen and
  a 20px title on the next.
* Nothing in the API changes, which is why this is a patch — but it is visible
  on every screen using either header, and a long title will ellipsize a
  little sooner than it did. The 56px toolbar still has the room: a 20px title
  over a 12px subtitle comes to about 41px.

## 0.6.0

**Phone field**

* `BCPhoneField` gains `inline`, for the long forms where a stack of boxed
  fields is more furniture than the page can carry. It lays the field out as a
  row of an iOS grouped form: no box, no shadow, no focus ring, the label
  beside the number rather than above it, and the country button without its
  divider — that hairline marks the edge of a box, and there is no box now.
  The row is padded the (20, 6, 6, 6) SwiftUI's `Form` uses, which is what
  `CupertinoFormRow` uses too, so the field lines up with the native rows
  above and below it.
* Drop it straight into a `CupertinoFormSection`'s children; wrapping it in a
  `CupertinoFormRow` as well would pad it twice. `variant` is ignored while
  `inline` is on, and the description and the validation message still land
  under the row, left-aligned, where the section expects them.
* Nothing else about the field changes: the country sheet, the live
  validation, the trunk-prefix stripping and the paste-an-international-number
  handling all behave as they do in a boxed field.
* The PhoneField showcase gains an *In a Cupertino form* variant — the field
  between two `CupertinoTextFormFieldRow`s, which is the case the above is
  about.

**Input**

* `BCInputVariant.plain` — no background, no shadow, no focus ring and no
  horizontal padding, just the text with its prefix and suffix. It is what
  `inline` is built on, and it is for any field sitting inside chrome
  something else already drew: a form row, a table cell, a toolbar. That
  container then owns the shape, the padding, and telling the user the value
  is wrong.
* Adding a value to `BCInputVariant` is why this is a minor release rather
  than a patch: an exhaustive `switch` over it in your own code now needs a
  third arm. The fields that read the enum by comparison — `BCDateField`,
  `BCTimeField`, `BCDateTimePicker` — treat `plain` as `secondary`, and are
  otherwise untouched.

## 0.5.0

**Tokens**

* `overlay` no longer duplicates `surface`. The two held the same value in both
  themes, so anything painted on a sheet, dialog, menu or popover — a `BCCard`,
  a `BCListGroup`, a text field — had no edge against the panel beneath it. In
  dark the card vanished outright, since dark surfaces carry neither shadow nor
  border and the fill was the only cue. `overlay` is now `#F7F7F8` in light and
  `#1F1F23` in dark. Sheets and dialogs shift tone slightly as a result, which
  is why this is a minor release rather than a patch.
* Light and dark separate in opposite directions, deliberately. Light `surface`
  is already pure white, so the sheet moves *down* and cards float lighter on
  it, the way a grouped table reads on iOS; dark has headroom above `surface`,
  so the sheet moves *up*. `overlayForeground` and `segment` were checked
  against the new values and both still contrast comfortably — neither changed.
* Custom accents are unaffected: nothing is derived from `overlay`, so
  `BCThemeOverrides` recomputes exactly what it did before.

**Toast, Navigation drawer**

* `BCToast` and the modal `BCNavDrawer` now paint `overlay` rather than
  `surface`. Both float above the page wearing the overlay shadow, so they
  belong with the dialogs and sheets; they only matched before because the two
  tokens happened to be equal. The permanent drawer keeps `background`, and the
  bottom nav, toolbar and app header stay on `surface` — those read as page
  chrome, not overlays.

## 0.4.3

**Toast**

* A bottom toast no longer comes up behind the on-screen keyboard, where it
  was all but invisible. While the keyboard is up, `bottomInset` is measured
  from the top of the keys instead of the safe area, and the card rides the
  keyboard down again when it closes. Top toasts are unaffected.
* The Toast showcase gains a *With the keyboard up* variant — a focused field
  and a toast fired behind it, the case the above is about.

## 0.4.2

**Dialog**

* A modal with a form in it no longer disappears behind the on-screen
  keyboard. The dialog is laid out in the band above the keyboard, and content
  taller than that band scrolls — focusing a field brings it into view instead
  of leaving the caret under the keys, so six fields in a modal stay reachable
  from the first to the last.
* `BCDialog.show` gains `isSwipeable` (on by default): a downward drag carries
  the dialog with the finger the way a bottom sheet does, rubber-bands when
  dragged the other way, and either springs back or keeps the momentum of the
  throw — the drag physics `BCToast` already used, rather than a gesture that
  merely triggers the close animation. While the content is tall enough to
  scroll, the scroll takes the drag.
* The Dialog showcase gains a *Form dialog* variant — six fields and a
  password, the case both of the above are about.

## 0.4.1

**Password field**

* `BCPasswordInput` gains a `prefix`, the leading slot `BCInput` and
  `BCTextFieldInput` already exposed. The visibility toggle keeps the trailing
  slot, so a password field can now carry a leading icon (a lock, say) like
  every other input.

## 0.4.0

**Phone field**

* `BCPhoneField` — an international phone input. The field's prefix is a
  tappable flag and dial code that opens the searchable country list, and the
  number groups itself as you type.
* Leave `initialCountry` null and the field opens on the device's own region,
  the way a web form reads `navigator.language` — a phone set to Bangladesh
  opens on Bangladesh. `fallbackCountry` covers a device that reports no
  usable region (a bare `en` locale, or a UN M.49 region like `es_419`), and
  `BCPhoneField.deviceCountry()` exposes the lookup for your own state. This
  is the phone's *configured* region, not where it physically is.
* Validation is libPhoneNumber's metadata rather than a regex, so it knows
  each country's real lengths and prefixes: `+1 555 000 0000` is rejected
  where a digit count would pass it. `onChanged` hands back a `BCPhoneNumber`
  with `e164`, `national`, `international`, `isoCode` and `isValid` on every
  keystroke; `onValidityChanged` fires only when validity flips, so a submit
  button can be driven straight from it.
* Nothing is blocked while you type — a half-typed number is not an error, so
  the message waits for blur (or for a caller-supplied `errorText`, which
  always wins). `invalidNumberText: null` keeps the field silent and reports
  through the callback only.
* The country's trunk prefix is dropped as you type, because it is not part
  of an international number: a UK number beside `+44` is `7400 123456`,
  never `07400 123456`.
* The picker is authoritative about the country. `+1` covers 25 countries and
  no parser can tell a US number from a Canadian one, so whatever the user
  picks wins over what the metadata guesses.
* **This adds bc_ui's first runtime dependency**, `phone_numbers_parser`.
  It is pure Dart with no platform channels, and its own only dependency is
  `meta`.

**Select**

* `triggerBuilder` replaces a `BCSelect`'s trigger wholesale while keeping its
  press feedback, tap handling, disabled dimming and popover anchoring.
* `matchTriggerWidth` (default `true`, unchanged behaviour) stops a narrow
  custom trigger from squeezing the popover list to its own width.
* `triggerFeedback` (default `BCPressFeedback.scale`, unchanged behaviour)
  because the scale is width-compensated and pops harder on a small inline
  trigger than on the default one.

**Input**

* `autofillHints` on `BCInput`, forwarded to the underlying field. Without it
  the OS keychain and iOS's one-tap SMS code were unreachable.

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
