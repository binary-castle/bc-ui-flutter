import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../theme/component_themes/ai_chat_theme.dart';
import '../../tokens/bc_duration.dart';
import '../../tokens/bc_radius.dart';
import '../../tokens/bc_shapes.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';
import '../bc_pressable.dart';
import 'bc_agent_steps.dart';
import 'bc_chat_attachments.dart';
import 'bc_chat_markdown.dart';
import 'bc_chat_models.dart';

export '../../theme/component_themes/ai_chat_theme.dart'
    show BCChatBubbleVariant;

/// The container a message's content sits in.
///
/// This draws the fill, the asymmetric corners and the width cap, and nothing
/// else — it takes any [child], so it is equally the right box for text, an
/// image grid, or a rich card of your own.
class BCChatBubble extends StatelessWidget {
  const BCChatBubble({
    super.key,
    required this.child,
    this.role = BCChatRole.assistant,
    this.variant = BCChatBubbleVariant.plain,
    this.backgroundColor,
    this.shape,
    this.padding,
    this.maxWidthFactor,
    this.alignment,
  });

  final Widget child;

  final BCChatRole role;

  /// How an assistant message is drawn. Ignored for the other roles, which
  /// are always filled.
  final BCChatBubbleVariant variant;

  /// Overrides the fill derived from [role] and [variant].
  final Color? backgroundColor;

  /// Overrides the default asymmetric continuous shape.
  final ShapeBorder? shape;

  /// Overrides the default `EdgeInsets.symmetric(horizontal: 14, vertical: 10)`
  /// — or `EdgeInsets.zero` for a plain assistant message, which is unboxed.
  final EdgeInsetsGeometry? padding;

  /// Fraction of the available width the bubble may occupy. Overrides the
  /// default 0.78. A plain assistant message ignores this and takes the full
  /// measure.
  final double? maxWidthFactor;

  /// Overrides the side the bubble is pinned to, which otherwise follows
  /// [role].
  final AlignmentGeometry? alignment;

  bool get _isMine => role == BCChatRole.user;

  bool get _isPlain =>
      role == BCChatRole.assistant && variant == BCChatBubbleVariant.plain;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final direction = Directionality.of(context);
    final background =
        backgroundColor ??
        BCAIChatTheme.bubbleBackground(role: role, variant: variant, bc: bc);
    final foreground = BCAIChatTheme.bubbleForeground(
      role: role,
      variant: variant,
      bc: bc,
    );

    final resolvedAlignment =
        alignment ??
        switch (role) {
          BCChatRole.user => AlignmentDirectional.centerEnd,
          BCChatRole.assistant => AlignmentDirectional.centerStart,
          BCChatRole.system => Alignment.center,
        };

    Widget content = DefaultTextStyle.merge(
      style: BCTypography.textBase.copyWith(color: foreground, height: 1.5),
      child: child,
    );

    if (_isPlain) {
      content = Padding(padding: padding ?? EdgeInsets.zero, child: content);
    } else {
      content = Container(
        decoration: ShapeDecoration(
          color: background,
          shape:
              shape ??
              BCAIChatTheme.bubbleShape(isMine: _isMine, direction: direction),
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: content,
      );
    }

    if (_isPlain) {
      return Align(alignment: resolvedAlignment, child: content);
    }

    return Align(
      alignment: resolvedAlignment,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final factor = maxWidthFactor ?? BCAIChatTheme.maxWidthFactor;
          final cap = constraints.maxWidth.isFinite
              ? constraints.maxWidth * factor
              : double.infinity;
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cap),
            child: content,
          );
        },
      ),
    );
  }
}

/// Three dots that rise and fade in sequence — the assistant is composing but
/// has produced nothing to show yet.
///
/// Freezes to three static dots when animations are disabled.
class BCChatTypingIndicator extends StatefulWidget {
  const BCChatTypingIndicator({
    super.key,
    this.color,
    this.dotSize = 7,
    this.label,
  });

  /// Overrides the default `bc.muted`.
  final Color? color;

  final double dotSize;

  /// Optional text beside the dots — "Thinking", "Searching the web".
  final String? label;

  @override
  State<BCChatTypingIndicator> createState() => _BCChatTypingIndicatorState();
}

