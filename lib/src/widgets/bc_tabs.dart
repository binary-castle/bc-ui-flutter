import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_duration.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';

enum BCTabsVariant { primary, secondary }

class BCTabItem<T> {
  const BCTabItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final Widget? icon;
}

/// Shared state for a [BCTabs] bar and the [BCTabView] it drives.
///
/// The controller owns the [PageController], which makes the swipe position
/// the single source of truth: dragging the view moves the tab indicator
/// continuously (it tracks the finger, it does not just snap at the end), and
/// tapping a trigger animates the view to that page.
///
/// ```dart
/// final tabs = BCTabsController<String>(values: ['music', 'podcasts']);
/// ...
/// BCTabs(items: items, controller: tabs);
/// Expanded(child: BCTabView(controller: tabs, children: [MusicPage(), PodcastPage()]));
/// ```
///
/// Dispose it with the [State] that created it.
class BCTabsController<T> extends ChangeNotifier {
  BCTabsController({required List<T> values, T? initialValue})
      : assert(values.isNotEmpty, 'BCTabsController needs at least one value'),
        assert(
          initialValue == null || values.contains(initialValue),
          'initialValue must be one of values',
        ),
        _values = List<T>.unmodifiable(values),
        _index = initialValue == null ? 0 : values.indexOf(initialValue) {
    pageController = PageController(initialPage: _index);
    pageController.addListener(_handlePageChanged);
  }

  final List<T> _values;
  int _index;

  /// Owned by this controller — hand it to a [BCTabView], not to a bare
  /// [PageView] you also drive yourself.
  late final PageController pageController;

  List<T> get values => _values;

  /// The settled tab.
  T get value => _values[_index];

  int get index => _index;

  /// Continuous position, e.g. 1.4 halfway through a swipe from tab 1 to 2.
  /// Falls back to [index] before the view is laid out.
  double get offset {
    if (!pageController.hasClients) return _index.toDouble();
    final position = pageController.position;
    if (!position.hasPixels || !position.hasContentDimensions) {
      return _index.toDouble();
    }
    return (pageController.page ?? _index.toDouble())
        .clamp(0.0, (_values.length - 1).toDouble());
  }

  void _handlePageChanged() {
    final page = offset;
    final settled = page.round();
    if (settled != _index) _index = settled;
    // Notified every frame of the drag so the indicator can follow it.
    notifyListeners();
  }

  /// Animates the view (and the indicator) to [value].
  Future<void> animateTo(
    T value, {
    Duration duration = BCDuration.normal,
    Curve curve = Curves.easeOutCubic,
  }) async {
    final target = _values.indexOf(value);
    if (target < 0 || target == _index) return;
    if (!pageController.hasClients) {
      _index = target;
      notifyListeners();
      return;
    }
    await pageController.animateToPage(
      target,
      duration: duration,
      curve: curve,
    );
  }

  /// Jumps without animating.
  void jumpTo(T value) {
    final target = _values.indexOf(value);
    if (target < 0 || target == _index) return;
    if (pageController.hasClients) {
      pageController.jumpToPage(target);
    } else {
      _index = target;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pageController.removeListener(_handlePageChanged);
    pageController.dispose();
    super.dispose();
  }
}

/// HeroUI Native Tabs (tabs.css): a segmented control.
///
/// Primary: `default`-colored pill list (radius 24, 3px padding) with a
/// sliding `segment` indicator. Secondary: bottom-border list with a 2px
/// accent underline. The indicator moves with a spring
/// (stiffness 1200, damping 120).
class BCTabs<T> extends StatefulWidget {
  const BCTabs({
    super.key,
    required this.items,
    this.value,
    this.controller,
    this.onValueChange,
    this.variant = BCTabsVariant.primary,
    this.fullWidth = false,
  }) : assert(
          (value == null) != (controller == null),
          'Pass either value (uncontrolled) or controller (paired with a '
          'BCTabView), not both',
        );

  final List<BCTabItem<T>> items;

