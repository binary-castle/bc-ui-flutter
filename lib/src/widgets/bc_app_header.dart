import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart' show Icons, ThemeData;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

/// How a [BCAppHeader] paints itself behind the content it sits over.
enum BCAppHeaderVariant {
  /// Frosted glass: the content scrolling underneath is blurred and tinted
  /// with a translucent [BCThemeExtension.background]. Pair with
  /// `Scaffold(extendBodyBehindAppBar: true)` so there is something to blur.
  blurred,

  /// Opaque [BCThemeExtension.background] with a hairline separator.
  solid,

  /// No background at all — for hero images, auth screens and onboarding.
  transparent,

  /// Detached, rounded, frosted bar with an overlay shadow (mirrors the
  /// floating bottom nav).
  floating,
}

/// A top app bar built from bc_ui tokens.
///
/// Drop-in for Material's `AppBar` (it is a [PreferredSizeWidget], so it goes
/// straight into `Scaffold.appBar`), but styled to the heroui palette: no
/// elevation, a hairline `border` separator that fades in only once content
/// scrolls under it, semibold 16px title with an optional muted subtitle, and
/// press-feedback icon buttons ([BCHeaderIconButton]).
///
/// ```dart
/// Scaffold(
///   extendBodyBehindAppBar: true,
///   appBar: BCAppHeader(
///     title: const Text('Inbox'),
///     subtitle: const Text('12 unread'),
///     actions: [BCHeaderIconButton(icon: const Icon(Icons.search), onPressed: () {})],
///   ),
///   body: ListView(...),
/// );
/// ```
class BCAppHeader extends StatefulWidget implements PreferredSizeWidget {
  const BCAppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottom,
    this.bottomHeight = 48,
    this.variant = BCAppHeaderVariant.blurred,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.filledIconButtons = false,
    this.showSeparator = true,
    this.separatorOnScrollOnly = true,
    this.materializeOnScroll = false,
    this.backgroundColor,
    this.foregroundColor,
    this.backgroundOpacity = 0.72,
    this.blurSigma = 24,
    this.systemOverlayStyle,
    this.toolbarHeight = defaultToolbarHeight,
  });

  static const double defaultToolbarHeight = 56;

  /// Styled with a 16px semibold [BCTypography] style when it is a [Text].
  final Widget? title;

  /// Secondary line under [title], muted 12px.
  final Widget? subtitle;

  /// Defaults to a back button when the route can be popped (a close button
  /// for fullscreen dialogs), unless [automaticallyImplyLeading] is false.
  final Widget? leading;

  final List<Widget> actions;

  /// Optional row under the toolbar — tabs, a search field, filter chips.
  final Widget? bottom;

  /// Height reserved for [bottom]. Ignored when [bottom] is a
  /// [PreferredSizeWidget], which reports its own height.
  final double bottomHeight;

  final BCAppHeaderVariant variant;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  /// Renders every [BCHeaderIconButton] in the leading and actions slots
  /// [BCHeaderIconButton.filled], including the back button this header
  /// implies — so a screen picks the style once instead of at each button.
  /// A button that sets `filled` itself still wins.
  final bool filledIconButtons;

  /// Draws the hairline [BCThemeExtension.border] separator along the bottom
  /// edge (never used by [BCAppHeaderVariant.floating]).
  final bool showSeparator;

  /// Fades the separator in only while content is scrolled under the header.
  final bool separatorOnScrollOnly;

  /// Starts fully see-through and fades the blur + tint in once content is
  /// scrolled under — the iOS "hero materializes into a bar" behavior.
  /// Only meaningful for [BCAppHeaderVariant.blurred] and
  /// [BCAppHeaderVariant.floating].
  final bool materializeOnScroll;

  /// Defaults to [BCThemeExtension.background] (blurred/solid) or
  /// [BCThemeExtension.surface] (floating).
  final Color? backgroundColor;

  /// Colors the title, subtitle and any [BCHeaderIconButton] in the leading /
  /// actions slots — use it when the header sits over a photo or a dark hero.
  /// Defaults to [BCThemeExtension.foreground].
  final Color? foregroundColor;

  /// Alpha applied to [backgroundColor] behind the blur.
  final double backgroundOpacity;

  final double blurSigma;

  /// Status bar icon brightness while this header is on screen. Defaults to
  /// whatever contrasts with the resolved [foregroundColor] — a white-on-photo
  /// header gets light glyphs without any extra wiring.
  final SystemUiOverlayStyle? systemOverlayStyle;

  final double toolbarHeight;

  double get _bottomHeight => switch (bottom) {
        null => 0,
        final PreferredSizeWidget w => w.preferredSize.height,
        _ => bottomHeight,
      };

  /// Vertical inset around the detached [BCAppHeaderVariant.floating] bar.
  double get _floatingMargin =>
      variant == BCAppHeaderVariant.floating ? BCSpacing.sm : 0;

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + _bottomHeight + _floatingMargin * 2,
      );

  @override
  State<BCAppHeader> createState() => _BCAppHeaderState();
}