class _BCChatTypingIndicatorState extends State<BCChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final color = widget.color ?? bc.muted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: BCSpacing.sm,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            for (var i = 0; i < 3; i++)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  // Each dot runs the same curve a third of a cycle apart.
                  final phase = (_controller.value - i * 0.18) % 1.0;
                  final wave = phase < 0.5
                      ? Curves.easeOut.transform(phase * 2)
                      : Curves.easeIn.transform((1 - phase) * 2);
                  return Opacity(
                    opacity: 0.35 + wave * 0.65,
                    child: Transform.translate(
                      offset: Offset(0, -wave * 2.5),
                      child: Container(
                        width: widget.dotSize,
                        height: widget.dotSize,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        if (widget.label != null)
          Text(
            widget.label!,
            style: BCTypography.textSm.copyWith(color: color),
          ),
      ],
    );
  }
}

/// One action offered on a message — copy, regenerate, edit, a rating.
@immutable
class BCChatMessageAction {
  const BCChatMessageAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  final IconData icon;

  /// The tooltip, and the accessibility label.
  final String label;

  final VoidCallback onPressed;

  /// Tints the action with `bc.danger`.
  final bool isDestructive;
}

/// The row of actions under a message.
///
/// On a device with a mouse these fade in on hover; on touch they are always
/// visible, because there is nothing to hover with.
class BCChatMessageActions extends StatefulWidget {
  const BCChatMessageActions({
    super.key,
    required this.actions,
    this.alwaysVisible = false,
    this.alignment = MainAxisAlignment.start,
  });

  final List<BCChatMessageAction> actions;

  /// Skips the hover gate. Defaults to false, which still shows the row on
  /// touch devices — hover only gates where hovering is possible.
  final bool alwaysVisible;

  final MainAxisAlignment alignment;

  @override
  State<BCChatMessageActions> createState() => _BCChatMessageActionsState();
}

class _BCChatMessageActionsState extends State<BCChatMessageActions> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    if (widget.actions.isEmpty) return const SizedBox.shrink();

    // Touch devices never report hover, so gating on it there would hide the
    // row forever.
    final gatesOnHover =
        !widget.alwaysVisible &&
        switch (defaultTargetPlatform) {
          TargetPlatform.macOS ||
          TargetPlatform.windows ||
          TargetPlatform.linux => true,
          _ => false,
        };

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedOpacity(
        opacity: !gatesOnHover || _hovered ? 1 : 0,
        duration: BCDuration.fast,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: widget.alignment,
          spacing: 2,
          children: [
            for (final action in widget.actions)
              Semantics(
                button: true,
                label: action.label,
                child: BCPressable(
                  onPressed: action.onPressed,
                  feedback: BCPressFeedback.highlight,
                  shape: BCShapes.continuous(BCRadius.md),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      action.icon,
                      size: 16,
                      color: action.isDestructive ? bc.danger : bc.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A full message row: avatar, bubble, attachments, agent steps and actions.
///
/// This is what a `BCChatThread` renders per message. Use it directly if you
/// are building your own list but want the message layout for free.
class BCChatMessageView extends StatelessWidget {
  const BCChatMessageView({
    super.key,
    required this.message,
    this.variant = BCChatBubbleVariant.plain,
    this.avatar,
    this.actions = const <BCChatMessageAction>[],
    this.contentBuilder,
    this.attachmentBuilder,
    this.stepBuilder,
    this.onLinkTap,
    this.onLongPress,
    this.showTypingIndicator = true,
    this.typingLabel,
    this.maxWidthFactor,
    this.avatarGap = BCSpacing.sm,
    this.reduceMotion,
  });

  final BCChatMessage message;

  final BCChatBubbleVariant variant;

  /// Leading avatar. Null renders no avatar and no gutter — the default,
  /// since a two-party chat reads fine without one.
  final Widget? avatar;

  final List<BCChatMessageAction> actions;

  /// Replaces the default markdown body. Use it to swap in a full CommonMark
  /// renderer, or to render your own `metadata`-driven card.
  final Widget Function(BuildContext, BCChatMessage)? contentBuilder;

  /// Wraps or replaces each attachment chip.
  final Widget Function(BuildContext, BCChatAttachment, Widget)?
  attachmentBuilder;

  /// Wraps or replaces each agent step tile.
  final Widget Function(BuildContext, BCAgentStep, Widget)? stepBuilder;

  final ValueChanged<String>? onLinkTap;

  final VoidCallback? onLongPress;

  /// Whether an assistant message with no body yet shows the typing dots.
  final bool showTypingIndicator;

  /// Text beside the typing dots.
  final String? typingLabel;

  /// Forwarded to [BCChatBubble.maxWidthFactor].
  final double? maxWidthFactor;

  /// Gap between the avatar and the bubble.
  final double avatarGap;

  /// Overrides `MediaQuery.disableAnimationsOf`.
  final bool? reduceMotion;

  bool get _isUser => message.role == BCChatRole.user;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final isSystem = message.role == BCChatRole.system;

    if (isSystem) {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: BCSpacing.xs),
          child: Text(
            message.text,
            textAlign: TextAlign.center,
            style: BCTypography.textSm.copyWith(color: bc.muted),
          ),
        ),
      );
    }

    final body = _buildBody(context);

    Widget bubble = BCChatBubble(
      role: message.role,
      variant: variant,
      maxWidthFactor: maxWidthFactor,
      child: body,
    );

    if (onLongPress != null) {
      bubble = BCPressable(
        onLongPress: onLongPress,
        feedback: BCPressFeedback.none,
        behavior: HitTestBehavior.deferToChild,
        child: bubble,
      );
    }

    final column = Column(
      crossAxisAlignment: _isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: BCSpacing.xs,
      children: [
        bubble,
        if (actions.isNotEmpty && !message.isStreaming)
          BCChatMessageActions(
            actions: actions,
            alignment: _isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
          ),
      ],
    );

    if (avatar == null) return column;

    // The avatar sits on the author's side: trailing for the user, leading
    // for the assistant.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: avatarGap,
      children: [
        if (!_isUser) avatar!,
        Expanded(child: column),
        if (_isUser) avatar!,
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final bc = context.bcTheme;
    final children = <Widget>[];

    if (message.attachments.isNotEmpty) {
      children.add(
        BCChatAttachmentStrip(
          attachments: message.attachments,
          isEditable: false,
          chipBuilder: attachmentBuilder,
        ),
      );
    }

    if (message.steps.isNotEmpty) {
      children.add(
        BCAgentStepList(
          steps: message.steps,
          tileBuilder: stepBuilder,
          reduceMotion: reduceMotion,
        ),
      );
    }

    if (message.status == BCChatMessageStatus.failed) {
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: BCSpacing.xs,
          children: [
            Icon(Icons.error_outline_rounded, size: 16, color: bc.danger),
            Flexible(
              child: Text(
                message.error ?? 'Something went wrong.',
                style: BCTypography.textSm.copyWith(color: bc.danger),
              ),
            ),
          ],
        ),
      );
    } else if (message.text.trim().isNotEmpty) {
      children.add(
        contentBuilder?.call(context, message) ??
            _StreamingBody(
              message: message,
              onLinkTap: onLinkTap,
              reduceMotion: reduceMotion,
            ),
      );
    } else if (message.isStreaming && showTypingIndicator) {
      children.add(BCChatTypingIndicator(label: typingLabel));
    }

    if (children.isEmpty) return const SizedBox.shrink();
    if (children.length == 1) return children.single;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: BCSpacing.sm,
      children: children,
    );
  }
}

