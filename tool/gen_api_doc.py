"""Regenerate doc/api.md.

Prose (summaries, examples, conventions) lives in this file; every prop table
is extracted from lib/src so the reference cannot drift from the code.

    python3 tool/gen_api_doc.py          # writes doc/api.md

Run it from the package root after changing a public constructor.
"""

import os
import re
import sys

ROOT = 'lib/src'


def class_bodies(src):
    """Yield (kind, name, body) for every top-level class/enum."""
    for m in re.finditer(r'^(?:abstract\s+)?(?:final\s+)?(?:sealed\s+)?(class|enum)\s+(\w+)', src, re.M):
        kind, name = m.group(1), m.group(2)
        brace = src.find('{', m.end())
        if brace < 0:
            continue
        depth, i = 0, brace
        while i < len(src):
            if src[i] == '{':
                depth += 1
            elif src[i] == '}':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        # doc comment above
        head = src[:m.start()].rstrip().split('\n')
        doc = []
        for line in reversed(head):
            t = line.strip()
            if t.startswith('///'):
                doc.insert(0, t[3:].strip())
            elif t.startswith('@') or t == '':
                if t == '':
                    break
            else:
                break
        yield kind, name, src[brace:i], ' '.join(doc).strip()


def split_args(s):
    """Split a parameter list on commas that are not nested in (), [], {}, <>."""
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch in '([{<':
            depth += 1
        elif ch in ')]}>':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur)
    return out


def split_params(s):
    """Split a constructor's argument list into (positional, named).

    Dart parks named parameters inside a trailing `{...}` (optional positionals
    inside `[...]`). Feeding that straight to `split_args` counts the brace as
    nesting, so everything after the first positional collapses into one
    unparseable chunk and every named parameter is silently dropped. Peel the
    group off first, then split each part on its own.
    """
    depth = 0
    for i, ch in enumerate(s):
        if depth == 0 and ch in '{[':
            head = s[:i].rstrip().rstrip(',')
            tail = s[i + 1:].rstrip().rstrip(',')
            if tail.endswith(('}', ']')):
                tail = tail[:-1]
            return split_args(head), split_args(tail)
        if ch in '([{<':
            depth += 1
        elif ch in ')]}>':
            depth -= 1
    return split_args(s), []


def parse_class(name, body):
    """Return (params, fields, doc_by_field)."""
    fields = {}
    docs = {}
    for fm in re.finditer(
        r'((?:[ \t]*///[^\n]*\n)*)[ \t]*(?:final|late final)\s+([\w<>,\?\s\.\(\)]+?)\s+(\w+)\s*(?:=|;)',
        body,
    ):
        d = ' '.join(l.strip()[3:].strip() for l in fm.group(1).strip().split('\n') if l.strip())
        fields[fm.group(3)] = re.sub(r'\s+', ' ', fm.group(2)).strip()
        if d:
            docs[fm.group(3)] = d

    ctor = re.search(
        r'(?:const\s+)?' + re.escape(name) + r'(?:<[^>]*>)?\((.*?)\)\s*(?::|;|\{)',
        body, re.S,
    )
    params = []
    if ctor:
        seen = set()
        positional, named = split_params(ctor.group(1))
        args = [(True, a) for a in positional] + [(False, a) for a in named]
        for is_positional, arg in args:
            arg = re.sub(r'///[^\n]*', '', arg).strip().rstrip(',')
            if not arg or arg.startswith('//'):
                continue
            pm = re.match(
                r'(required\s+)?(?:[\w<>,\?\s\.]+\s+)?(?:this\.|super\.)?(\w+)\s*(?:=\s*(.+))?$',
                arg, re.S,
            )
            if not pm:
                continue
            pname = pm.group(2)
            if pname in seen or pname == 'key':
                continue
            seen.add(pname)
            default = re.sub(r'\s+', ' ', (pm.group(3) or '').strip())
            params.append({
                'name': pname,
                # A positional with no default is required without saying so.
                'required': bool(pm.group(1)) or (is_positional and not default),
                'positional': is_positional,
                'default': default,
                'type': fields.get(pname, ''),
                'doc': docs.get(pname, ''),
            })
    return params



def extract(root='lib/src'):
    api = {}
    for dirpath, _, files in os.walk(root):
        for f in sorted(files):
            if not f.endswith('.dart'):
                continue
            src = open(os.path.join(dirpath, f)).read()
            for kind, name, body, doc in class_bodies(src):
                if name.startswith('_'):
                    continue
                if kind == 'enum':
                    # Strip comments first: a ';' inside a doc comment must
                    # not look like the end of the value list.
                    head = re.sub(r'///[^\n]*|//[^\n]*', '', body.strip('{}')).split(';')[0]
                    values = []
                    for part in split_args(head):
                        m2 = re.match(r'\s*(\w+)', part)
                        if m2 and m2.group(1) not in ('final', 'const', 'static'):
                            values.append(m2.group(1))
                    api[name] = {'kind': 'enum', 'doc': doc, 'values': values}
                else:
                    api[name] = {'kind': 'class', 'doc': doc, 'body': body,
                                 'params': parse_class(name, body)}
    return api


API = extract()
ENUMS = {k: v for k, v in API.items() if v['kind'] == 'enum'}

CATALOG = [
    ('Navigation', [
        'BCAppHeader', 'BCSliverAppHeader', 'BCHeaderIconButton',
        'BCBottomNav', 'BCNavRail', 'BCNavDrawer', 'BCToolbar',
        'BCTabs', 'BCTabView',
    ]),
    ('Actions', [
        'BCButton', 'BCSocialAuthButton', 'BCBrandLogo', 'BCLinkButton',
        'BCCloseButton', 'BCFab', 'BCSpeedDial',
        'BCToggleButton', 'BCToggleButtonGroup', 'BCPressable',
    ]),
    ('Containers', [
        'BCSurface', 'BCCard', 'BCListGroup', 'BCAccordion', 'BCFlipCard',
        'BCScrollShadow',
    ]),
    ('Data display', [
        'BCText', 'BCAvatar', 'BCChip', 'BCRibbon', 'BCTagGroup', 'BCSeparator',
        'BCSkeleton', 'BCSpinner', 'BCProgress', 'BCLoadingOverlay',
        'BCRating', 'BCEmptyState',
    ]),
    ('Forms', [
        'BCInput', 'BCTextField', 'BCTextArea', 'BCPasswordInput',
        'BCSearchField', 'BCInputOTP', 'BCDateField', 'BCTimeField',
        'BCDateTimePicker', 'BCDateTimeWheel', 'BCCalendar', 'BCTimeWheel',
        'BCPhoneField', 'BCSelect', 'BCControlField',
    ]),
    ('Selection', [
        'BCCheckbox', 'BCRadioGroup', 'BCSwitch', 'BCSlider', 'BCRangeSlider',
    ]),
    ('Overlays', ['BCDialog', 'BCPopover', 'BCMenu', 'BCToast']),
]

