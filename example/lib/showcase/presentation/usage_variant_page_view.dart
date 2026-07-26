import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One usage-variant section of a component showcase screen.
class UsageVariant {
  const UsageVariant({required this.title, required this.builder});

  final String title;
  final WidgetBuilder builder;
}

/// Mirrors heroui-native's `usage-variant-flatlist`: full-screen vertically
/// paged sections with a stacked pagination label list at the bottom-left,
/// a scale interpolation around each page, and a light haptic on settle.
class UsageVariantPageView extends StatefulWidget {
  const UsageVariantPageView({super.key, required this.variants});

  final List<UsageVariant> variants;

  @override
  State<UsageVariantPageView> createState() => _UsageVariantPageViewState();
}

class _UsageVariantPageViewState extends State<UsageVariantPageView> {
  final PageController _controller = PageController();
  double _page = 0;
  int _settledPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final page = _controller.page ?? 0;
    setState(() => _page = page);
    final settled = page.round();
    if ((page - settled).abs() < 0.01 && settled != _settledPage) {
      _settledPage = settled;
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          scrollDirection: Axis.vertical,
          itemCount: widget.variants.length,
          itemBuilder: (context, index) {
            final delta = (_page - index).abs().clamp(0.0, 1.0);
            final scale = 1 - 0.1 * delta;

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: 1 - 0.35 * delta,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: widget.variants[index].builder(context),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        PositionedDirectional(
          start: 24,
          bottom: 24,
          child: _PaginationIndicator(
            titles: [for (final v in widget.variants) v.title],
            activeIndex: _page.round().clamp(0, widget.variants.length - 1),
            onSelect: (index) => _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      ],
    );
  }
}

/// Stacked section labels, active one highlighted (pagination-indicator.tsx).
class _PaginationIndicator extends StatelessWidget {
  const _PaginationIndicator({
    required this.titles,
    required this.activeIndex,
    required this.onSelect,
  });

  final List<String> titles;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < titles.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == activeIndex ? 16 : 6,
                    height: 3,
                    decoration: BoxDecoration(
                      color: i == activeIndex ? bc.accent : bc.separator,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: BCTypography.textSm.copyWith(
                      color: i == activeIndex ? bc.foreground : bc.muted,
                      fontWeight: i == activeIndex
                          ? BCTypography.semiBold
                          : BCTypography.regular,
                    ),
                    child: Text(titles[i]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Standard scaffold for a component showcase screen.
class ComponentShowcaseScaffold extends StatelessWidget {
  const ComponentShowcaseScaffold({
    super.key,
    required this.title,
    required this.variants,
  });

  final String title;
  final List<UsageVariant> variants;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: UsageVariantPageView(variants: variants),
    );
  }
}
