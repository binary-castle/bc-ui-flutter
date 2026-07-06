import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/badge_theme.dart';
import 'package:flutter/material.dart';

export 'package:bc_ui/src/theme/component_themes/badge_theme.dart'
    show BCBadgeColor, BCBadgeSize, BCBadgeVariant;

class BCBadge extends StatelessWidget {
  const BCBadge({
    super.key,
    this.child,
    this.label,
    this.size = BCBadgeSize.medium,
    this.variant = BCBadgeVariant.primary,
    this.color = BCBadgeColor.accent,
    this.onPressed,
  }) : assert(child != null || label != null);

  final Widget? child;
  final String? label;
  final BCBadgeSize size;
  final BCBadgeVariant variant;
  final BCBadgeColor color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = child ?? BCBadgeLabel(label!);
    final decoration = BCBadgeTheme.decoration(
      variant: variant,
      color: color,
      size: size,
      colors: colors,
    );
    final radius = BCBadgeTheme.borderRadius(size);
    final padding = BCBadgeTheme.padding(size);

    final badge = _BCBadgeScope(
      size: size,
      variant: variant,
      color: color,
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: BCBadgeTheme.labelStyle(
              size,
              context.text,
              BCBadgeTheme.foregroundColor(
                variant: variant,
                color: color,
                colors: colors,
              ),
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                size: size == BCBadgeSize.small ? 12 : 14,
                color: BCBadgeTheme.foregroundColor(
                  variant: variant,
                  color: color,
                  colors: colors,
                ),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );

    if (onPressed == null) return badge;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onPressed, borderRadius: radius, child: badge),
    );
  }
}

class BCBadgeLabel extends StatelessWidget {
  const BCBadgeLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scope = _BCBadgeScope.of(context);
    final colors = context.colors;
    final textTheme = context.text;

    final size = scope?.size ?? BCBadgeSize.medium;
    final variant = scope?.variant ?? BCBadgeVariant.primary;
    final badgeColor = scope?.color ?? BCBadgeColor.accent;

    return Text(
      text,
      style: BCBadgeTheme.labelStyle(
        size,
        textTheme,
        BCBadgeTheme.foregroundColor(
          variant: variant,
          color: badgeColor,
          colors: colors,
        ),
      ),
    );
  }
}

class _BCBadgeScope extends InheritedWidget {
  const _BCBadgeScope({
    required this.size,
    required this.variant,
    required this.color,
    required super.child,
  });

  final BCBadgeSize size;
  final BCBadgeVariant variant;
  final BCBadgeColor color;

  static _BCBadgeScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_BCBadgeScope>();
  }

  @override
  bool updateShouldNotify(_BCBadgeScope oldWidget) {
    return size != oldWidget.size ||
        variant != oldWidget.variant ||
        color != oldWidget.color;
  }
}