# One-liners that override / sharpen the source dartdoc for the doc index.
SUMMARY = {
    'BCAppHeader': 'Top app bar with four backgrounds (frosted, solid, transparent, floating), an optional subtitle and a hairline separator that fades in when content scrolls under it. Drop it into `Scaffold.appBar`.',
    'BCSliverAppHeader': 'Pinned sliver header with an iOS-style large title that collapses into the compact toolbar title. Put it first in a `CustomScrollView`.',
    'BCHeaderIconButton': 'Round 40px icon button for header leading/action slots, with optional fill and badges.',
    'BCBottomNav': 'Bottom navigation bar — full-width or detached/floating — with an accent-soft pill indicator and badges.',
    'BCNavRail': 'Vertical navigation for medium and larger windows — the counterpart to `BCBottomNav` on compact ones. Collapsed it is an 80px icon strip; `extended` widens it so labels sit beside the icons, and the width change animates.',
    'BCNavDrawer': 'Wide vertical navigation, inline on large windows (`standard`) or sliding over content from `Scaffold.drawer` (`modal`). Items mix destinations with section labels and dividers; `selectedIndex` counts destinations only.',
    'BCToolbar': 'A bar of actions for the current screen — the bottom-of-screen counterpart to `BCAppHeader`. Docked to the edge or floating as a rounded pill, horizontal or vertical, optionally frosted.',
    'BCProgress': 'Determinate and indeterminate progress, linear or circular, with an optional label and percentage. Determinate changes ease into place instead of snapping.',
    'BCLoadingOverlay': 'Covers a page or section while work is in flight: fades in a dim or blurred backdrop, blocks input underneath, and centers an indicator with an optional label.',
    'BCRangeSlider': 'Two-thumb slider for a start/end range — price filters, time windows, thresholds. Shares `BCSlider`\'s metrics and spring.',
    'BCTabs': 'Segmented control. Drive it with `value` + `onValueChange`, or hand it a `BCTabsController` to pair it with a swipeable `BCTabView`.',
    'BCTabView': 'The swipeable panels behind a `BCTabs` bar. Sharing a controller means a drag switches tabs and carries the indicator with it.',
    'BCButton': 'The primary action component: 7 variants x 3 sizes, optional leading/trailing content, icon-only and full-width modes.',
    'BCSocialAuthButton': 'Sign-in button for an identity provider — a `BCButton` with the provider\'s brand mark as start content, so it lines up with every other button on the screen. Ten providers ship with the package; logos are vector data, not assets.',
    'BCBrandLogo': 'A provider\'s brand mark painted as vector art at any size, in official colours or as a single-colour glyph. Used by `BCSocialAuthButton`; usable on its own for account rows and settings.',
    'BCLinkButton': 'Text-only action that reads as a link.',
    'BCCloseButton': '32px tertiary icon button used by dialogs and dismissible surfaces.',
    'BCFab': 'Floating action button.',
    'BCSpeedDial': 'FAB that expands into a labelled action list over a dimmed or blurred backdrop.',
    'BCToggleButton': 'Two-state button (icon, label, or both).',
    'BCToggleButtonGroup': 'Row of toggle buttons with single or multiple selection.',
    'BCPressable': 'The press-feedback engine every interactive component is built on — scale, highlight and ripple, with heroui-native\'s exact timings.',
    'BCSurface': 'Base container: 16px padding, 24px continuous corners, surface shadow.',
    'BCCard': 'Surface with the compound header/body/footer/title/description parts.',
    'BCListGroup': 'Grouped rows inside one rounded surface, with hairline separators.',
    'BCAccordion': 'Collapsible sections stacked in one column — one open at a time, or several with `selectionMode`. Plain by default; `surface` wraps the stack in a rounded surface. Each `BCAccordionItem` pairs a `BCAccordionTrigger` with a `BCAccordionContent` that springs open as it fades in, and a chevron that rotates with it. Drive it with `value` + `onValueChange`, or hand it a `BCAccordionController`.',
    'BCFlipCard': 'Two faces that flip on tap or programmatically.',
    'BCScrollShadow': 'Fades a gradient in at the edges of a scrollable while there is more to scroll.',
    'BCText': 'Typography primitive with the heroui type scale.',
    'BCAvatar': 'Composable avatar: image with a fallback that shows initials while loading or on error.',
    'BCChip': 'Compact pill for status, filters and metadata.',
    'BCRibbon': "Merchandising ribbon for product cards — 'Hot Sale', 'Nearby', '-30%'. Five forms — pill tag, edge flag, corner sash, full-width banner, bookmark — laid over a card and clipped to its corners where the form needs it. The corner band sizes itself to its label and takes `cornerOffset`/`cornerThickness`, so it runs from a thin floating stripe to a filled corner (`cornerOffset: 0`). The overlay never takes pointer events, so the card stays tappable.",
    'BCTagGroup': 'Wrapping list of selectable/removable tags.',
    'BCSeparator': 'Horizontal or vertical rule.',
    'BCSkeleton': 'Loading placeholder with shimmer or pulse.',
    'BCSpinner': 'Indeterminate loading indicator.',
    'BCRating': 'Star rating, read-only or interactive, with optional halves.',
    'BCEmptyState': 'Empty/zero-state block: icon or illustration, title, description and actions.',
    'BCInput': 'Single-line text input primitive.',
    'BCTextField': 'Compound field: label, input, description and error, wired together for validation state.',
    'BCTextArea': 'Multi-line input.',
    'BCPasswordInput': 'Input with a reveal toggle.',
    'BCSearchField': 'Input with a search icon and a clear button.',
    'BCInputOTP': 'One-time-code field composed of slots, with a caret and separators.',
    'BCDateField': 'Read-only field that opens a calendar in a dialog, a popover or a bottom sheet (`presentation`). Months change by swiping the grid or with the header arrows.',
    'BCTimeField': 'Read-only field that opens the hour/minute wheels in a dialog, a popover or a bottom sheet (`presentation`). The dialog commits on Confirm; popover and sheet apply each spin live.',
    'BCCalendar': 'The month calendar behind `BCDateField`: header, weekday row and a swipeable six-row day grid. Usable on its own.',
    'BCTimeWheel': 'The hour / minute (and AM/PM) wheels behind `BCTimeField`. Usable on its own.',
    'BCDateTimePicker': 'Date **and** time in one field: day, hour, minute (and AM/PM) wheels presented in a popover, a dialog or a bottom sheet, with built-in label, description and error slots.',
    'BCDateTimeWheel': 'The wheels behind `BCDateTimePicker`, usable on their own to embed day/time selection in a form or a sheet of your own.',
    'BCPhoneField': "International phone input: a tappable flag and dial code in the field's prefix opening a searchable country list, and a number that groups itself as you type. Leave `initialCountry` null and it opens on the device's own region, the way a web form reads `navigator.language`. Validation is libPhoneNumber's, not a regex — it knows each country's real lengths and prefixes, so `+1 555 000 0000` comes back invalid. Nothing is blocked while you type; `onChanged` reports a `BCPhoneNumber` with `isValid` on every keystroke and the message waits for blur. The trunk prefix is dropped as you type, because it is not part of an international number.",
    'BCSelect': "Dropdown select with three presentations — an anchored popover, a bottom sheet, or a spinning wheel — plus search and pagination hooks for lists too long to scroll. `isSearchable` filters locally; `onSearch` hands the lookup to you (debounced and awaited, so it can hit the network); `onLoadMore` fires as the list nears its end. Rows take `leading`/`trailing` slots, a per-item `onTap` and `isDisabled`, or hand the whole row to `itemBuilder`. `triggerBuilder` replaces the trigger itself — pair it with `matchTriggerWidth: false` when the replacement is narrower than its list.",
    'BCControlField': 'Row that pairs a control (switch, checkbox, radio) with a label and description.',
    'BCCheckbox': 'Checkbox with a spring-animated indicator.',
    'BCRadioGroup': 'Radio group; wraps `BCRadio` children and owns the selected value.',
    'BCSwitch': 'Switch with spring thumb motion and optional start/end content.',
    'BCSlider': 'Slider with optional label, output readout and stepping.',
    'BCDialog': 'Modal dialog (static `show`, plus content/title/description parts).',
    'BCPopover': 'Anchored popover that flips and clamps to stay on screen.',
    'BCMenu': 'Anchored menu with items, labels, separators and a danger variant.',
    'BCToast': 'Transient message queue; `BCToastProvider` hosts it above the app. Toasts stack against the top or bottom edge (`placement`, per provider or per toast) and are swiped away toward that edge — the card tracks the finger, rubber-bands the other way, and keeps its momentum when it is thrown.',
}

