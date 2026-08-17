import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../theme/component_themes/ai_chat_theme.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/bc_duration.dart';
import '../../tokens/bc_radius.dart';
import '../../tokens/bc_shapes.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';
import '../bc_pressable.dart';
import '../bc_spinner.dart';
import 'bc_chat_models.dart';

/// The agent's work for one turn, shown above the reply it produced.
///
/// Collapsed it is a single summary row — *"Worked for 12s · 4 steps"* — that
/// expands into the full list. While anything is still running the list opens
/// itself, so the user watches the work happen; once the turn finishes it
/// collapses back out of the way unless they pinned it open.
///
/// ```dart
/// BCAgentStepList(
///   steps: [
///     BCAgentStep(
///       id: 's1',
///       label: 'Searched the web',
///       detail: 'flutter chat ui packages',
///       status: BCAgentStepStatus.success,
///       duration: Duration(seconds: 2),
///     ),
///     BCAgentStep(id: 's2', label: 'Reading results', status: BCAgentStepStatus.running),
///   ],
/// );
/// ```
class BCAgentStepList extends StatefulWidget {
  const BCAgentStepList({
    super.key,
    required this.steps,
    this.initiallyExpanded,
    this.collapsible = true,
    this.summaryBuilder,
    this.tileBuilder,
    this.backgroundColor,
    this.padding,
    this.reduceMotion,
  });

  final List<BCAgentStep> steps;

  /// Overrides the default, which is "expanded while any step is running".
  final bool? initiallyExpanded;

  /// Whether the summary row can fold the list away. False pins it open and
  /// hides the summary.
  final bool collapsible;

  /// Replaces the default summary row. Receives whether the list is expanded
  /// and a callback that toggles it.
  final Widget Function(BuildContext, bool isExpanded, VoidCallback toggle)?
  summaryBuilder;

  /// Wraps or replaces each tile.
  final Widget Function(BuildContext, BCAgentStep, Widget)? tileBuilder;

  /// Overrides the default `bc.surfaceSecondary`.
  final Color? backgroundColor;

  /// Overrides the default `EdgeInsets.all(10)`.
  final EdgeInsetsGeometry? padding;

  /// Overrides `MediaQuery.disableAnimationsOf`.
  final bool? reduceMotion;

  @override
  State<BCAgentStepList> createState() => _BCAgentStepListState();
}

class _BCAgentStepListState extends State<BCAgentStepList> {
  bool? _userChoice;

  bool get _anyRunning => widget.steps.any((step) => step.isActive);

  /// The user's explicit choice wins; otherwise the list follows the work.
  bool get _isExpanded =>
      !widget.collapsible ||
      (_userChoice ?? widget.initiallyExpanded ?? _anyRunning);

  Duration get _elapsed {
    var total = Duration.zero;
    void walk(List<BCAgentStep> steps) {
      for (final step in steps) {
        total += step.duration ?? Duration.zero;
        walk(step.children);
      }
    }

    walk(widget.steps);
    return total;
  }