  /// Selected value when driving the bar yourself. Omit when using
  /// [controller].
  final T? value;

  /// Ties this bar to a [BCTabView]; the indicator then follows the swipe.
  final BCTabsController<T>? controller;

  /// Called on tap, and on swipe when a [controller] is attached.
  final ValueChanged<T>? onValueChange;
  final BCTabsVariant variant;

  /// Stretches the list to fill the available width, distributing triggers
  /// evenly.
  final bool fullWidth;

  @override
  State<BCTabs<T>> createState() => _BCTabsState<T>();
}

class _BCTabsState<T> extends State<BCTabs<T>>
    with SingleTickerProviderStateMixin {
  // Eagerly constructed: a `late final` initializer would run on first use,
  // which for a controlled bar is inside dispose() — too late to create a
  // ticker.
  late final AnimationController _progress;
  Rect? _fromRect;
  Rect? _toRect;

  final Map<T, GlobalKey> _triggerKeys = {};
  final GlobalKey _stackKey = GlobalKey();

  GlobalKey _keyFor(T value) => _triggerKeys.putIfAbsent(value, GlobalKey.new);

  BCTabsController<T>? get _controller => widget.controller;

  T get _value => _controller?.value ?? widget.value as T;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, value: 1);
    _lastReportedValue = _controller?.value;
    _controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(BCTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }
    if (widget.controller == null && oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _moveIndicator());
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChanged);
    _progress.dispose();
    super.dispose();
  }

  /// Repaints the label colors as the settled tab changes; the indicator
  /// itself rebuilds from the controller directly.
  void _handleControllerChanged() {
    final settled = _controller!.value;
    if (settled != _lastReportedValue) {
      _lastReportedValue = settled;
      widget.onValueChange?.call(settled);
    }
    if (mounted) setState(() {});
  }

  T? _lastReportedValue;

  /// Indicator rect for a fractional position, interpolating between the two
  /// triggers the swipe sits between.
  Rect? _rectForOffset(double offset) {
    final items = widget.items;
    final low = offset.floor().clamp(0, items.length - 1);
    final high = offset.ceil().clamp(0, items.length - 1);
    final lowRect = _measure(items[low].value);
    final highRect = _measure(items[high].value);
    if (lowRect == null || highRect == null) return lowRect ?? highRect;
    if (low == high) return lowRect;
    return Rect.lerp(lowRect, highRect, offset - low);
  }

  Rect? _measure(T value) {
    final triggerContext = _triggerKeys[value]?.currentContext;
    final stackContext = _stackKey.currentContext;
    if (triggerContext == null || stackContext == null) return null;
    final triggerBox = triggerContext.findRenderObject() as RenderBox?;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (triggerBox == null || stackBox == null || !triggerBox.hasSize) {
      return null;
    }
    final topLeft =
        triggerBox.localToGlobal(Offset.zero, ancestor: stackBox);
    return topLeft & triggerBox.size;
  }

  void _moveIndicator() {
    if (!mounted) return;
    final target = _measure(_value);
    if (target == null) return;

    setState(() {
      _fromRect = _currentRect() ?? target;
      _toRect = target;
    });

    if (MediaQuery.disableAnimationsOf(context)) {
      _progress.value = 1;
      return;
    }
    _progress.value = 0;
    _progress.animateWith(
      SpringSimulation(BCMotion.tabsIndicatorSpring, 0, 1, 0,
          snapToEnd: true),
    );
  }

  Rect? _currentRect() {
    if (_fromRect == null || _toRect == null) return _toRect;
    return Rect.lerp(_fromRect, _toRect, _progress.value.clamp(0.0, 1.0));
  }

  /// Controlled: track the swipe position. Uncontrolled: run the spring.
  Rect? _indicatorRect() {
    final controller = _controller;
    if (controller != null) return _rectForOffset(controller.offset);
    return _currentRect() ?? _measure(_value);
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final isPrimary = widget.variant == BCTabsVariant.primary;

    final triggers = [
      for (final item in widget.items)
        _buildTrigger(context, item, isPrimary),
    ];

    final list = Stack(
      key: _stackKey,
      children: [
        // Indicator behind triggers
        AnimatedBuilder(
          animation: _controller ?? _progress,
          builder: (context, _) {
            final rect = _indicatorRect();
            if (rect == null) {
              // First layout: the triggers have no geometry yet.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (_controller != null) {
                  setState(() {});
                } else if (_toRect == null) {
                  _moveIndicator();
                }
              });
              return const SizedBox.shrink();
            }
            if (isPrimary) {
              return Positioned(
                left: rect.left,
                top: rect.top,
                width: rect.width,
                height: rect.height,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: bc.segment,
                    shape: BCShapes.continuous(BCRadius.xxxl),
                    shadows: [
                      BoxShadow(
                        color: const Color(0xFF000000).withValues(alpha: 0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Positioned(
              left: rect.left,
              bottom: 0,
              width: rect.width,
              height: 2,
              child: ColoredBox(color: bc.accent),
            );
          },
        ),
        Row(
          mainAxisSize:
              widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          spacing: 4,
          children: widget.fullWidth
              ? [for (final t in triggers) Expanded(child: t)]
              : triggers,
        ),
      ],
    );

    // Shrink-wrap to the triggers' content width (heroui's
    // `align-self: flex-start`); when [fullWidth] the tab bar fills its
    // parent so the Expanded triggers can divide the space.
    final widthFactor = widget.fullWidth ? null : 1.0;

    if (isPrimary) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: widthFactor,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: ShapeDecoration(
            color: bc.defaultColor,
            shape: BCShapes.continuous(BCRadius.xxxl),
          ),
          child: list,
        ),
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: bc.border)),
        ),
        child: list,
      ),
    );
  }

  Widget _buildTrigger(
    BuildContext context,
    BCTabItem<T> item,
    bool isPrimary,
  ) {
    final bc = context.bcTheme;
    final isSelected = item.value == _value;

    final labelColor = isSelected
        ? (isPrimary ? bc.segmentForeground : bc.foreground)
        : bc.muted;

    return GestureDetector(
      key: _keyFor(item.value),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isSelected) return;
        final controller = _controller;
        if (controller != null) {
          controller.animateTo(item.value);
        } else {
          widget.onValueChange?.call(item.value);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            if (item.icon != null)
              IconTheme.merge(
                data: IconThemeData(color: labelColor, size: 16),
                child: item.icon!,
              ),
            Text(
              item.label,
              style: BCTypography.textBase.copyWith(
                color: labelColor,
                fontWeight: BCTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The swipeable panels behind a [BCTabs] bar.
///
/// Shares a [BCTabsController] with the bar, so a horizontal drag switches
/// tabs and drags the indicator with it, exactly like Material's
/// `TabBarView` — but with the heroui segmented-control styling.
///
/// ```dart
/// Column(
///   children: [
///     BCTabs(items: items, controller: _tabs),
///     Expanded(
///       child: BCTabView(
///         controller: _tabs,
///         children: const [MusicPage(), PodcastsPage(), BooksPage()],
///       ),
///     ),
///   ],
/// );
/// ```
class BCTabView<T> extends StatelessWidget {
  const BCTabView({
    super.key,
    required this.controller,
    required this.children,
    this.swipeEnabled = true,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
  });

  final BCTabsController<T> controller;

  /// One panel per value in [BCTabsController.values], in the same order.
  final List<Widget> children;

  /// Set false to keep the panels in sync with the bar but only switchable by
  /// tapping a trigger.
  final bool swipeEnabled;

  /// Overrides the scroll physics; ignored when [swipeEnabled] is false.
  final ScrollPhysics? physics;

  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    assert(
      children.length == controller.values.length,
      'BCTabView needs one child per BCTabsController value '
      '(${children.length} children vs ${controller.values.length} values)',
    );

    return PageView(
      controller: controller.pageController,
      clipBehavior: clipBehavior,
      physics: swipeEnabled
          ? physics
          : const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