EXAMPLES = {
    'BCAppHeader': '''Scaffold(
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
);''',
    'BCSliverAppHeader': '''CustomScrollView(
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
);''',
    'BCBottomNav': '''BCBottomNav(
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
);''',
    'BCTabs': '''// Uncontrolled: you own the value.
BCTabs<String>(
  value: tab,
  onValueChange: (value) => setState(() => tab = value),
  items: const [
    BCTabItem(value: 'all', label: 'All'),
    BCTabItem(value: 'open', label: 'Open'),
  ],
);''',
    'BCTabView': '''// Swipeable: bar + panels share one controller.
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
);''',
    'BCNavRail': '''Row(
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
);''',
    'BCNavDrawer': '''Scaffold(
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
);''',
    'BCToolbar': '''Scaffold(
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
);''',
    'BCProgress': '''BCProgress(value: 0.4, label: 'Uploading', showValueLabel: true);

// Indeterminate until you know the total.
const BCProgress(variant: BCProgressVariant.circular);

BCProgress(
  value: bytes / total,
  size: BCProgressSize.lg,
  color: BCProgressColor.success,
  formatValue: (v) => '${(v * total / 1e6).round()} MB',
);''',
    'BCLoadingOverlay': '''BCLoadingOverlay(
  isLoading: _saving,
  label: 'Saving changes',
  backdrop: BCLoadingBackdrop.blur,
  child: ProfileForm(),
);''',
    'BCRangeSlider': '''BCRangeSlider(
  values: range,
  minValue: 0,
  maxValue: 500,
  step: 10,
  minSeparation: 50, // thumbs cannot come closer than this
  label: 'Price',
  showOutput: true,
  formatOutput: (value) => '\$${value.round()}',
  onChanged: (value) => setState(() => range = value),
);''',
    'BCButton': '''BCButton(
  variant: BCButtonVariant.secondary,
  size: BCButtonSize.lg,
  onPressed: () {},
  startContent: const Icon(Icons.add, size: 18),
  child: const Text('Add item'),
);''',
    'BCSocialAuthButton': '''// A stack of sign-in options: outline buttons, full width by default.
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
);''',
    'BCBrandLogo': '''const BCBrandLogo(provider: BCSocialProvider.github, size: 24);

// Single-colour glyph instead of the brand colours.
BCBrandLogo(
  provider: BCSocialProvider.slack,
  color: context.bcTheme.foreground,
);''',
    'BCRibbon': '''// Wraps the card it decorates.
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
const BCRibbon(label: Text('-30%'), form: BCRibbonForm.bookmark);''',
    'BCSpeedDial': '''BCSpeedDial(
  items: [
    BCSpeedDialItem(label: 'New note', icon: const Icon(Icons.note_add), onPressed: () {}),
    BCSpeedDialItem(label: 'Delete', icon: const Icon(Icons.delete), isDanger: true, onPressed: () {}),
  ],
);''',
    'BCPressable': '''BCPressable(
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
);''',
    'BCCard': '''BCCard(
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
);''',
    'BCListGroup': '''BCListGroup(
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
);''',
    'BCAccordion': r'''// You own the set of expanded values.
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
);''',
    'BCText': """const BCText('Section title', type: BCTextType.h4);
const BCText('Muted caption', type: BCTextType.bodyXs, color: BCTextColor.muted);""",
    'BCAvatar': '''BCAvatar(
  size: BCAvatarSize.large,
  children: [
    BCAvatarImage(image: NetworkImage(url)),
    const BCAvatarFallback(initials: 'RK'), // shown while loading / on error
  ],
);''',
    'BCChip': '''BCChip(
  variant: BCChipVariant.soft,
  color: BCChipColor.success,
  startContent: const Icon(Icons.trending_up, size: 14),
  child: const Text('+12.4%'),
);''',
    'BCTagGroup': '''BCTagGroup<String>(
  selectionMode: BCTagGroupSelectionMode.multiple,
  selectedValues: selected,
  onSelectionChange: (values) => setState(() => selected = values),
  items: const [
    BCTagItem(value: 'design', label: 'Design'),
    BCTagItem(value: 'code', label: 'Code'),
  ],
);''',
    'BCSkeleton': '''BCSkeletonGroup(
  isLoading: loading,
  child: Column(
    children: const [
      BCSkeleton(width: 180, height: 20),
      SizedBox(height: 8),
      BCSkeleton(width: 240, height: 20),
    ],
  ),
);''',
    'BCEmptyState': '''BCEmptyState(
  icon: const Icon(Icons.inbox_outlined),
  title: 'No messages',
  description: 'When someone writes to you it will show up here.',
  actions: [BCButton(onPressed: () {}, child: const Text('Refresh'))],
);''',
    'BCTextField': '''BCTextField(
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
);''',
    'BCInputOTP': '''BCInputOTP(
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
);''',
    'BCDateTimePicker': '''BCDateTimePicker(
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
);''',
    'BCSelect': '''BCSelect<String>(
  value: plan,
  onValueChange: (value) => setState(() => plan = value),
  listLabel: 'Plans',
  items: const [
    BCSelectItem(value: 'free', label: 'Free', description: 'For trying things out'),
    BCSelectItem(value: 'pro', label: 'Pro', description: r'$12 / month'),
  ],
);''',
    'BCPhoneField': '''// No initialCountry: opens on the device's own region,
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
);''',
    'BCSelect': '''// The default: an anchored list under the trigger.
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
);''',
    'BCControlField': '''BCControlField(
  label: 'Push notifications',
  description: 'Deals, order updates and reminders.',
  control: BCSwitch(isSelected: on, onSelectedChange: (v) => setState(() => on = v)),
  onPressed: () => setState(() => on = !on),
);''',
    'BCRadioGroup': '''BCRadioGroup<String>(
  value: plan,
  onValueChange: (value) => setState(() => plan = value),
  children: const [
    BCRadio(value: 'free', label: 'Free', description: 'For trying things out'),
    BCRadio(value: 'pro', label: 'Pro'),
  ],
);''',
    'BCSlider': '''BCSlider(
  value: volume,
  onChanged: (v) => setState(() => volume = v),
  label: 'Volume',
  showOutput: true,
  formatOutput: (v) => '${(v * 100).round()}%',
);''',
    'BCDialog': '''BCDialog.show<void>(
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
);''',
    'BCPopover': '''BCPopover(
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
);''',
    'BCMenu': '''BCMenu(
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
);''',
    'BCToast': '''// Once, above the app. `placement` sets the edge every toast
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
));''',
}

