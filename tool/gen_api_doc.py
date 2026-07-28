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
        r'(?:const\s+)?' + re.escape(name) + r'(?:<[^>]*>)?\(\s*(?:\{)?(.*?)\}?\)\s*(?::|;|\{)',
        body, re.S,
    )
    params = []
    if ctor:
        seen = set()
        for arg in split_args(ctor.group(1)):
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
            params.append({
                'name': pname,
                'required': bool(pm.group(1)),
                'default': re.sub(r'\s+', ' ', (pm.group(3) or '').strip()),
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
                    head = re.sub(r'///[^\n]*|//[^\n]*', '', body.strip('{}').split(';')[0])
                    values = []
                    for part in split_args(head):
                        m2 = re.match(r'\s*(\w+)', part)
                        if m2 and m2.group(1) not in ('final', 'const', 'static'):
                            values.append(m2.group(1))
                    api[name] = {'kind': 'enum', 'doc': doc, 'values': values}
                else:
                    api[name] = {'kind': 'class', 'doc': doc,
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
        'BCButton', 'BCLinkButton', 'BCCloseButton', 'BCFab', 'BCSpeedDial',
        'BCToggleButton', 'BCToggleButtonGroup', 'BCPressable',
    ]),
    ('Containers', [
        'BCSurface', 'BCCard', 'BCListGroup', 'BCFlipCard', 'BCScrollShadow',
    ]),
    ('Data display', [
        'BCText', 'BCAvatar', 'BCChip', 'BCTagGroup', 'BCSeparator',
        'BCSkeleton', 'BCSpinner', 'BCProgress', 'BCLoadingOverlay',
        'BCRating', 'BCEmptyState',
    ]),
    ('Forms', [
        'BCInput', 'BCTextField', 'BCTextArea', 'BCPasswordInput',
        'BCSearchField', 'BCInputOTP', 'BCDateField', 'BCTimeField',
        'BCDateTimePicker', 'BCDateTimeWheel', 'BCCalendar', 'BCTimeWheel',
        'BCSelect', 'BCControlField',
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
    'BCFlipCard': 'Two faces that flip on tap or programmatically.',
    'BCScrollShadow': 'Fades a gradient in at the edges of a scrollable while there is more to scroll.',
    'BCText': 'Typography primitive with the heroui type scale.',
    'BCAvatar': 'Composable avatar: image with a fallback that shows initials while loading or on error.',
    'BCChip': 'Compact pill for status, filters and metadata.',
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
    'BCSelect': 'Anchored dropdown select.',
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
    'BCTabs': ['BCTabItem', 'BCTabsController'],
    'BCNavRail': ['BCNavRailDestination'],
    'BCNavDrawer': [
        'BCNavDrawerDestination', 'BCNavDrawerSection', 'BCNavDrawerDivider',
    ],
    'BCRangeSlider': ['BCRange'],
    'BCBottomNav': ['BCBottomNavItem'],
    'BCAvatar': ['BCAvatarImage', 'BCAvatarFallback'],
    'BCTextField': ['BCTextFieldLabel', 'BCTextFieldInput', 'BCTextFieldDescription', 'BCTextFieldError'],
    'BCInputOTP': ['BCInputOTPGroup', 'BCInputOTPSlot', 'BCInputOTPSeparator'],
    'BCSelect': ['BCSelectItem'],
    'BCTagGroup': ['BCTagItem'],
    'BCSpeedDial': ['BCSpeedDialItem'],
    'BCToggleButtonGroup': ['BCToggleButtonOption'],
    'BCDialog': ['BCDialogContent', 'BCDialogTitle', 'BCDialogDescription'],
    'BCPopover': ['BCPopoverTitle', 'BCPopoverDescription'],
    'BCMenu': ['BCMenuItem', 'BCMenuLabel', 'BCMenuSeparator'],
    'BCToast': ['BCToastData', 'BCToastProvider'],
    'BCEmptyState': ['BCEmptyStateAvatarCluster'],
    'BCSkeleton': ['BCSkeletonGroup'],
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

POSITIONAL = {
    ('BCText', 'data'), ('BCCardTitle', 'text'), ('BCCardDescription', 'text'),
    ('BCDialogTitle', 'text'), ('BCDialogDescription', 'text'),
    ('BCPopoverTitle', 'text'), ('BCPopoverDescription', 'text'),
    ('BCMenuLabel', 'text'), ('BCLabel', 'text'), ('BCDescription', 'text'),
    ('BCFieldError', 'text'), ('BCTextFieldLabel', 'text'),
    ('BCTextFieldDescription', 'text'), ('BCTextFieldError', 'text'),
}


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
    for p in params:
        raw = DEFAULTS.get(p['default'], p['default'])
        default = 'required' if p['required'] else (code(raw) or '—')
        notes = esc(p['doc'])
        if (name, p['name']) in POSITIONAL:
            default = 'required'
            notes = ('First positional argument. ' + notes).strip()
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

w('## Theme and tokens')
w('')
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
w('---')
w('')

for section, names in CATALOG:
    w(f'## {section}')
    w('')
    for name in names:
        e = API.get(name)
        if not e:
            continue
        w(f'### {name}')
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
        ens = enums_for(name)
        if ens:
            for en in ens:
                vals = ', '.join(f'`{v}`' for v in ENUMS[en]['values'])
                w(f'**`{en}`** — {vals}')
                w('')
        subs = SUBPARTS.get(name, [])
        for sub in subs:
            se = API.get(sub)
            if not se:
                continue
            w(f'<details><summary><code>{sub}</code></summary>')
            w('')
            sdoc = re.sub(r'\[([^\]]+)\]', r'`\1`', clean_doc(se.get('doc', '')))
            if sdoc:
                w(sdoc)
                w('')
            stable = props_table(sub)
            if stable:
                w(stable)
                w('')
            for en in enums_for(sub):
                vals = ', '.join(f'`{v}`' for v in ENUMS[en]['values'])
                w(f'**`{en}`** — {vals}')
                w('')
            w('</details>')
            w('')
    w('---')
    w('')

OUT = sys.argv[1] if len(sys.argv) > 1 else 'doc/api.md'
open(OUT, 'w').write('\n'.join(out).rstrip() + '\n')
print('wrote', OUT, f'({len(API)} symbols)')
