import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';
import 'bc_separator.dart';
import 'bc_surface.dart';

/// HeroUI Native ListGroup (list-group.css): a zero-padding [BCSurface]
/// stacking [BCListGroupItem]s with hairline separators between them.
class BCListGroup extends StatelessWidget {
  const BCListGroup({
    super.key,
    required this.children,
    this.variant = BCSurfaceVariant.defaultVariant,
    this.showSeparators = true,
  });

  final List<Widget> children;
  final BCSurfaceVariant variant;
  final bool showSeparators;

  @override
  Widget build(BuildContext context) {
    return BCSurface(
      variant: variant,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0 && showSeparators)
              const Padding(
                padding: EdgeInsetsDirectional.only(start: 16),
                child: BCSeparator(),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A list row: prefix | title/description | suffix, 16px padding, gap 12,
/// press highlight (no scale).
class BCListGroupItem extends StatelessWidget {
  const BCListGroupItem({
    super.key,
    this.title,
    this.description,
    this.prefix,
    this.suffix,
    this.content,
    this.onPressed,
    this.isDisabled = false,
  });

  final String? title;
  final String? description;
  final Widget? prefix;
  final Widget? suffix;

  /// Custom middle content; replaces [title]/[description].
  final Widget? content;

  final VoidCallback? onPressed;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    Widget row = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 12,
        children: [
          ?prefix,
          Expanded(
            child: content ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: BCTypography.textBase.copyWith(
                          color: bc.foreground,
                          fontWeight: BCTypography.medium,
                        ),
                      ),
                    if (description != null)
                      Text(
                        description!,
                        style:
                            BCTypography.textSm.copyWith(color: bc.muted),
                      ),
                  ],
                ),
          ),
          ?suffix,
        ],
      ),
    );

    if (isDisabled) {
      row = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: row),
      );
    }

    if (onPressed == null) return row;

    return BCPressable(
      feedback: BCPressFeedback.highlight,
      onPressed: isDisabled ? null : onPressed,
      enabled: !isDisabled,
      highlightColor: bc.surfaceHover,
      highlightOpacityRange: (0, 1),
      child: row,
    );
  }
}