MEMBERS = {
    'BCPhoneField': [
        ('static IsoCode? deviceCountry()', "The device's configured region — `en_GB` gives `IsoCode.GB`, and null when no preferred locale carries one the parser knows. What `initialCountry` uses when you leave it null. This is the phone's configured region, not where it physically is."),
        ('static String flagEmoji(IsoCode isoCode)', 'The flag as a regional-indicator emoji pair — `IsoCode.BD` becomes 🇧🇩.'),
    ],
    'BCPhoneNumber': [
        ('const BCPhoneNumber({required IsoCode isoCode, required String nsn})', 'The `nsn` is the national significant number in international form — digits only, no trunk prefix, no dial code.'),
        ('factory BCPhoneNumber.parse(String text, {IsoCode? country})', 'Reads a number in any shape and never throws; an unreadable string comes back as the digits it could salvage under `country` (or `IsoCode.US`).'),
        ('IsoCode isoCode', 'The country. Authoritative — `+1` covers 25 countries, so the picker decides, not the parser.'),
        ('String nsn', 'National significant number, digits only.'),
        ('String dialCode', "Without the plus — `880`."),
        ('String e164', "`+8801712345678`. Empty while `nsn` is."),
        ('String national', 'Grouped the way the country writes it — `(201) 555-0123`.'),
        ('String international', '`+880 1712-345678`.'),
        ('bool isEmpty', 'Whether `nsn` is empty.'),
        ('bool isValid', "Length *and* pattern, against libPhoneNumber's metadata."),
        ('BCPhoneNumber copyWith({IsoCode? isoCode, String? nsn})', 'A copy with either half replaced.'),
    ],
    'BCTabsController': [
        ('BCTabsController({required List<T> values, T? initialValue})', 'Create one per tab bar + view pair and dispose it with your `State`.'),
        ('T value', 'The settled tab.'),
        ('int index', 'Index of the settled tab.'),
        ('double offset', 'Continuous position — `1.4` halfway through a swipe from tab 1 to 2. Drives the indicator.'),
        ('List<T> values', 'The tab values, in panel order.'),
        ('PageController pageController', 'Owned by the controller; hand it to `BCTabView`, not to a bare `PageView`.'),
        ('Future<void> animateTo(T value, {Duration duration, Curve curve})', 'Animate bar + panels to a tab.'),
        ('void jumpTo(T value)', 'Switch without animating.'),
        ('void dispose()', 'Disposes the page controller too.'),
    ],
    'BCAccordionController': [
        ('BCAccordionController({Set<String> initialValue = const {}})', "Create one per accordion and dispose it with your `State`. heroui's uncontrolled `defaultValue` is `initialValue` here."),
        ('Set<String> value', 'The expanded item values. The getter is an unmodifiable view — assign a new set to change them.'),
        ('bool isExpanded(String value)', 'Whether that item is open.'),
        ('void expand(String value)', 'Opens one item, leaving the others alone. Does not apply `selectionMode`.'),
        ('void collapse(String value)', 'Closes one item.'),
        ('void collapseAll()', 'Closes everything.'),
    ],
    'BCAnchoredOverlayController': [
        ('BCAnchoredOverlayController()', 'Create one per anchored overlay in a `State` and dispose it there. Drives `BCPopover`, `BCMenu` and `BCSelect`.'),
        ('bool isOpen', 'Whether the overlay is showing.'),
        ('void open()', 'Show the overlay.'),
        ('void close()', 'Hide it.'),
        ('void toggle()', 'The usual `onPressed` for a trigger.'),
    ],
    'BCDialog': [
        ('static Future<R?> show<R>(BuildContext context, {required WidgetBuilder builder, bool barrierDismissible = true})', 'Presents `builder` over the themed backdrop with the scale + fade transition.'),
    ],
    'BCToast': [
        ('static void show(BuildContext context, BCToastData data)', 'Queues a toast. Requires a `BCToastProvider` above `context`.'),
        ('static void hideAll(BuildContext context)', 'Clears the queue.'),
    ],
    'BCTheme': [
        ('static ThemeData light({BCThemeOverrides? overrides})', 'Light `ThemeData` carrying `BCThemeExtension`.'),
        ('static ThemeData dark({BCThemeOverrides? overrides})', 'Dark `ThemeData` carrying `BCThemeExtension`.'),
    ],
}

# Compound sub-widgets listed under their parent instead of getting a section.
SUBPARTS = {
    'BCCard': ['BCCardHeader', 'BCCardBody', 'BCCardFooter', 'BCCardTitle', 'BCCardDescription'],
    'BCListGroup': ['BCListGroupItem'],
    'BCAccordion': [
        'BCAccordionItem', 'BCAccordionTrigger', 'BCAccordionIndicator',
        'BCAccordionContent', 'BCAccordionController',
    ],
    'BCTabs': ['BCTabItem', 'BCTabsController'],
    'BCNavRail': ['BCNavRailDestination'],
    'BCNavDrawer': [
        'BCNavDrawerItem', 'BCNavDrawerDestination', 'BCNavDrawerSection',
        'BCNavDrawerDivider',
    ],
    'BCRangeSlider': ['BCRange'],
    'BCBottomNav': ['BCBottomNavItem'],
    'BCAvatar': ['BCAvatarImage', 'BCAvatarFallback'],
    'BCTextField': ['BCTextFieldLabel', 'BCTextFieldInput', 'BCTextFieldDescription', 'BCTextFieldError'],
    'BCInputOTP': [
        'BCInputOTPGroup', 'BCInputOTPSlot', 'BCInputOTPSlotPlaceholder',
        'BCInputOTPSlotValue', 'BCInputOTPSlotCaret', 'BCInputOTPSeparator',
    ],
    'BCSelect': ['BCSelectItem'],
    'BCPhoneField': ['BCPhoneNumber'],
    'BCTagGroup': ['BCTagItem'],
    'BCSpeedDial': ['BCSpeedDialItem'],
    'BCToggleButtonGroup': ['BCToggleButtonOption'],
    'BCDialog': ['BCDialogContent', 'BCDialogTitle', 'BCDialogDescription'],
    'BCPopover': [
        'BCPopoverTitle', 'BCPopoverDescription', 'BCAnchoredOverlayController',
    ],
    'BCMenu': ['BCMenuItem', 'BCMenuLabel', 'BCMenuSeparator'],
    'BCToast': ['BCToastData', 'BCToastProvider'],
    'BCEmptyState': ['BCEmptyStateAvatarCluster'],
    'BCSkeleton': [
        'BCSkeletonGroup', 'BCSkeletonAnimation',
        'BCSkeletonShimmerAnimation', 'BCSkeletonPulseAnimation',
    ],
    'BCRadioGroup': ['BCRadio'],
    'BCDateField': ['BCDatePickerDialog', 'BCCalendar'],
    'BCDateTimePicker': ['BCDateTimeWheel'],
    'BCTimeField': ['BCTimePickerDialog', 'BCTimeWheel'],
    'BCControlField': ['BCLabel', 'BCDescription', 'BCFieldError'],
}


