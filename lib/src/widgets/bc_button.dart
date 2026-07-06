import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/button_theme.dart';
import 'package:flutter/material.dart';

export 'package:bc_ui/src/theme/component_themes/button_theme.dart'
    show BCButtonSize, BCButtonVariant;

class BCButton extends StatelessWidget {
  const BCButton._({
    super.key,
    required this.variant,
    required this.text,
    this.onPressed,
    this.leading,
    this.trailing,
    this.loading = false,
    this.fullWidth = false,
    this.size = BCButtonSize.medium,
  });

  // Primary
  factory BCButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    bool loading = false,
    bool fullWidth = false,
    BCButtonSize size = BCButtonSize.medium,
  }) {
    return BCButton._(
      key: key,
      variant: BCButtonVariant.primary,
      text: text,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      loading: loading,
      fullWidth: fullWidth,
      size: size,
    );
  }

  // Secondary
  factory BCButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    bool loading = false,
    bool fullWidth = false,
    BCButtonSize size = BCButtonSize.medium,
  }) {
    return BCButton._(
      key: key,
      variant: BCButtonVariant.secondary,
      text: text,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      loading: loading,
      fullWidth: fullWidth,
      size: size,
    );
  }

  // Outline
  factory BCButton.outline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    bool loading = false,
    bool fullWidth = false,
    BCButtonSize size = BCButtonSize.medium,
  }) {
    return BCButton._(
      key: key,
      variant: BCButtonVariant.outline,
      text: text,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      loading: loading,
      fullWidth: fullWidth,
      size: size,
    );
  }

  // Text
  factory BCButton.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    bool loading = false,
    bool fullWidth = false,
    BCButtonSize size = BCButtonSize.medium,
  }) {
    return BCButton._(
      key: key,
      variant: BCButtonVariant.text,
      text: text,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      loading: loading,
      fullWidth: fullWidth,
      size: size,
    );
  }

  // Destructive
  factory BCButton.destructive({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    bool loading = false,
    bool fullWidth = false,
    BCButtonSize size = BCButtonSize.medium,
  }) {
    return BCButton._(
      key: key,
      variant: BCButtonVariant.destructive,
      text: text,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      loading: loading,
      fullWidth: fullWidth,
      size: size,
    );
  }

  final BCButtonVariant variant;
  final String text;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool loading;
  final bool fullWidth;
  final BCButtonSize size;

  ButtonStyle _style(BuildContext context) {
    return BCButtonTheme.style(
      variant: variant,
      size: size,
      colors: context.colors,
      textTheme: context.text,
    );
  }

  Widget _child(BuildContext context) {
    final foreground = BCButtonTheme.foregroundColor(variant, context.colors);
    final gap = BCButtonTheme.iconGap(size);

    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(foreground),
            ),
          )
        else
          ?leading,
        if (loading || leading != null) SizedBox(width: gap),
        Text(text),
        if (trailing != null) ...[SizedBox(width: gap), trailing!],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final callback = loading ? null : onPressed;
    final style = _style(context);
    final child = _child(context);

    final button = switch (variant) {
      BCButtonVariant.primary ||
      BCButtonVariant.secondary ||
      BCButtonVariant.destructive => FilledButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      BCButtonVariant.outline => OutlinedButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      BCButtonVariant.text => TextButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