/// The markdown body, with a caret blinking at the end while tokens are still
/// arriving.
class _StreamingBody extends StatefulWidget {
  const _StreamingBody({
    required this.message,
    this.onLinkTap,
    this.reduceMotion,
  });

  final BCChatMessage message;
  final ValueChanged<String>? onLinkTap;
  final bool? reduceMotion;

  @override
  State<_StreamingBody> createState() => _StreamingBodyState();
}

class _StreamingBodyState extends State<_StreamingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _caret = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncCaret();
  }

  @override
  void didUpdateWidget(_StreamingBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCaret();
  }

  void _syncCaret() {
    final still =
        widget.reduceMotion ?? MediaQuery.disableAnimationsOf(context);
    if (widget.message.isStreaming && !still) {
      if (!_caret.isAnimating) _caret.repeat();
    } else if (_caret.isAnimating) {
      _caret.stop();
    }
  }

  @override
  void dispose() {
    _caret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final markdown = BCChatMarkdown(
      data: widget.message.text,
      onLinkTap: widget.onLinkTap,
    );

    if (!widget.message.isStreaming) return markdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        markdown,
        AnimatedBuilder(
          animation: _caret,
          builder: (context, _) {
            // A square wave: on for the first half of the cycle, off for the
            // second — a caret that faded would read as a rendering glitch.
            final visible = !_caret.isAnimating || _caret.value < 0.5;
            return Opacity(
              opacity: visible ? 1 : 0,
              child: Container(
                width: 7,
                height: 15,
                margin: const EdgeInsets.only(top: 2),
                color: bc.accent,
              ),
            );
          },
        ),
      ],
    );
  }
}
