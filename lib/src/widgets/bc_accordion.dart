import 'dart:collection';

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_motion.dart';
import 'bc_pressable.dart';
import 'bc_separator.dart';
import 'bc_surface.dart';

/// How many [BCAccordionItem]s a [BCAccordion] keeps open at once.
enum BCAccordionSelectionMode { single, multiple }

/// A [BCAccordion]'s look. `default` is a reserved word in Dart, so heroui's
/// `default` variant is [defaultVariant] — the same rename [BCSurfaceVariant]
/// uses.
enum BCAccordionVariant { defaultVariant, surface }

/// Owns a [BCAccordion]'s set of expanded item values, so the accordion can be
/// driven from outside without lifting the set into your own `setState`.
///
/// Create one in a [State] and dispose it there:
///
/// ```dart
/// final _faq = BCAccordionController(initialValue: const {'shipping'});
///
/// @override
/// void dispose() {
///   _faq.dispose();
///   super.dispose();
/// }
/// ```
///
/// heroui's uncontrolled `defaultValue="2"` is `initialValue: {'2'}` here.
///
/// There is deliberately no `toggle`: toggling depends on
/// [BCAccordion.selectionMode] and [BCAccordion.isCollapsible], which live on
/// the widget, so tapping a [BCAccordionTrigger] is the only thing that
/// applies them. [expand] and [collapse] set one item without consulting
/// either.
class BCAccordionController extends ChangeNotifier {
  BCAccordionController({Set<String> initialValue = const <String>{}})
      : _value = Set<String>.of(initialValue);

  Set<String> _value;

  /// The expanded item values. Assign a new set to change them — the view
  /// returned here is unmodifiable, so mutating it in place is not an option.
  Set<String> get value => UnmodifiableSetView<String>(_value);

  set value(Set<String> next) {
    if (setEquals(_value, next)) return;
    _value = Set<String>.of(next);
    notifyListeners();
  }

  /// Whether the item with this value is expanded.
  bool isExpanded(String value) => _value.contains(value);

  /// Opens one item, leaving the others alone. This does not apply
  /// [BCAccordion.selectionMode]: in single-selection mode it is on you to
  /// collapse whatever else is open.
  void expand(String value) {
    if (_value.contains(value)) return;
    _value = {..._value, value};
    notifyListeners();
  }

  /// Closes one item.
  void collapse(String value) {
    if (!_value.contains(value)) return;
    _value = {..._value}..remove(value);
    notifyListeners();
  }

  /// Closes everything.
  void collapseAll() {
    if (_value.isEmpty) return;
    _value = <String>{};
    notifyListeners();
  }
}

/// HeroUI Native Accordion (accordion.css / accordion.constants.ts): a column
/// of collapsible sections.
///
/// Plain by default; `surface` wraps the stack in a [BCSurface] — surface fill,
/// 24px continuous corners, surface shadow — and insets the separators by
/// 12px. Hairline separators sit between items, never after the last one.
///
/// Each item's content springs open (mass 4, stiffness 1600, damping 140 —
/// heroui's `ACCORDION_LAYOUT_TRANSITION`) while fading in over 200ms, and the
/// chevron rotates 0 → -180° on its own softer spring (mass 4, stiffness 1000,
/// damping 140). heroui gets the height change free from Reanimated's layout
/// transition; here it is an explicit [SizeTransition] on the same spring.
///
/// State is yours: pass either [value] + [onValueChange], or a
/// [BCAccordionController]. The widget holds none of its own.
///
/// ```dart
/// BCAccordion(
///   value: _expanded,
///   onValueChange: (value) => setState(() => _expanded = value),
///   variant: BCAccordionVariant.surface,
///   children: const [
///     BCAccordionItem(
///       value: 'shipping',
///       children: [
///         BCAccordionTrigger(child: Text('How much does shipping cost?')),
///         BCAccordionContent(child: Text('Free over \$50.')),
///       ],
///     ),
///   ],
/// );
/// ```
///
/// Deliberate departures from heroui, all cosmetic or structural rather than
/// behavioural: the trigger presses with a highlight overlay
/// ([BCPressFeedback.highlight]) instead of a bare `Pressable`; disabled items
/// dim to `opacityDisabled` (heroui only sets `aria-disabled`); the default
/// variant has no root clip, because each content's own [SizeTransition]
/// already clips; and there is no `z-index: 10` analogue on the trigger — with
/// the content anchored to the top of its clip rect it can never paint over
/// the trigger anyway.
///
/// The accordion stretches its children to its own width, so it needs a
/// bounded width: inside a [Row] it must be wrapped in an [Expanded].
class BCAccordion extends StatefulWidget {
  const BCAccordion({
    super.key,
    required this.children,
    this.value,
    this.onValueChange,
    this.controller,
    this.selectionMode = BCAccordionSelectionMode.single,
    this.variant = BCAccordionVariant.defaultVariant,
    this.hideSeparator = false,
    this.isCollapsible = true,
    this.isDisabled = false,
  })  : assert(
          (value == null) != (controller == null),
          'BCAccordion needs either value (you own the expanded set and pass '
          'onValueChange) or a BCAccordionController (it owns the set), not '
          'both and not neither',
        ),
        assert(
          selectionMode == BCAccordionSelectionMode.multiple ||
              value == null ||
              value.length <= 1,
          'A single-selection BCAccordion expands at most one item; pass a '
          'value holding one item or fewer, or switch to '
          'BCAccordionSelectionMode.multiple',
        );