DEFAULTS = {
    'defaultToolbarHeight': '56',
    'BCAppHeader.defaultToolbarHeight': '56',
    'BCMotion.pressScale': '0.985',
}

# Positional arguments are derived from the constructor by `split_params`,
# not listed by hand — the old table drifted (it claimed BCTextFieldError took
# `text` when the field is `message`).


def clean_doc(s):
    """Drop dartdoc code samples — the doc supplies its own examples."""
    return re.sub(r'\s*```.*?```\s*', ' ', s, flags=re.S).strip()


def esc(s):
    s = re.sub(r'\[([^\]]+)\]', r'`\1`', s)
    return s.replace('|', r'\|').replace('\n', ' ').strip()


def code(s):
    return f'`{s}`' if s else ''


def props_table(name, level='####'):
    e = API.get(name)
    if not e or e['kind'] != 'class':
        return ''
    params = e.get('params') or []
    if not params:
        return ''
    rows = ['| Prop | Type | Default | Notes |', '|---|---|---|---|']
    seen_positional = 0
    for p in params:
        raw = DEFAULTS.get(p['default'], p['default'])
        default = 'required' if p['required'] else (code(raw) or '—')
        notes = esc(p['doc'])
        if p.get('positional'):
            label = 'First positional argument.' if seen_positional == 0 \
                else f'Positional argument {seen_positional + 1}.'
            notes = (label + ' ' + notes).strip()
            seen_positional += 1
        rows.append(
            f"| `{p['name']}` | {code(p['type'])} | {default} | {notes} |"
        )
    return '\n'.join(rows)


def enums_for(name):
    """Enums referenced by this class's param types."""
    e = API.get(name, {})
    found = []
    for p in e.get('params', []):
        for en in ENUMS:
            if re.search(r'\b' + en + r'\b', p['type']) and en not in found:
                found.append(en)
    return found


def render_header_and_contents():
    out = []
    w = out.append

    w('# bc_ui API reference')
    w('')
    w('Every component, its props and its enums. Prop tables are generated from the')
    w('source, so they track the code.')
    w('')
    w('- New here? Start with the [README](../README.md).')
    w('- These tables are generated: `python3 tool/gen_api_doc.py` re-extracts them')
    w('  from `lib/src` after an API change.')
    w('- Looking for a live version of a component? `cd example && flutter run` —')
    w('  one screen per component, each with paged usage variants.')
    w('')
    w('## Contents')
    w('')
    w('- [Conventions](#conventions)')
    w('- [Theme and tokens](#theme-and-tokens)')
    for section, names in CATALOG:
        anchor = section.lower().replace(' ', '-')
        w(f'- [{section}](#{anchor}) — ' + ', '.join(f'`{n}`' for n in names))
    w('')
    w('---')
    w('')
    return out


def render_conventions():
    out = []
    w = out.append

    w('## Conventions')
    w('')
    w('A few rules hold across the whole library, so you can guess most APIs:')
    w('')
    w('- **Every component reads its colors from the theme**, never from hard-coded')
    w('  values. Reach the tokens yourself with `context.bcTheme`.')
    w('- **`variant` picks the look, `size` picks the metrics.** Both are enums named')
    w('  after the component (`BCButtonVariant`, `BCButtonSize`).')
    w('- **State is controlled.** Widgets take a value plus a change callback')
    w('  (`isSelected` + `onSelectedChange`, `value` + `onValueChange`) and never own')
    w('  their state, except where a controller is explicitly provided.')
    w('- **Disabled is `isDisabled`, invalid is `isInvalid`** — never `enabled: false`.')
    w('- **Compound components** (Card, TextField, InputOTP, Dialog, Menu) are built')
    w('  from named parts you compose as children, mirroring heroui-native.')
    w('- **Pickers share one `presentation`.** `BCDateField`, `BCTimeField` and')
    w('  `BCDateTimePicker` all take a `BCPickerPresentation` — `dialog`,')
    w('  `popover` or `bottomSheet` — and behave the same way in each.')
    w('- **Continuous corners everywhere.** Radii come from `BCRadius` and are drawn')
    w('  with `BCShapes.continuous` (Apple-style squircles), not plain circles.')
    w('')
    return out


def render_setup():
    """`### Installing the theme` + `### BCThemeOverrides`."""
    out = []
    w = out.append

    w('### Installing the theme')
    w('')
    w('```dart')
    w('''MaterialApp(
  theme: BCTheme.light(),
  darkTheme: BCTheme.dark(),
  themeMode: ThemeMode.system,
  // Only needed if you use BCToast:
  builder: (context, child) => BCToastProvider(child: child!),
  home: const HomeScreen(),
);''')
    w('```')
    w('')
    w('### `BCThemeOverrides`')
    w('')
    w('```dart')
    w('''BCTheme.light(
  overrides: BCThemeOverrides(
    accent: const Color(0xFF0F766E), // hover/soft/focus tokens are recomputed
    fontFamily: 'SF Pro Text',       // defaults to the bundled Inter
  ),
);''')
    w('```')
    w('')
    w(props_table('BCThemeOverrides'))
    w('')
    return out


def render_reading_snippet():
    """Just the `### Reading tokens` how-to, without the token inventories."""
    out = []
    w = out.append

    w('### Reading tokens')
    w('')
    w('```dart')
    w('''final bc = context.bcTheme; // BCThemeExtension

Container(color: bc.surface);
Text('Hi', style: TextStyle(color: bc.muted));
DecoratedBox(
  decoration: ShapeDecoration(
    color: bc.accentSoft,
    shape: BCShapes.continuous(BCRadius.xxl),
    shadows: bc.surfaceShadow.shadows,
  ),
);''')
    w('```')
    w('')
    w('`context` also exposes `theme`, `colors` (Material `ColorScheme`) and `text`')
    w('(`TextTheme`) for the Material widgets you mix in.')
    w('')
    return out


