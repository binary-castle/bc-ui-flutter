import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/card_theme.dart';
import 'package:flutter/material.dart';

export 'package:bc_ui/src/theme/component_themes/card_theme.dart'
    show BCCardVariant;

class BCCard extends StatelessWidget {
  const BCCard({
    super.key,
    required this.child,
    this.variant = BCCardVariant.defaultVariant,
  });

  final Widget child;
  final BCCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showShadow = variant != BCCardVariant.transparent;

    final card = ClipRRect(
      borderRadius: BCCardTheme.borderRadius,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BCCardTheme.fillDecoration(
          variant: variant,
          colors: colors,
        ),
        child: Padding(padding: BCCardTheme.padding, child: child),
      ),
    );

    if (!showShadow) return card;

    return DecoratedBox(
      decoration: BCCardTheme.shadowDecoration(colors),
      child: card,
    );
  }
}

class BCCardHeader extends StatelessWidget {
  const BCCardHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class BCCardBody extends StatelessWidget {
  const BCCardBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class BCCardFooter extends StatelessWidget {
  const BCCardFooter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class BCCardTitle extends StatelessWidget {
  const BCCardTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCCardTheme.titleStyle(context.text, context.colors),
    );
  }
}

class BCCardDescription extends StatelessWidget {
  const BCCardDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCCardTheme.descriptionStyle(context.text, context.colors),
    );
  }
}