  int get _count {
    var total = 0;
    void walk(List<BCAgentStep> steps) {
      for (final step in steps) {
        total++;
        walk(step.children);
      }
    }

    walk(widget.steps);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    final still =
        widget.reduceMotion ?? MediaQuery.disableAnimationsOf(context);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        for (final step in widget.steps)
          Builder(
            builder: (context) {
              final tile = BCAgentStepTile(step: step, reduceMotion: still);
              return widget.tileBuilder?.call(context, step, tile) ?? tile;
            },
          ),
      ],
    );

    return Container(
      decoration: ShapeDecoration(
        color: widget.backgroundColor ?? bc.surfaceSecondary,
        shape: BCShapes.continuous(BCRadius.xl),
      ),
      padding: widget.padding ?? const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.collapsible)
            widget.summaryBuilder?.call(context, _isExpanded, _toggle) ??
                _summary(bc),
          AnimatedSize(
            duration: still ? Duration.zero : BCDuration.normal,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.only(
                      top: widget.collapsible ? BCSpacing.sm : 0,
                    ),
                    child: body,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  void _toggle() => setState(() => _userChoice = !_isExpanded);

  Widget _summary(BCThemeExtension bc) {
    final running = _anyRunning;
    final elapsed = _elapsed;
    final parts = <String>[
      if (running)
        'Working'
      else if (elapsed > Duration.zero)
        'Worked for ${_formatDuration(elapsed)}'
      else
        'Done',
      '$_count ${_count == 1 ? 'step' : 'steps'}',
    ];

    return Semantics(
      button: true,
      expanded: _isExpanded,
      child: BCPressable(
        onPressed: _toggle,
        feedback: BCPressFeedback.highlight,
        shape: BCShapes.continuous(BCRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            spacing: BCSpacing.sm,
            children: [
              if (running)
                const BCSpinner(size: BCSpinnerSize.sm)
              else
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 15,
                  color: bc.muted,
                ),
              Expanded(
                child: Text(
                  parts.join(' · '),
                  style: BCTypography.textSm.copyWith(
                    color: bc.muted,
                    fontWeight: BCTypography.medium,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: BCDuration.fast,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: bc.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One row in a [BCAgentStepList].
///
/// Tapping it reveals the step's [BCAgentStep.output]. A step with neither
/// output nor children is not tappable, since there would be nothing to show.
class BCAgentStepTile extends StatefulWidget {
  const BCAgentStepTile({
    super.key,
    required this.step,
    this.depth = 0,
    this.reduceMotion = false,
  });

  final BCAgentStep step;

  /// Indent level. Nesting beyond one level renders flat.
  final int depth;

  final bool reduceMotion;

  @override
  State<BCAgentStepTile> createState() => _BCAgentStepTileState();
}

class _BCAgentStepTileState extends State<BCAgentStepTile> {
  bool _expanded = false;

  bool get _hasDetail =>
      widget.step.output != null || widget.step.children.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final step = widget.step;
    final color = BCAIChatTheme.stepColor(status: step.status, bc: bc);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: BCSpacing.sm,
        children: [
          SizedBox(
            width: 16,
            height: 18,
            child: Center(child: _leading(bc, color)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step.label,
                  style: BCTypography.textSm.copyWith(
                    color: step.status == BCAgentStepStatus.skipped
                        ? bc.muted
                        : bc.foreground,
                  ),
                ),
                if (step.detail != null)
                  Text(
                    step.detail!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: BCTypography.textXs.copyWith(color: bc.muted),
                  ),
              ],
            ),
          ),
          if (step.duration != null)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                _formatDuration(step.duration!),
                style: BCTypography.textXs.copyWith(color: bc.muted),
              ),
            ),
          if (_hasDetail)
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: widget.reduceMotion ? Duration.zero : BCDuration.fast,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: bc.muted,
              ),
            ),
        ],
      ),
    );

    final head = _hasDetail
        ? Semantics(
            button: true,
            expanded: _expanded,
            child: BCPressable(
              onPressed: () => setState(() => _expanded = !_expanded),
              feedback: BCPressFeedback.highlight,
              shape: BCShapes.continuous(BCRadius.md),
              child: row,
            ),
          )
        : row;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: widget.depth > 0 ? 12 : 0),
      child: Container(
        decoration: widget.depth > 0
            ? BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: bc.separator),
                ),
              )
            : null,
        padding: EdgeInsetsDirectional.only(start: widget.depth > 0 ? 8 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            head,
            AnimatedSize(
              duration: widget.reduceMotion ? Duration.zero : BCDuration.fast,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: BCSpacing.xs,
                      children: [
                        if (step.output != null) _output(bc, step.output!),
                        for (final child in step.children)
                          BCAgentStepTile(
                            step: child,
                            depth: widget.depth + 1,
                            reduceMotion: widget.reduceMotion,
                          ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leading(BCThemeExtension bc, Color color) {
    if (widget.step.status == BCAgentStepStatus.running) {
      return const BCSpinner(size: BCSpinnerSize.sm);
    }
    final icon =
        widget.step.icon ??
        switch (widget.step.status) {
          BCAgentStepStatus.success => Icons.check_rounded,
          BCAgentStepStatus.error => Icons.close_rounded,
          BCAgentStepStatus.skipped => Icons.remove_rounded,
          BCAgentStepStatus.pending => Icons.circle_outlined,
          BCAgentStepStatus.running => Icons.circle_outlined,
        };
    return Icon(icon, size: 14, color: color);
  }

  Widget _output(BCThemeExtension bc, String output) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 24, top: 2),
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: bc.background,
        shape: BCShapes.continuous(BCRadius.lg),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          output,
          style: BCAIChatTheme.monospace(bc.muted, fontSize: 11),
        ),
      ),
    );
  }
}

/// Renders a duration the way a progress log would — "820ms", "12s", "3m 4s".
String _formatDuration(Duration duration) {
  if (duration.inMilliseconds < 1000) return '${duration.inMilliseconds}ms';
  if (duration.inSeconds < 60) {
    final seconds = duration.inMilliseconds / 1000;
    return seconds >= 10
        ? '${seconds.round()}s'
        : '${seconds.toStringAsFixed(1)}s';
  }
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return seconds == 0 ? '${minutes}m' : '${minutes}m ${seconds}s';
}