def render_reading_tokens():
    """`### Reading tokens` + the color and design token summary tables."""
    out = render_reading_snippet()
    w = out.append

    w('### Color tokens')
    w('')
    w('The 64 semantic slots mirror heroui-native\'s `--color-*` variables. Grouped:')
    w('')
    w('| Group | Tokens |')
    w('|---|---|')
    w('| Page | `background`, `backgroundSecondary`, `backgroundTertiary`, `backgroundInverse`, `foreground` |')
    w('| Surfaces | `surface`, `surfaceForeground`, `surfaceHover`, `surfaceSecondary(+Foreground)`, `surfaceTertiary(+Foreground)` |')
    w('| Overlays | `overlay`, `overlayForeground`, `backdrop` |')
    w('| Accent | `accent`, `accentForeground`, `accentHover`, `accentSoft(+Foreground, +Hover)`, `focus`, `link` |')
    w('| Neutral | `defaultColor`, `defaultForeground`, `defaultHover`, `defaultSoft(+Foreground, +Hover)`, `muted`, `segment`, `segmentForeground` |')
    w('| Status | `success`, `warning`, `danger` — each with `Foreground`, `Hover`, `Soft`, `SoftForeground`, `SoftHover` |')
    w('| Fields | `field`, `fieldForeground`, `fieldPlaceholder`, `fieldBorder`, `fieldHover`, `fieldFocus`, `fieldBorderHover`, `fieldBorderFocus` |')
    w('| Lines | `border`, `borderSecondary`, `borderTertiary`, `separator`, `separatorSecondary`, `separatorTertiary` |')
    w('| Elevation | `surfaceShadow`, `overlayShadow`, `fieldShadow` (`BCShadowSet`: `shadows` + optional `innerBorder`) |')
    w('| Metrics | `borderWidth` (1), `opacityDisabled` (0.5) |')
    w('')
    w('### Design tokens')
    w('')
    w('| Class | What it holds |')
    w('|---|---|')
    w('| `BCSpacing` | 4px base unit: `xxs` 2, `xs` 4, `sm` 8, `md` 16, `lg` 24, `xl` 32, `xxl` 48, plus `unit(n)` |')
    w('| `BCRadius` | `xs` 2 → `xxxxl` 32, `field` 14, `full` 999 (base 8) |')
    w('| `BCShapes` | `continuous(radius)` / `continuousFrom(borderRadius)` — squircle borders |')
    w('| `BCTypography` | Inter + tailwind scale: `textXs`…`text4xl`, weights, `trackingTight(size)` |')
    w('| `BCSizes` | Button/input/avatar/spinner metrics |')
    w('| `BCMotion` | heroui timings and spring descriptions (press scale, switch thumb, tabs indicator…) |')
    w('| `BCDuration` | `fast` 150ms, `normal` 250ms, `slow` 400ms |')
    w('| `BCShadows` | Raw light/dark shadow sets behind the theme tokens |')
    w('| `BCBreakpoints` | Layout breakpoints |')
    w('')
    return out


def render_component(name, heading='###', collapse_subparts=True):
    """One `### BCFoo` block: summary, example, props, members, enums, subparts."""
    e = API.get(name)
    if not e:
        return []
    out = []
    w = out.append

    w(f'{heading} {name}')
    w('')
    summary = SUMMARY.get(name) or clean_doc(e.get('doc', ''))
    summary = re.sub(r'\[([^\]]+)\]', r'`\1`', summary)
    if summary:
        w(summary)
        w('')
    if name in EXAMPLES:
        w('```dart')
        w(EXAMPLES[name])
        w('```')
        w('')
    table = props_table(name)
    if table:
        w(table)
        w('')
    for sig, desc in MEMBERS.get(name, []):
        w(f'- `{sig}` — {desc}')
    if name in MEMBERS:
        w('')
    for en in enums_for(name):
        vals = ', '.join(f'`{v}`' for v in ENUMS[en]['values'])
        w(f'**`{en}`** — {vals}')
        w('')
    for sub in SUBPARTS.get(name, []):
        se = API.get(sub)
        if not se:
            continue
        # api.md collapses subparts behind <details>; the agent references
        # spell them out as headings, since nothing collapses in a grep.
        if collapse_subparts:
            w(f'<details><summary><code>{sub}</code></summary>')
        else:
            w(f'{heading}# {sub}')
        w('')
        sdoc = re.sub(r'\[([^\]]+)\]', r'`\1`', clean_doc(se.get('doc', '')))
        if sdoc:
            w(sdoc)
            w('')
        stable = props_table(sub)
        if stable:
            w(stable)
            w('')
        for sig, desc in MEMBERS.get(sub, []):
            w(f'- `{sig}` — {desc}')
        if sub in MEMBERS:
            w('')
        for en in enums_for(sub):
            vals = ', '.join(f'`{v}`' for v in ENUMS[en]['values'])
            w(f'**`{en}`** — {vals}')
            w('')
        if collapse_subparts:
            w('</details>')
            w('')
    return out


def render_section(section, names, heading='##', **kw):
    """A `## Forms` block: every component in it, then a rule."""
    out = [f'{heading} {section}', '']
    for name in names:
        out += render_component(name, heading=heading + '#', **kw)
    out += ['---', '']
    return out


def build_api_md():
    out = []
    out += render_header_and_contents()
    out += render_conventions()
    out += ['## Theme and tokens', '']
    out += render_setup()
    out += render_reading_tokens()
    out += ['---', '']
    for section, names in CATALOG:
        out += render_section(section, names)
    return '\n'.join(out).rstrip() + '\n'


# ---------------------------------------------------------------------------
# Agent skill (skills/bc-ui) — same extraction, split for progressive disclosure
# ---------------------------------------------------------------------------

VERSION = re.search(r'^version:\s*(\S+)', open('pubspec.yaml').read(), re.M).group(1)

SKILL_DIR = 'skills/bc-ui'
REF_DIR = SKILL_DIR + '/references'

# Forms is by far the largest section (~600 lines). The pickers are a
# self-contained cluster sharing one BCPickerPresentation, so they get their
# own file — that halves the read cost of the common case, building a text
# form. doc/api.md keeps its original seven sections.
PICKERS = [
    'BCDateField', 'BCTimeField', 'BCDateTimePicker',
    'BCDateTimeWheel', 'BCCalendar', 'BCTimeWheel',
]


def reference_specs():
    """(slug, title, [component names]) for each reference file."""
    specs = []
    for section, names in CATALOG:
        if section == 'Forms':
            specs.append(('forms', 'Forms',
                          [n for n in names if n not in PICKERS]))
            specs.append(('pickers', 'Date and time pickers',
                          [n for n in names if n in PICKERS]))
        else:
            specs.append((section.lower().replace(' ', '-'), section, names))
    return specs


def skill_header(title):
    return [
        f'<!-- Generated by tool/gen_api_doc.py from bc_ui {VERSION}. Do not edit. -->',
        '',
        f'# {title} — bc_ui reference',
        '',
    ]


def build_reference(title, names):
    out = skill_header(title)
    present = [n for n in names if n in API]
    out.append('Components: ' + ', '.join(f'`{n}`' for n in present) + '.')
    out.append('')
    for name in present:
        out += render_component(name, heading='##', collapse_subparts=False)
    return '\n'.join(out).rstrip() + '\n'


def promote(lines):
    """`### Foo` -> `## Foo`: these blocks sit under a `##` in api.md, but head
    their own file in the skill."""
    return [re.sub(r'^### ', '## ', l) for l in lines]


def build_setup_md():
    out = skill_header('Setup and theming')
    out += promote(render_setup())
    out += promote(render_reading_snippet())
    return '\n'.join(out).rstrip() + '\n'


def class_fields(name):
    """(field, type, doc) for every `final` field on a class."""
    body = API.get(name, {}).get('body', '')
    found = []
    for m in re.finditer(
        r'((?:[ \t]*///[^\n]*\n)*)[ \t]*(?:final|late final)\s+'
        r'([\w<>,\?\s\.]+?)\s+(\w+)\s*;',
        body,
    ):
        doc = ' '.join(l.strip()[3:].strip()
                       for l in m.group(1).strip().split('\n') if l.strip())
        found.append((m.group(3), re.sub(r'\s+', ' ', m.group(2)).strip(), doc))
    return found