  /// The [BCAccordionItem]s. Anything else is rendered as-is and still counts
  /// for separator placement, matching heroui's `Children.map`.
  final List<Widget> children;

  /// The expanded item values; empty means everything is closed. Mutually
  /// exclusive with [controller].
  final Set<String>? value;

  /// Called with the next expanded set. Pair it with [value].
  final ValueChanged<Set<String>>? onValueChange;

  /// Owns the expanded set instead of [value]. Dispose it with the [State]
  /// that created it.
  final BCAccordionController? controller;

  final BCAccordionSelectionMode selectionMode;
  final BCAccordionVariant variant;

  /// Hides the hairline lines drawn between items.
  final bool hideSeparator;

  /// When false, tapping the open item leaves it open (heroui's
  /// `isCollapsible`), so the accordion always has something expanded once
  /// the first item is opened.
  final bool isCollapsible;

  /// Dims every item and stops them responding to taps.
  final bool isDisabled;

  @override
  State<BCAccordion> createState() => _BCAccordionState();
}

class _BCAccordionState extends State<BCAccordion> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(BCAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  Set<String> get _value => widget.controller?.value ?? widget.value!;

  /// A direct port of the primitive trigger's `onPress`
  /// (primitives/accordion/accordion.tsx), including the non-collapsible
  /// branches: single mode re-selects the same value, multiple mode dedupes.
  void _handleToggle(String itemValue) {
    final current = _value;
    final Set<String> next;

    switch (widget.selectionMode) {
      case BCAccordionSelectionMode.single:
        next = widget.isCollapsible && current.contains(itemValue)
            ? const <String>{}
            : <String>{itemValue};
      case BCAccordionSelectionMode.multiple:
        next = Set<String>.of(current);
        if (widget.isCollapsible && current.contains(itemValue)) {
          next.remove(itemValue);
        } else {
          next.add(itemValue);
        }
    }

    final controller = widget.controller;
    if (controller != null) {
      controller.value = next;
    } else {
      widget.onValueChange?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final isSurface = widget.variant == BCAccordionVariant.surface;

    Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.children.length; i++) ...[
          widget.children[i],
          if (!widget.hideSeparator && i < widget.children.length - 1)
            BCSeparator(
              // `.accordion__root-separator--variant-surface` insets the line
              // by `--spacing * 3`.
              margin: isSurface
                  ? const EdgeInsets.symmetric(horizontal: 12)
                  : null,
            ),
        ],
      ],
    );

    if (isSurface) {
      column = BCSurface(padding: EdgeInsets.zero, child: column);
    }

    if (widget.isDisabled) {
      column = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: column),
      );
    }

    return _BCAccordionScope(
      value: _value,
      variant: widget.variant,
      selectionMode: widget.selectionMode,
      isCollapsible: widget.isCollapsible,
      isDisabled: widget.isDisabled,
      onToggle: _handleToggle,
      child: column,
    );
  }
}