class _BCAppHeaderState extends State<BCAppHeader> {
  ScrollNotificationObserverState? _observer;
  bool _scrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ScrollNotificationObserver.maybeOf(context);
    if (observer != _observer) {
      _observer?.removeListener(_handleScrollNotification);
      _observer = observer;
      _observer?.addListener(_handleScrollNotification);
    }
  }

  @override
  void dispose() {
    _observer?.removeListener(_handleScrollNotification);
    _observer = null;
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification ||
        !defaultScrollNotificationPredicate(notification)) {
      return;
    }
    final metrics = notification.metrics;
    final scrolledUnder = switch (metrics.axisDirection) {
      // Reversed list: content piles up below the header.
      AxisDirection.up => metrics.extentAfter > 0,
      AxisDirection.down => metrics.extentBefore > 0,
      // Horizontal scrollers never put content under the header.
      AxisDirection.left || AxisDirection.right => _scrolledUnder,
    };
    if (scrolledUnder != _scrolledUnder) {
      setState(() => _scrolledUnder = scrolledUnder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final isFloating = widget.variant == BCAppHeaderVariant.floating;

    final toolbar = _BCHeaderToolbar(
      title: widget.title,
      subtitle: widget.subtitle,
      leading: widget.leading,
      actions: widget.actions,
      centerTitle: widget.centerTitle,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      filledIconButtons: widget.filledIconButtons,
      foregroundColor: widget.foregroundColor,
      height: widget.toolbarHeight,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        toolbar,
        if (widget.bottom != null)
          SizedBox(height: widget._bottomHeight, child: widget.bottom),
      ],
    );

    // Blur and tint are off until content scrolls under when materializing.
    final target =
        widget.materializeOnScroll && !_scrolledUnder ? 0.0 : 1.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.systemOverlayStyle ??
          _overlayStyleFor(widget.foregroundColor ?? bc.foreground),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: BCMotion.timingDuration,
        curve: BCMotion.timingCurve,
        builder: (context, t, _) {
          if (isFloating) {
            return SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: BCSpacing.md,
                  vertical: widget._floatingMargin,
                ),
                child: _floating(bc, content, t),
              ),
            );
          }

          return _withSeparator(
            bc,
            _background(bc, SafeArea(bottom: false, child: content), t),
          );
        },
      ),
    );
  }

  /// Frosted (or plain) background behind an edge-to-edge header.
  Widget _background(BCThemeExtension bc, Widget child, double t) {
    if (widget.variant == BCAppHeaderVariant.transparent) return child;

    final base = widget.backgroundColor ?? bc.background;

    if (widget.variant == BCAppHeaderVariant.solid) {
      return ColoredBox(color: base, child: child);
    }

    final tinted = ColoredBox(
      color: base.withValues(alpha: widget.backgroundOpacity * t),
      child: child,
    );
    if (t == 0) return tinted;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurSigma * t,
          sigmaY: widget.blurSigma * t,
        ),
        child: tinted,
      ),
    );
  }

  /// Hairline along the bottom edge, painted over the header so it never
  /// takes part in layout.
  Widget _withSeparator(BCThemeExtension bc, Widget child) {
    if (!widget.showSeparator) return child;
    final visible = !widget.separatorOnScrollOnly || _scrolledUnder;

    return Stack(
      children: [
        child,
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: BCMotion.timingDuration,
            curve: BCMotion.timingCurve,
            child: Container(height: bc.borderWidth, color: bc.border),
          ),
        ),
      ],
    );
  }

  /// Detached rounded bar with the overlay shadow, like the floating bottom
  /// nav.
  Widget _floating(BCThemeExtension bc, Widget content, double t) {
    final shape = BCShapes.continuous(BCRadius.xxxl);
    final base = widget.backgroundColor ?? bc.surface;
    final hairline = bc.overlayShadow.innerBorder;

    final bar = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: base.withValues(alpha: widget.backgroundOpacity * t),
        shape: shape,
        shadows: BoxShadow.lerpList(
          const <BoxShadow>[],
          bc.overlayShadow.shadows,
          t,
        ),
      ),
      child: t == 0
          ? content
          : BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurSigma * t,
                sigmaY: widget.blurSigma * t,
              ),
              child: content,
            ),
    );

    if (hairline == null) return bar;

    // Painted as an overlay rather than as the shape's side: a stroked
    // ShapeDecoration insets its child, which would squeeze the toolbar.
    return Stack(
      children: [
        bar,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: BCShapes.continuous(
                  BCRadius.xxxl,
                  side: hairline.copyWith(
                    color:
                        hairline.color.withValues(alpha: hairline.color.a * t),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Status bar glyphs that contrast with the header's own foreground: a light
/// foreground implies a dark backdrop behind it, which needs light glyphs.
SystemUiOverlayStyle _overlayStyleFor(Color foreground) {
  return ThemeData.estimateBrightnessForColor(foreground) == Brightness.light
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}

/// The leading / title / actions row shared by [BCAppHeader] and
/// [BCSliverAppHeader].
class _BCHeaderToolbar extends StatelessWidget {
  const _BCHeaderToolbar({
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.filledIconButtons = false,
    this.titleOpacity = 1,
    this.foregroundColor,
    required this.height,
  });

  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final bool filledIconButtons;

  /// Used by the large-title header to fade the compact title in.
  final double titleOpacity;
  final Color? foregroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final onColor = foregroundColor;

    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && automaticallyImplyLeading) {
      final route = ModalRoute.of(context);
      if (route?.impliesAppBarDismissal ?? false) {
        resolvedLeading = BCHeaderIconButton(
          icon: Icon(
            (route?.fullscreenDialog ?? false)
                ? Icons.close
                : Icons.arrow_back_ios_new,
          ),
          iconSize: 20,
          filled: filledIconButtons,
          semanticLabel: (route?.fullscreenDialog ?? false) ? 'Close' : 'Back',
          onPressed: () => Navigator.maybePop(context),
        );
      }
    }

    Widget? middle;
    if (title != null || subtitle != null) {
      middle = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (title != null)
            DefaultTextStyle(
              style: BCTypography.textBase.copyWith(
                fontWeight: BCTypography.semiBold,
                color: onColor ?? bc.foreground,
                letterSpacing: BCTypography.trackingTight(BCTypography.sizeBase),
                height: 1.25,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: title!,
            ),
          if (subtitle != null)
            DefaultTextStyle(
              style: BCTypography.textXs.copyWith(
                fontWeight: BCTypography.medium,
                color: onColor?.withValues(alpha: 0.75) ?? bc.muted,
                height: 1.35,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
        ],
      );

      middle = Semantics(header: true, child: middle);
      if (titleOpacity < 1) {
        middle = Opacity(opacity: titleOpacity, child: middle);
      }
    }

    final Widget toolbar = SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: BCSpacing.sm),
        child: NavigationToolbar(
          // NavigationToolbar gives the leading slot the full bar height and
          // pins it at y=0, so it has to center its own content; widthFactor
          // keeps the slot from claiming the whole row.
          leading: resolvedLeading == null
              ? null
              : Align(widthFactor: 1, child: resolvedLeading),
          middle: middle,
          centerMiddle: centerTitle,
          // 8px gutter puts the title at x=16 without a leading widget and at
          // x=56 with one, matching the 16px content grid either way.
          middleSpacing: BCSpacing.sm,
          trailing: actions.isEmpty
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: BCSpacing.xs,
                  children: actions,
                ),
        ),
      ),
    );

    // Always inserted, even with no foreground override: [filledIconButtons]
    // travels the same channel, and an action is an opaque widget the caller
    // supplied — context is the only way to reach the buttons inside it.
    return _BCHeaderStyle(
      color: onColor,
      filled: filledIconButtons,
      child: toolbar,
    );
  }
}

