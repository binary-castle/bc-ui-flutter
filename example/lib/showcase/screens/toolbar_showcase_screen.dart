import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ToolbarShowcaseScreen extends StatelessWidget {
  const ToolbarShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Toolbar',
      variants: [
        UsageVariant(
          title: 'Docked',
          builder: (context) => const _ToolbarCanvas(),
        ),
        UsageVariant(
          title: 'Docked with primary action',
          builder: (context) => const _ToolbarCanvas(withPrimary: true),
        ),
        UsageVariant(
          title: 'Floating',
          builder: (context) => const _ToolbarCanvas(
            variant: BCToolbarVariant.floating,
            withPrimary: true,
          ),
        ),
        UsageVariant(
          title: 'Floating, frosted',
          builder: (context) => const _ToolbarCanvas(
            variant: BCToolbarVariant.floating,
            blurred: true,
          ),
        ),
        UsageVariant(
          title: 'Vertical',
          builder: (context) => const _ToolbarCanvas(vertical: true),
        ),
      ],
    );
  }
}

class _ToolbarCanvas extends StatelessWidget {
  const _ToolbarCanvas({
    this.variant = BCToolbarVariant.docked,
    this.withPrimary = false,
    this.blurred = false,
    this.vertical = false,
  });

  final BCToolbarVariant variant;
  final bool withPrimary;
  final bool blurred;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final toolbar = BCToolbar(
      variant: variant,
      blurred: blurred,
      axis: vertical ? BCToolbarAxis.vertical : BCToolbarAxis.horizontal,
      primaryAction: withPrimary
          ? BCFab(icon: const Icon(Icons.check), size: 48, onPressed: () {})
          : null,
      children: [
        BCHeaderIconButton(icon: const Icon(Icons.undo), onPressed: () {}),
        BCHeaderIconButton(icon: const Icon(Icons.redo), onPressed: () {}),
        BCHeaderIconButton(
          icon: const Icon(Icons.format_bold),
          onPressed: () {},
        ),
        BCHeaderIconButton(
          icon: const Icon(Icons.palette_outlined),
          onPressed: () {},
        ),
      ],
    );

    final canvas = _Artboard(scrollable: blurred);

    return ClipRRect(
      borderRadius: BorderRadius.circular(BCRadius.xxxl),
      child: SizedBox(
        height: 420,
        child: ColoredBox(
          color: bc.background,
          child: vertical
              ? Row(children: [toolbar, Expanded(child: canvas)])
              : Stack(
                  children: [
                    Positioned.fill(child: canvas),
                    if (variant == BCToolbarVariant.floating)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: BCSpacing.md,
                        child: Center(child: toolbar),
                      )
                    else
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: toolbar,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Stand-in content so the frosted variant has something to blur.
class _Artboard extends StatelessWidget {
  const _Artboard({this.scrollable = false});

  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final swatches = [
      bc.accentSoft,
      bc.successSoft,
      bc.warningSoft,
      bc.dangerSoft,
      bc.defaultSoft,
      bc.accentSoft,
    ];

    return ListView(
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(BCSpacing.md),
      children: [
        for (final color in swatches)
          Container(
            height: 88,
            margin: const EdgeInsets.only(bottom: BCSpacing.sm),
            decoration: ShapeDecoration(
              color: color,
              shape: BCShapes.continuous(BCRadius.xxl),
            ),
          ),
      ],
    );
  }
}