/// One collapsible section: usually a [BCAccordionTrigger] followed by a
/// [BCAccordionContent].
///
/// Outside a [BCAccordion] it still renders, but nothing can ever expand it —
/// the house behaviour for compound parts.
class BCAccordionItem extends StatelessWidget {
  const BCAccordionItem({
    super.key,
    required this.value,
    this.children,
    this.builder,
    this.isDisabled = false,
  }) : assert(
          (children == null) != (builder == null),
          'BCAccordionItem takes either children or builder, not both and not '
          'neither',
        );

  /// Identifies this item in [BCAccordion.value]. Two items sharing a value
  /// expand together — heroui behaves the same way.
  final String value;

  /// The section's parts, stacked in a column. Mutually exclusive with
  /// [builder].
  final List<Widget>? children;

  /// heroui's render-function child: rebuilt with this item's expanded state.
  /// Reach for it when the whole section changes shape when open; for a single
  /// part that cares, [isExpandedOf] is lighter.
  final Widget Function(BuildContext context, bool isExpanded)? builder;

  /// Dims this item and stops it responding to taps.
  final bool isDisabled;

  /// Whether the enclosing [BCAccordionItem] is expanded — the equivalent of
  /// heroui's `useAccordionItem()` hook. False outside an item.
  ///
  /// Use it to build a custom indicator, which [BCAccordionIndicator] does not
  /// rotate for you:
  ///
  /// ```dart
  /// BCAccordionTrigger(
  ///   child: const Text('Details'),
  ///   indicator: Builder(
  ///     builder: (context) => Icon(
  ///       BCAccordionItem.isExpandedOf(context) ? Icons.remove : Icons.add,
  ///       size: 16,
  ///     ),
  ///   ),
  /// );
  /// ```
  static bool isExpandedOf(BuildContext context) =>
      _BCAccordionItemScope.of(context)?.isExpanded ?? false;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final scope = _BCAccordionScope.of(context);
    final isExpanded = scope?.value.contains(value) ?? false;

    Widget body = builder?.call(context, isExpanded) ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children!,
        );

    // A disabled root dims the whole stack once, at the root — dimming again
    // here would double up.
    if (isDisabled) {
      body = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: body),
      );
    }

    return _BCAccordionItemScope(
      value: value,
      isExpanded: isExpanded,
      isDisabled: isDisabled || (scope?.isDisabled ?? false),
      child: body,
    );
  }
}

/// The row that toggles its [BCAccordionItem]: [child] on the leading side,
/// the indicator flush to the trailing edge.
///
/// 16px vertical padding, 12px horizontal (20px in the surface variant), 16px
/// gap — `.accordion__trigger`.
class BCAccordionTrigger extends StatelessWidget {
  const BCAccordionTrigger({
    super.key,
    required this.child,
    this.indicator,
    this.hideIndicator = false,
    this.isDisabled = false,
    this.onPressed,
    this.feedback = BCPressFeedback.highlight,
  });

  /// Leading content. It expands to fill, so the indicator sits flush right
  /// (heroui's `justify-content: space-between`).
  final Widget child;

  /// Defaults to a [BCAccordionIndicator] — a chevron that rotates with the
  /// item.
  final Widget? indicator;

  /// Renders no indicator at all. Distinct from `indicator: null`, which just
  /// falls back to the default.
  final bool hideIndicator;

  final bool isDisabled;

  /// Runs after the item has toggled — heroui's `onPress` passthrough.
  final VoidCallback? onPressed;

  /// Defaults to [BCPressFeedback.highlight]: a full-width row that scales
  /// looks wrong, and it is what heroui's own example uses.
  final BCPressFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final root = _BCAccordionScope.of(context);
    final item = _BCAccordionItemScope.of(context);
    final isSurface = root?.variant == BCAccordionVariant.surface;
    final disabled = isDisabled || (item?.isDisabled ?? false);