def static_consts(name):
    """(name, type, value, doc) for every `static const` on a token class."""
    body = API.get(name, {}).get('body', '')
    found = []
    for m in re.finditer(
        # The type annotation is optional — `static const buttonSm = 36.0;`.
        r'((?:[ \t]*///[^\n]*\n)*)[ \t]*static const\s+(?:([\w<>?]+)\s+)?(\w+)\s*=\s*([^;]+);',
        body,
    ):
        doc = ' '.join(l.strip()[3:].strip()
                       for l in m.group(1).strip().split('\n') if l.strip())
        found.append((m.group(3), m.group(2) or '',
                      re.sub(r'\s+', ' ', m.group(4).strip()), doc))
    return found


TOKEN_CLASSES = [
    ('BCSpacing', 'Spacing — 4px base unit. Also `BCSpacing.unit(n)`.'),
    ('BCRadius', 'Corner radii. Draw them with `BCShapes.continuous(...)`.'),
    ('BCSizes', 'Component metrics — button, input, avatar and spinner sizes.'),
    ('BCDuration', 'Animation durations.'),
    ('BCBreakpoints', 'Layout breakpoints.'),
]


def build_tokens_md():
    out = skill_header('Design tokens')
    out.append('Every name below is real and current. If a token you want is not')
    out.append('here, it does not exist — compose from what is, never hard-code a')
    out.append('literal colour, radius, spacing or duration.')
    out.append('')
    out += promote(render_reading_snippet())

    fields = class_fields('BCThemeExtension')
    colors = [f for f in fields if f[1] == 'Color']
    others = [f for f in fields if f[1] != 'Color']

    out.append(f'## Semantic colours ({len(colors)})')
    out.append('')
    out.append('Reached as `context.bcTheme.<name>`. Light and dark are resolved for')
    out.append('you — there is never a reason to branch on brightness yourself. The')
    out.append('`*Foreground` of a slot is what stays legible on top of it.')
    out.append('')
    out.append(', '.join(f'`{f[0]}`' for f in colors) + '.')
    out.append('')

    if others:
        out.append('## Other theme slots')
        out.append('')
        out.append('| Slot | Type | Notes |')
        out.append('|---|---|---|')
        for fname, ftype, doc in others:
            out.append(f'| `{fname}` | {code(ftype)} | {esc(doc)} |')
        out.append('')

    for cname, blurb in TOKEN_CLASSES:
        consts = static_consts(cname)
        if not consts:
            continue
        out.append(f'## `{cname}`')
        out.append('')
        out.append(blurb)
        out.append('')
        out.append('| Constant | Value | Notes |')
        out.append('|---|---|---|')
        for kname, _, value, doc in consts:
            out.append(f'| `{cname}.{kname}` | `{value}` | {esc(doc)} |')
        out.append('')

    out.append('## Shapes, type and motion')
    out.append('')
    out.append('- `BCShapes.continuous(radius, {side})` / '
               '`BCShapes.continuousFrom(borderRadius, {side})` — the only')
    out.append('  sanctioned way to build corners. Never `BorderRadius.circular`.')
    out.append('- `BCTypography` — Inter plus the tailwind scale: `textXs`…`text4xl`,')
    out.append('  `regular`/`medium`/`semiBold`/`bold`, `trackingTight(fontSize)`.')
    out.append('  Prefer `BCText` over a raw `Text` + `TextStyle`.')
    out.append('- `BCMotion` — ported springs and timings (`pressScale`,')
    out.append('  `switchThumbSpring`, `timingCurve`, …). Use these rather than')
    out.append('  inventing a curve, so motion matches the rest of the library.')
    out.append('- `BCShadowSet` — `shadows` (a `List<BoxShadow>`) plus an optional')
    out.append('  `innerBorder`. Apply both; dark mode leans on the inner border.')
    out.append('')
    return '\n'.join(out).rstrip() + '\n'


def scan_balanced(s, start):
    """End index of the `(`-group opened just before `start`, skipping strings.

    Assert messages routinely contain unbalanced parens — "(paired with a
    BCTabView)" — so depth counting has to know when it is inside a literal.
    Commas at depth 0, outside strings, are recorded on the way past.
    """
    i, depth, commas, quote = start, 1, [], ''
    while i < len(s) and depth:
        ch = s[i]
        if quote:
            if ch == '\\':
                i += 1
            elif ch == quote:
                quote = ''
        elif ch in '\'"':
            quote = ch
        elif ch in '([{':
            depth += 1
        elif ch in ')]}':
            depth -= 1
        elif ch == ',' and depth == 1:
            commas.append(i)
        i += 1
    return i - 1, commas


def asserts_for(name):
    """(condition, message) for each `assert` in a class body."""
    body = re.sub(r'///[^\n]*', '', API.get(name, {}).get('body', ''))
    found = []
    for m in re.finditer(r'\bassert\(', body):
        end, commas = scan_balanced(body, m.end())
        inner = body[m.end():end]
        cond, msg = inner, ''
        # The message, when present, is the trailing string-literal argument.
        for c in reversed(commas):
            tail = body[c + 1:end].strip()
            if tail.startswith(("'", '"')):
                cond, msg = body[m.end():c], tail
                break
        cond = re.sub(r'\s+', ' ', cond.strip()).rstrip(',')
        # Dart concatenates adjacent literals; stitch them back together.
        chunks = re.findall(r"'((?:[^'\\]|\\.)*)'|\"((?:[^\"\\]|\\.)*)\"", msg)
        msg = ''.join(a or b for a, b in chunks)
        found.append((cond, re.sub(r'\s+', ' ', msg.replace("\\'", "'")).strip()))
    return [(c, m) for c, m in found if c]


# Traps a parser cannot infer: things that compile, run, and quietly do the
# wrong thing. Each entry is (component, what goes wrong / what to do).
GOTCHAS = [
    ('Theme', 'Every BC widget resolves its colours through `context.bcTheme`, '
     'which ends in a null assertion. Under a bare `MaterialApp` — or a widget '
     'test that forgets `theme: BCTheme.light()` — every one of them throws. '
     'There is no graceful fallback by design.'),
    ('BCToast', '`BCToast.show` finds its host with an ancestor-state lookup and '
     '`assert`s when it is missing. In a release build the assert is stripped and '
     'the call becomes a silent no-op — no toast, no error. Mount '
     '`BCToastProvider` via `MaterialApp.builder` before using it. Note the '
     'provider defaults to `BCToastPlacement.bottom`.'),
    ('BCTextFieldError', 'Renders `SizedBox.shrink()` unless its parent '
     '`BCTextField` has `isInvalid: true`. Setting the message alone shows '
     'nothing — flip `isInvalid` on the parent at the same time. This is the '
     'single most common "my validation message never appears" bug.'),
    ('Compound parts', '`BCTextFieldLabel` / `BCTextFieldInput` / '
     '`BCTextFieldDescription`, `BCRadio`, `BCMenuItem`, `BCInputOTPSlot*`, '
     '`BCAvatarImage` / `BCAvatarFallback` and `BCCard*` all read an inherited '
     'scope from their parent. Used standalone they do not throw — they fall '
     'back to neutral defaults or render nothing, and a `BCRadio` outside a '
     '`BCRadioGroup` simply ignores taps. Always compose them under their parent.'),
    ('BCAccordion', '`BCAccordionContent` is unmounted while its item is '
     'collapsed — heroui does the same — so anything stateful inside it (a '
     'text field\'s contents, a scroll offset, a playing video) is rebuilt '
     'from scratch on every expand. Lift that state above the accordion. The '
     'content is laid out at its natural height, so an unbounded-height child '
     'such as a bare `ListView` throws: give it `shrinkWrap: true` or a fixed '
     'height. And the accordion stretches its children to its own width, so '
     'inside a `Row` it needs an `Expanded`.'),
    ('BCAppHeader', 'The frosted variants need something to blur: pair with '
     '`Scaffold(extendBodyBehindAppBar: true)`. The body then sits behind the '
     'header, so pad it yourself by '
     '`MediaQuery.paddingOf(context).top + BCAppHeader.defaultToolbarHeight` '
     '(56). Skipping this hides your first rows under the header.'),
    ('Generics', '`BCTabs<T>`, `BCTabView<T>`, `BCSelect<T>`, `BCRadioGroup<T>` '
     'and `BCTagGroup<T>` infer `T` from their items. With `const` item lists '
     'inference can land on the wrong type — write the type argument explicitly.'),
    ('Controllers', '`BCTabsController` owns a `PageController`; create it in a '
     '`State` and dispose it there. Hand it to a `BCTabView`, not to a bare '
     '`PageView` you also drive. `BCAnchoredOverlayController` (for `BCPopover`, '
     '`BCMenu`, `BCSelect`) is a `ChangeNotifier` with `open()` / `close()` / '
     '`toggle()` / `isOpen`, reached through the `trigger: (context, controller)` '
     'builder — dispose it the same way.'),
]