/// Carries [BCAppHeader.foregroundColor] and [BCAppHeader.filledIconButtons]
/// down to the [BCHeaderIconButton]s in the leading/actions slots.
class _BCHeaderStyle extends InheritedWidget {
  const _BCHeaderStyle({
    this.color,
    required this.filled,
    required super.child,
  });

  final Color? color;
  final bool filled;

  /// Returns the widget rather than a single value, so a button resolves both
  /// of its inherited defaults with one dependency registration.
  static _BCHeaderStyle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BCHeaderStyle>();

  @override
  bool updateShouldNotify(_BCHeaderStyle oldWidget) =>
      color != oldWidget.color || filled != oldWidget.filled;
}

/// A round 40px icon button for [BCAppHeader] leading/action slots.
///
/// Uses the library press feedback (scale + highlight); [filled] paints the
/// `default` token behind it, which reads well over photos and blurred
/// backgrounds.
class BCHeaderIconButton extends StatelessWidget {
  const BCHeaderIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.filled,
    this.size = 40,
    this.iconSize = 22,
    this.color,
    this.backgroundColor,
    this.badgeCount,
    this.showDot = false,
    this.semanticLabel,
    this.isDisabled = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;

  /// Paints a circle behind the icon, so it stays legible over photos.
  ///
  /// Null defers to the enclosing header's [BCAppHeader.filledIconButtons],
  /// and false where there is none — so a header can set the style for all of
  /// its buttons while a single button still opts in or out.
  final bool? filled;

