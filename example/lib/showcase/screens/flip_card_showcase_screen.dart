import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class FlipCardShowcaseScreen extends StatefulWidget {
  const FlipCardShowcaseScreen({super.key});

  @override
  State<FlipCardShowcaseScreen> createState() =>
      _FlipCardShowcaseScreenState();
}

class _FlipCardShowcaseScreenState extends State<FlipCardShowcaseScreen> {
  bool _showBack = false;

  Widget _cardShell(BuildContext context, {required Widget child}) {
    final bc = context.bcTheme;
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bc.surfaceSecondary, bc.surface],
        ),
        shape: BCShapes.continuous(BCRadius.xxxl),
        shadows: bc.overlayShadow.shadows,
      ),
      child: child,
    );
  }

  Widget _cardFront(BuildContext context) {
    final bc = context.bcTheme;
    return _cardShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BCText('Hero Bank',
                  type: BCTextType.h4, weight: BCTextWeight.semibold),
              Icon(Icons.wifi, color: bc.muted),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              BCText('••••  ••••  ••••',
                  type: BCTextType.h5, color: BCTextColor.muted),
              const SizedBox(width: 8),
              BCText('4242', type: BCTextType.h4),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BCText('CARD HOLDER',
                      type: BCTextType.bodyXs, color: BCTextColor.muted),
                  const BCText('Maya Chen', weight: BCTextWeight.medium),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BCText('EXPIRES',
                      type: BCTextType.bodyXs, color: BCTextColor.muted),
                  const BCText('09/28', weight: BCTextWeight.medium),
                ],
              ),
              const Spacer(),
              Icon(Icons.credit_card, color: bc.muted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBack(BuildContext context) {
    final bc = context.bcTheme;
    return _cardShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Container(height: 36, color: bc.foreground.withValues(alpha: 0.85)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BCText('CVV', type: BCTextType.bodyXs, color: BCTextColor.muted),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: bc.surface,
                child: const BCText('314', weight: BCTextWeight.semibold),
              ),
            ],
          ),
          const Spacer(),
          BCText(
            'Tap to flip back',
            type: BCTextType.bodySm,
            color: BCTextColor.muted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'FlipCard',
      variants: [
        UsageVariant(
          title: 'Tap to flip',
          builder: (context) => BCFlipCard(
            front: _cardFront(context),
            back: _cardBack(context),
          ),
        ),
        UsageVariant(
          title: 'Controlled',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              BCFlipCard(
                isFlipped: _showBack,
                flipOnTap: false,
                front: _cardFront(context),
                back: _cardBack(context),
              ),
              BCButton(
                variant: BCButtonVariant.outline,
                onPressed: () => setState(() => _showBack = !_showBack),
                child: Text(
                  _showBack ? 'Hide security code' : 'Show security code',
                ),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Vertical flip',
          builder: (context) => BCFlipCard(
            direction: Axis.vertical,
            front: _cardFront(context),
            back: _cardBack(context),
          ),
        ),
      ],
    );
  }
}
