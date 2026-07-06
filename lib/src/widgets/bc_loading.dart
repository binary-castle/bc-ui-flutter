import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/loading_theme.dart';
import 'package:flutter/material.dart';

export 'package:bc_ui/src/theme/component_themes/loading_theme.dart'
    show BCLoadingColor, BCLoadingSize;

class BCLoading extends StatelessWidget {
  const BCLoading({
    super.key,
    this.child,
    this.size = BCLoadingSize.medium,
    this.color = BCLoadingColor.defaultColor,
    this.customColor,
    this.isLoading = true,
  });

  final Widget? child;
  final BCLoadingSize size;
  final BCLoadingColor color;
  final Color? customColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? _BCLoadingScope(
              key: const ValueKey('loading'),
              size: size,
              color: color,
              customColor: customColor,
              child: child ?? const BCLoadingIndicator(),
            )
          : const SizedBox.shrink(key: ValueKey('idle')),
    );
  }
}

class BCLoadingIndicator extends StatelessWidget {
  const BCLoadingIndicator({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scope = _BCLoadingScope.of(context);
    final colors = context.colors;

    final size = scope?.size ?? BCLoadingSize.medium;
    final indicatorColor = BCLoadingTheme.resolveColor(
      semanticColor: scope?.color,
      customColor: scope?.customColor,
      colors: colors,
    );
    final dimension = BCLoadingTheme.size(size);
    final strokeWidth = BCLoadingTheme.strokeWidth(size);

    if (child != null) return child!;

    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(indicatorColor),
      ),
    );
  }
}

class _BCLoadingScope extends InheritedWidget {
  const _BCLoadingScope({
    super.key,
    required this.size,
    required this.color,
    required this.customColor,
    required super.child,
  });

  final BCLoadingSize size;
  final BCLoadingColor color;
  final Color? customColor;

  static _BCLoadingScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_BCLoadingScope>();
  }

  @override
  bool updateShouldNotify(_BCLoadingScope oldWidget) {
    return size != oldWidget.size ||
        color != oldWidget.color ||
        customColor != oldWidget.customColor;
  }
}