  final double size;
  final double iconSize;

  /// Defaults to the header's `foregroundColor`, else the foreground token.
  final Color? color;

  /// Circle color when [filled]. Defaults to the `default` token; a
  /// translucent black reads better over a photo.
  final Color? backgroundColor;

  /// Shows a small count badge (e.g. unread notifications).
  final int? badgeCount;

  /// Shows a small dot badge (ignored when [badgeCount] is set).
  final bool showDot;

  final String? semanticLabel;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    const shape = CircleBorder();

    final headerStyle = _BCHeaderStyle.maybeOf(context);
    final iconColor = color ?? headerStyle?.color ?? bc.foreground;
    final isFilled = filled ?? headerStyle?.filled ?? false;

    Widget content = Center(
      child: IconTheme.merge(
        data: IconThemeData(color: iconColor, size: iconSize),
        child: icon,
      ),
    );

    final hasCount = badgeCount != null && badgeCount! > 0;
    if (hasCount || showDot) {
      content = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          content,
          Positioned(
            top: size / 2 - iconSize / 2 - 4,
            right: size / 2 - iconSize / 2 - 6,
            child: hasCount
                ? Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: bc.danger,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      badgeCount! > 99 ? '99+' : '$badgeCount',
                      style: BCTypography.textXs.copyWith(
                        color: bc.dangerForeground,
                        fontWeight: BCTypography.semiBold,
                        height: 1,
                      ),
                    ),
                  )
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: bc.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ],
      );
    }

    Widget button = BCPressable(
      onPressed: isDisabled ? null : onPressed,
      enabled: !isDisabled,
      shape: shape,
      background: isFilled
          ? DecoratedBox(
              decoration: ShapeDecoration(
                color: backgroundColor ?? bc.defaultColor,
                shape: shape,
              ),
            )
          : null,
      highlightColor: isFilled ? bc.defaultHover : null,
      child: SizedBox(width: size, height: size, child: content),
    );

    if (isDisabled) {
      button = Opacity(opacity: bc.opacityDisabled, child: button);
    }

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel,
      child: button,
    );
  }
}