    final row = Padding(
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: isSurface ? 20 : 12,
      ),
      child: Row(
        spacing: 16,
        children: [
          Expanded(child: child),
          if (!hideIndicator) indicator ?? const BCAccordionIndicator(),
        ],
      ),
    );

    return BCPressable(
      feedback: feedback,
      // heroui's example drives PressableFeedback.Highlight with
      // `opacity: { value: [0, 0.05] }` over the default theme-aware gray.
      highlightOpacityRange: const (0, 0.05),
      enabled: !disabled && item != null,
      onPressed: disabled || item == null
          ? null
          : () {
              root?.onToggle(item.value);
              onPressed?.call();
            },
      child: row,
    );
  }
}

/// The chevron at the trailing edge of a [BCAccordionTrigger], rotating
/// 0 → -180° on a spring (mass 4, stiffness 1000, damping 140) as its item
/// expands.
///
/// The rotation really is counter-clockwise. `INDICATOR_ROTATION` in heroui's
/// `accordion.constants.ts` reads `180deg`, but nothing imports it — the live
/// default rotates 0 to -180 degrees, in `accordion.animation.ts`.
class BCAccordionIndicator extends StatefulWidget {
  const BCAccordionIndicator({super.key, this.child, this.size = 16, this.color});

  /// A custom indicator, which is **not** rotated — heroui does the same.
  /// Animate it yourself off [BCAccordionItem.isExpandedOf].
  final Widget? child;

  /// heroui's `DEFAULT_ICON_SIZE`.
  final double size;

  /// Defaults to the `foreground` token.
  final Color? color;

  @override
  State<BCAccordionIndicator> createState() => _BCAccordionIndicatorState();
}

class _BCAccordionIndicatorState extends State<BCAccordionIndicator>
    with SingleTickerProviderStateMixin {
  /// 0 = collapsed, 1 = expanded.
  late final AnimationController _progress = AnimationController(vsync: this);
  bool? _wasExpanded;

  // The expanded flag arrives through an InheritedWidget rather than a prop,
  // so the house didUpdateWidget spring idiom would never fire here.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isExpanded = BCAccordionItem.isExpandedOf(context);
    if (_wasExpanded == isExpanded) return;

    final isFirstBuild = _wasExpanded == null;
    _wasExpanded = isExpanded;
    final target = isExpanded ? 1.0 : 0.0;

    if (isFirstBuild || MediaQuery.disableAnimationsOf(context)) {
      _progress.value = target;
      return;
    }

    final spring = SpringSimulation(
      BCMotion.accordionIndicatorSpring,
      _progress.value,
      target,
      0,
      snapToEnd: true,
    );
    isExpanded
        ? _progress.animateWith(spring)
        : _progress.animateBackWith(spring);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (child != null) {
      // Align rather than Center: a Center in a Row gets unbounded main-axis
      // constraints.
      return Align(widthFactor: 1, heightFactor: 1, child: child);
    }

    return RotationTransition(
      turns: _progress.drive(Tween<double>(begin: 0, end: -0.5)),
      child: Icon(
        Icons.keyboard_arrow_down,
        size: widget.size,
        color: widget.color ?? context.bcTheme.foreground,
      ),
    );
  }
}

/// The body revealed when its [BCAccordionItem] expands.
///
/// Height springs on heroui's `ACCORDION_LAYOUT_TRANSITION` (mass 4,
/// stiffness 1600, damping 140) while the body fades over 200ms — `easeOut`
/// in, `easeIn` out, the exact equivalents of Reanimated's
/// `Easing.out(Easing.ease)` / `Easing.in(Easing.ease)`.
///
/// The subtree is built on first expand and dropped once a collapse settles,
/// mirroring heroui rendering `null` while closed. Anything stateful inside —
/// a text field's contents, a scroll offset — is therefore rebuilt from
/// scratch on the next expand; lift that state above the accordion. The
/// content is also laid out at its natural height, so an unbounded-height
/// child such as a bare [ListView] needs `shrinkWrap: true` or a fixed height.
class BCAccordionContent extends StatefulWidget {
  const BCAccordionContent({super.key, required this.child, this.padding});

  final Widget child;

  /// Defaults to 12px start/end (20px in the surface variant) and 16px bottom
  /// — `.accordion__content`.
  final EdgeInsetsGeometry? padding;

  @override
  State<BCAccordionContent> createState() => _BCAccordionContentState();
}