INTERNAL = [
    'BCAnchoredOverlay', 'BCPickerPanel', 'BCPickerSheet', 'BCSvgPath',
    'BCColorSchemes', 'BCColorsLight', 'BCColorsDark', 'BCTextStyles',
    'BCAppBarTheme', 'BCAvatarTheme', 'BCSkeletonTheme', 'BCInputOTPTheme',
]


def build_gotchas_md():
    out = skill_header('Traps')
    out.append('Failures here compile cleanly and often run without an error, so')
    out.append('the analyzer will not save you. Read this before debugging a')
    out.append('bc_ui widget that renders but looks wrong.')
    out.append('')
    out.append('## Silent failures')
    out.append('')
    for subject, text in GOTCHAS:
        out.append(f'- **{subject}.** {text}')
    out.append('')

    out.append('## Constructor and build asserts')
    out.append('')
    out.append('These throw loudly in debug. Extracted from the source, so the')
    out.append('list stays complete as the library grows.')
    out.append('')
    out.append('| Component | Rule | Message |')
    out.append('|---|---|---|')
    scanned = []
    for _, names in CATALOG:
        scanned += names
    scanned += [s for subs in SUBPARTS.values() for s in subs]
    scanned += ['BCTabsController', 'BCToast', 'BCThemeExtension']
    for name in dict.fromkeys(scanned):
        for cond, msg in asserts_for(name):
            out.append(f'| `{name}` | {code(cond)} | {esc(msg)} |')
    out.append('')

    out.append('## Not public API')
    out.append('')
    out.append('Exported or reachable, but internal — do not use these, they will')
    out.append('change without a version bump:')
    out.append('')
    out.append(', '.join(f'`{n}`' for n in INTERNAL) + '.')
    out.append('')
    return '\n'.join(out).rstrip() + '\n'


CATALOG_BEGIN = '<!-- BEGIN GENERATED: catalog -->'
CATALOG_END = '<!-- END GENERATED -->'


def build_catalog_block():
    """The routing table spliced into SKILL.md."""
    out = [CATALOG_BEGIN, '']
    out.append(f'Generated from bc_ui {VERSION}.')
    out.append('')
    out.append('| Read this file | For these components |')
    out.append('|---|---|')
    out.append('| `references/setup.md` | `BCTheme`, `BCThemeOverrides`, `BCToastProvider` |')
    out.append('| `references/tokens.md` | `context.bcTheme` colours, `BCSpacing`, `BCRadius`, `BCShapes`, `BCTypography`, `BCSizes`, `BCMotion`, `BCDuration`, `BCBreakpoints` |')
    for slug, title, names in reference_specs():
        present = [n for n in names if n in API]
        out.append(f'| `references/{slug}.md` | ' +
                   ', '.join(f'`{n}`' for n in present) + ' |')
    out.append('| `references/gotchas.md` | Silent failures, asserts, internal-only names |')
    out.append('')
    out.append(CATALOG_END)
    return '\n'.join(out)


def splice_catalog(path):
    """Rewrite the generated parts of SKILL.md in place."""
    text = open(path).read()
    if CATALOG_BEGIN not in text or CATALOG_END not in text:
        sys.exit(f'{path}: missing {CATALOG_BEGIN} / {CATALOG_END} markers')
    head = text.split(CATALOG_BEGIN)[0]
    tail = text.split(CATALOG_END, 1)[1]
    out = head + build_catalog_block() + tail
    # The prose count sits outside the markers and had drifted four past the
    # real number, so it is rewritten from the catalog too. --check catches it
    # the next time a component lands.
    count = sum(len(names) for _, names in CATALOG)
    return re.sub(r'(~?)\d+ components',
                  lambda m: f'{m.group(1)}{count} components', out)


def targets():
    out = [('doc/api.md', build_api_md()),
           (f'{REF_DIR}/setup.md', build_setup_md()),
           (f'{REF_DIR}/tokens.md', build_tokens_md()),
           (f'{REF_DIR}/gotchas.md', build_gotchas_md())]
    for slug, title, names in reference_specs():
        out.append((f'{REF_DIR}/{slug}.md', build_reference(title, names)))
    skill = f'{SKILL_DIR}/SKILL.md'
    if os.path.exists(skill):
        out.append((skill, splice_catalog(skill)))
    return out


def undocumented():
    """Public BC* symbols in lib/src that no output mentions."""
    known = set(INTERNAL)
    for _, names in CATALOG:
        known.update(names)
    known.update(s for subs in SUBPARTS.values() for s in subs)
    known.update(MEMBERS)
    known.update(ENUMS)
    known.update(['BCTheme', 'BCThemeOverrides', 'BCThemeExtension',
                  'BCShapes', 'BCShadows', 'BCShadowSet', 'BCMotion',
                  'BCSpacing', 'BCRadius', 'BCSizes', 'BCDuration',
                  'BCTypography', 'BCBreakpoints'])
    return sorted(n for n in API if n.startswith('BC') and n not in known)


if __name__ == '__main__':
    args = sys.argv[1:]
    if '--check-coverage' in args:
        missing = undocumented()
        for name in missing:
            print('undocumented:', name)
        sys.exit(1 if missing else 0)

    built = targets()
    if '--check' in args:
        stale = [p for p, body in built
                 if not os.path.exists(p) or open(p).read() != body]
        for p in stale:
            print('stale:', p)
        if stale:
            print('\nRun `python3 tool/gen_api_doc.py` and commit the result.')
        sys.exit(1 if stale else 0)

    for path, body in built:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, 'w').write(body)
    print(f'wrote {len(built)} files from {len(API)} symbols (bc_ui {VERSION})')