/// A pinned sliver header with an iOS-style large title that collapses into
/// the compact toolbar title as the list scrolls.
///
/// Put it first in a [CustomScrollView]; the blur, separator and title
/// crossfade are all driven by the sliver's own scroll offset, so no
/// `Scaffold.appBar` is involved.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     BCSliverAppHeader(
///       largeTitle: const Text('Library'),
///       actions: [BCHeaderIconButton(icon: const Icon(Icons.add), onPressed: () {})],
///     ),
///     SliverList(...),
///   ],
/// );
/// ```
class BCSliverAppHeader extends StatelessWidget {
  const BCSliverAppHeader({
    super.key,
    required this.largeTitle,
    this.title,
    this.leading,
    this.actions = const [],
    this.bottom,
    this.bottomHeight = 48,
    this.variant = BCAppHeaderVariant.blurred,
    this.automaticallyImplyLeading = true,
    this.filledIconButtons = false,
    this.showSeparator = true,
    this.backgroundColor,
    this.foregroundColor,
    this.backgroundOpacity = 0.72,
    this.blurSigma = 24,
    this.systemOverlayStyle,
    this.toolbarHeight = BCAppHeader.defaultToolbarHeight,
    this.largeTitleHeight = 56,
  }) : assert(
          variant != BCAppHeaderVariant.floating,
          'BCSliverAppHeader does not support the floating variant',
        );

  /// Expanded 30px bold title.
  final Widget largeTitle;

  /// Compact title that fades in once collapsed. Defaults to [largeTitle].
  final Widget? title;

  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;
  final double bottomHeight;
  final BCAppHeaderVariant variant;
  final bool automaticallyImplyLeading;

  /// See [BCAppHeader.filledIconButtons].
  final bool filledIconButtons;
  final bool showSeparator;
  final Color? backgroundColor;

  /// See [BCAppHeader.foregroundColor].
  final Color? foregroundColor;
  final double backgroundOpacity;
  final double blurSigma;

  /// See [BCAppHeader.systemOverlayStyle].
  final SystemUiOverlayStyle? systemOverlayStyle;

  final double toolbarHeight;

  /// Height of the large-title row that collapses away.
  final double largeTitleHeight;

  @override
  Widget build(BuildContext context) {
    final resolvedBottomHeight = switch (bottom) {
      null => 0.0,
      final PreferredSizeWidget w => w.preferredSize.height,
      _ => bottomHeight,
    };

    return SliverPersistentHeader(
      pinned: true,
      delegate: _BCLargeTitleDelegate(
        topPadding: MediaQuery.paddingOf(context).top,
        largeTitle: largeTitle,
        title: title ?? largeTitle,
        leading: leading,
        actions: actions,
        bottom: bottom,
        bottomHeight: resolvedBottomHeight,
        variant: variant,
        automaticallyImplyLeading: automaticallyImplyLeading,
        filledIconButtons: filledIconButtons,
        showSeparator: showSeparator,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        backgroundOpacity: backgroundOpacity,
        blurSigma: blurSigma,
        systemOverlayStyle: systemOverlayStyle,
        toolbarHeight: toolbarHeight,
        largeTitleHeight: largeTitleHeight,
      ),
    );
  }
}

class _BCLargeTitleDelegate extends SliverPersistentHeaderDelegate {
  const _BCLargeTitleDelegate({
    required this.topPadding,
    required this.largeTitle,
    required this.title,
    required this.leading,
    required this.actions,
    required this.bottom,
    required this.bottomHeight,
    required this.variant,
    required this.automaticallyImplyLeading,
    required this.filledIconButtons,
    required this.showSeparator,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.backgroundOpacity,
    required this.blurSigma,
    required this.systemOverlayStyle,
    required this.toolbarHeight,
    required this.largeTitleHeight,
  });