class _BCAccordionContentState extends State<BCAccordionContent>
    with TickerProviderStateMixin {
  /// 0 = fully collapsed, 1 = natural height. Driven by a spring, so it has no
  /// duration of its own.
  late final AnimationController _size = AnimationController(vsync: this);
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: BCMotion.accordionContentFadeDuration,
  );
  late final CurvedAnimation _opacity = CurvedAnimation(
    parent: _fade,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  bool? _wasExpanded;

  /// Whether the subtree is built. Stays true through a collapse so the fade
  /// has something to fade.
  bool _isVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isExpanded = _BCAccordionItemScope.of(context)?.isExpanded ?? false;
    if (_wasExpanded == isExpanded) return;

    final isFirstBuild = _wasExpanded == null;
    _wasExpanded = isExpanded;
    final target = isExpanded ? 1.0 : 0.0;

    if (isFirstBuild || MediaQuery.disableAnimationsOf(context)) {
      _size.value = target;
      _fade.value = target;
      // A build always follows didChangeDependencies, so no setState.
      _isVisible = isExpanded;
      return;
    }

    if (isExpanded) {
      _isVisible = true;
      _size.animateWith(_spring(target));
      _fade.forward();
    } else {
      _fade.reverse();
      // animateBackWith, not animateWith: the latter forces the controller's
      // direction to forward, so a spring settling on 0 reports `completed`
      // and isDismissed would never become true.
      _size.animateBackWith(_spring(target)).whenCompleteOrCancel(() {
        if (mounted && _isVisible && _size.isDismissed) {
          setState(() => _isVisible = false);
        }
      });
    }
  }

  SpringSimulation _spring(double target) => SpringSimulation(
        BCMotion.accordionSpring,
        _size.value,
        target,
        0,
        snapToEnd: true,
      );

  @override
  void dispose() {
    _opacity.dispose();
    _size.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final isSurface =
        _BCAccordionScope.of(context)?.variant == BCAccordionVariant.surface;
    final inline = isSurface ? 20.0 : 12.0;

    return SizeTransition(
      sizeFactor: _size,
      // Top-anchored, so the body is revealed downward from under the trigger.
      // Centre alignment — the default — would reveal it from its own middle.
      alignment: AlignmentDirectional.topStart,
      child: FadeTransition(
        opacity: _opacity,
        child: Padding(
          padding: widget.padding ??
              EdgeInsetsDirectional.only(
                start: inline,
                end: inline,
                bottom: 16,
              ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Root state, shared with every part below it.
class _BCAccordionScope extends InheritedWidget {
  const _BCAccordionScope({
    required this.value,
    required this.variant,
    required this.selectionMode,
    required this.isCollapsible,
    required this.isDisabled,
    required this.onToggle,
    required super.child,
  });

  final Set<String> value;
  final BCAccordionVariant variant;
  final BCAccordionSelectionMode selectionMode;
  final bool isCollapsible;
  final bool isDisabled;

  /// A bound tear-off of the root state's toggle handler: stable across
  /// builds, and always reading the current widget.
  final void Function(String value) onToggle;

  static _BCAccordionScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BCAccordionScope>();

  @override
  bool updateShouldNotify(_BCAccordionScope oldWidget) =>
      // `Set == Set` is identity in Dart, so comparing with != would notify on
      // every single rebuild.
      !setEquals(value, oldWidget.value) ||
      variant != oldWidget.variant ||
      selectionMode != oldWidget.selectionMode ||
      isCollapsible != oldWidget.isCollapsible ||
      isDisabled != oldWidget.isDisabled;
}

/// Per-item state, shared with that item's trigger, indicator and content.
class _BCAccordionItemScope extends InheritedWidget {
  const _BCAccordionItemScope({
    required this.value,
    required this.isExpanded,
    required this.isDisabled,
    required super.child,
  });

  final String value;
  final bool isExpanded;

  /// Item-level or root-level, already combined.
  final bool isDisabled;

  static _BCAccordionItemScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BCAccordionItemScope>();

  @override
  bool updateShouldNotify(_BCAccordionItemScope oldWidget) =>
      isExpanded != oldWidget.isExpanded ||
      value != oldWidget.value ||
      isDisabled != oldWidget.isDisabled;
}
