import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_typography.dart';
import 'bc_surface.dart';

enum BCCardVariant { defaultVariant, secondary, tertiary, transparent }

/// HeroUI Native Card: a [BCSurface] with Header/Body/Footer/Title/Description
/// slots (card.tsx renders Root directly onto Surface).
class BCCard extends StatelessWidget {
  const BCCard({
    super.key,
    required this.child,
    this.variant = BCCardVariant.defaultVariant,
    this.padding,
  });

  final Widget child;
  final BCCardVariant variant;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return BCSurface(
      variant: switch (variant) {
        BCCardVariant.defaultVariant => BCSurfaceVariant.defaultVariant,
        BCCardVariant.secondary => BCSurfaceVariant.secondary,
        BCCardVariant.tertiary => BCSurfaceVariant.tertiary,
        BCCardVariant.transparent => BCSurfaceVariant.transparent,
      },
      padding: padding,
      child: child,
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

/// Card title: text-lg, medium weight, foreground (card.css `card__label`).
class BCCardTitle extends StatelessWidget {
  const BCCardTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCTypography.textLg.copyWith(
        color: context.bcTheme.foreground,
        fontWeight: BCTypography.medium,
      ),
    );
  }
}

/// Card description: text-base, muted (card.css `card__description`).
class BCCardDescription extends StatelessWidget {
  const BCCardDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCTypography.textBase.copyWith(color: context.bcTheme.muted),
    );
  }
}