  final double topPadding;
  final Widget largeTitle;
  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;
  final double bottomHeight;
  final BCAppHeaderVariant variant;
  final bool automaticallyImplyLeading;
  final bool filledIconButtons;
  final bool showSeparator;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double backgroundOpacity;
  final double blurSigma;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final double toolbarHeight;
  final double largeTitleHeight;

  @override
  double get minExtent => topPadding + toolbarHeight + bottomHeight;

  @override
  double get maxExtent => minExtent + largeTitleHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bc = context.bcTheme;
    final t = (shrinkOffset / largeTitleHeight).clamp(0.0, 1.0);
    // The compact title only appears over the last 40% of the collapse, so
    // the two titles never read as duplicated.
    final compactOpacity = ((t - 0.6) / 0.4).clamp(0.0, 1.0);

    final toolbar = _BCHeaderToolbar(
      title: title,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      filledIconButtons: filledIconButtons,
      titleOpacity: compactOpacity,
      foregroundColor: foregroundColor,
      height: toolbarHeight,
    );

    final layers = Stack(
      fit: StackFit.expand,
      children: [
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: bottomHeight,
          height: largeTitleHeight,
          child: Opacity(
            opacity: 1 - t,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                BCSpacing.md,
                0,
                BCSpacing.md,
                BCSpacing.sm,
              ),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: DefaultTextStyle(
                  style: BCTypography.text3xl.copyWith(
                    fontWeight: BCTypography.bold,
                    color: foregroundColor ?? bc.foreground,
                    letterSpacing:
                        BCTypography.trackingTight(BCTypography.size3xl),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: largeTitle,
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: 0,
          end: 0,
          top: topPadding,
          height: toolbarHeight,
          child: toolbar,
        ),
        if (bottom != null)
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            height: bottomHeight,
            child: bottom!,
          ),
        if (showSeparator)
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: Opacity(
              opacity: t,
              child: Container(height: bc.borderWidth, color: bc.border),
            ),
          ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle ??
          _overlayStyleFor(foregroundColor ?? bc.foreground),
      child: _background(bc, layers, t),
    );
  }

  Widget _background(BCThemeExtension bc, Widget child, double t) {
    if (variant == BCAppHeaderVariant.transparent) return child;

    final base = backgroundColor ?? bc.background;
    if (variant == BCAppHeaderVariant.solid) {
      return ColoredBox(color: base, child: child);
    }

    // The glass only builds up as the large title collapses, so the expanded
    // header sits flush on the page background.
    final tinted = ColoredBox(
      color: base.withValues(alpha: backgroundOpacity * t),
      child: child,
    );
    if (t == 0) return tinted;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma * t, sigmaY: blurSigma * t),
        child: tinted,
      ),
    );
  }

  @override
  bool shouldRebuild(_BCLargeTitleDelegate oldDelegate) {
    return topPadding != oldDelegate.topPadding ||
        largeTitle != oldDelegate.largeTitle ||
        title != oldDelegate.title ||
        leading != oldDelegate.leading ||
        actions != oldDelegate.actions ||
        bottom != oldDelegate.bottom ||
        bottomHeight != oldDelegate.bottomHeight ||
        variant != oldDelegate.variant ||
        automaticallyImplyLeading != oldDelegate.automaticallyImplyLeading ||
        filledIconButtons != oldDelegate.filledIconButtons ||
        showSeparator != oldDelegate.showSeparator ||
        backgroundColor != oldDelegate.backgroundColor ||
        foregroundColor != oldDelegate.foregroundColor ||
        backgroundOpacity != oldDelegate.backgroundOpacity ||
        blurSigma != oldDelegate.blurSigma ||
        systemOverlayStyle != oldDelegate.systemOverlayStyle ||
        toolbarHeight != oldDelegate.toolbarHeight ||
        largeTitleHeight != oldDelegate.largeTitleHeight;
  }
}
