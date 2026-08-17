import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../tokens/bc_duration.dart';
import '../../tokens/bc_radius.dart';
import '../../tokens/bc_shapes.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';
import '../bc_pressable.dart';
import '../bc_scroll_shadow.dart';
import 'bc_chat_bubble.dart';
import 'bc_chat_controller.dart';
import 'bc_chat_models.dart';

/// The scrolling transcript.
///
/// It follows the bottom while the user is reading the newest message, and
/// stops following the moment they scroll up — a reply streaming in never
/// yanks the view away from something being read. A pill appears while they
/// are away from the bottom to take them back.
///
/// Drive it with a [BCChatController], or hand it a plain [messages] list if
/// your state lives elsewhere.
class BCChatThread extends StatefulWidget {
  const BCChatThread({
    super.key,
    this.controller,
    this.messages,
    this.scrollController,
    this.variant = BCChatBubbleVariant.plain,
    this.messageBuilder,
    this.contentBuilder,
    this.attachmentBuilder,
    this.stepBuilder,
    this.avatarBuilder,
    this.dateSeparatorBuilder,
    this.emptyBuilder,
    this.header,
    this.footer,
    this.actionsBuilder,
    this.onLinkTap,
    this.onMessageLongPress,
    this.padding,
    this.messageSpacing = BCSpacing.md,
    this.showScrollShadow = true,
    this.showJumpToBottom = true,
    this.autoScrollThreshold = 80,
    this.showDateSeparators = true,
    this.typingLabel,
    this.maxWidthFactor,
    this.reduceMotion,
  }) : assert(
         controller != null || messages != null,
         'BCChatThread needs either a controller or a messages list',
       );

  /// The thread's state. Either this or [messages] must be set.
  final BCChatController? controller;

  /// A plain list, for when the state lives in your own store. Ignored when
  /// [controller] is set.
  final List<BCChatMessage>? messages;

  /// Pass your own to drive the scroll position from outside. One is created
  /// and disposed here otherwise.
  final ScrollController? scrollController;

  /// How assistant messages are drawn.
  final BCChatBubbleVariant variant;

  /// Wraps or replaces a whole message row.
  final Widget Function(BuildContext, BCChatMessage, Widget)? messageBuilder;

  /// Replaces the markdown body of a message.
  final Widget Function(BuildContext, BCChatMessage)? contentBuilder;

  /// Wraps or replaces each attachment chip.
  final Widget Function(BuildContext, BCChatAttachment, Widget)?
  attachmentBuilder;

  /// Wraps or replaces each agent-step tile.
  final Widget Function(BuildContext, BCAgentStep, Widget)? stepBuilder;

  /// The avatar for a message. Return null for no avatar — the default.
  final Widget? Function(BuildContext, BCChatMessage)? avatarBuilder;

  /// Replaces the default centred date chip.
  final Widget Function(BuildContext, DateTime)? dateSeparatorBuilder;

  /// What to show on an empty thread.
  final WidgetBuilder? emptyBuilder;

  /// Pinned above the first message — a model picker, a system notice.
  final Widget? header;

  /// Pinned below the last message.
  final Widget? footer;

  /// The actions offered on a message. Return an empty list for none.
  final List<BCChatMessageAction> Function(BuildContext, BCChatMessage)?
  actionsBuilder;

  final ValueChanged<String>? onLinkTap;

  final void Function(BCChatMessage)? onMessageLongPress;

  /// Overrides the default `EdgeInsets.symmetric(horizontal: 16, vertical: 12)`.
  final EdgeInsetsGeometry? padding;

  final double messageSpacing;

  /// Fades content out under the top edge. Needs a flat background behind the
  /// list, since the shadow is a solid-to-transparent gradient.
  final bool showScrollShadow;

  final bool showJumpToBottom;

  /// How close to the bottom the user has to be for new content to keep
  /// scrolling into view.
  final double autoScrollThreshold;

  final bool showDateSeparators;

  /// Text beside the typing dots.
  final String? typingLabel;

  /// Forwarded to each bubble.
  final double? maxWidthFactor;

  /// Overrides `MediaQuery.disableAnimationsOf`.
  final bool? reduceMotion;

  @override
  State<BCChatThread> createState() => _BCChatThreadState();
}

class _BCChatThreadState extends State<BCChatThread> {
  late ScrollController _scroll = widget.scrollController ?? ScrollController();
  bool _ownsScroll = false;
  bool _atBottom = true;
  int _lastCount = 0;
  String _lastSignature = '';

  @override
  void initState() {
    super.initState();
    _ownsScroll = widget.scrollController == null;
    _scroll.addListener(_onScroll);
    widget.controller?.addListener(_onMessagesChanged);
    _lastCount = _messages.length;
    _lastSignature = _signature;
  }

  @override
  void didUpdateWidget(BCChatThread oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onMessagesChanged);
      widget.controller?.addListener(_onMessagesChanged);
    }

    if (oldWidget.scrollController != widget.scrollController) {
      _scroll.removeListener(_onScroll);
      if (_ownsScroll) _scroll.dispose();
      _scroll = widget.scrollController ?? ScrollController();
      _ownsScroll = widget.scrollController == null;
      _scroll.addListener(_onScroll);
    }

    // A plain `messages` list changes by rebuild, not by notification.
    if (widget.controller == null) _onMessagesChanged();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onMessagesChanged);
    _scroll.removeListener(_onScroll);
    if (_ownsScroll) _scroll.dispose();
    super.dispose();
  }

  List<BCChatMessage> get _messages =>
      widget.controller?.messages ?? widget.messages ?? const [];

  /// Cheap change detector — the id and text length of the last message is
  /// enough to catch both a new message and a streamed chunk.
  String get _signature {
    final last = _messages.isEmpty ? null : _messages.last;
    return last == null ? '' : '${last.id}:${last.text.length}';
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final atBottom =
        position.maxScrollExtent - position.pixels <=
        widget.autoScrollThreshold;
    if (atBottom != _atBottom) setState(() => _atBottom = atBottom);
  }

  void _onMessagesChanged() {
    final signature = _signature;
    final count = _messages.length;
    if (signature == _lastSignature && count == _lastCount) return;

    // A message the user just sent always pulls the view down; anything else
    // only does when they were already at the bottom.
    final isOwnSend =
        count > _lastCount &&
        _messages.isNotEmpty &&
        _messages.last.role == BCChatRole.user;

    _lastSignature = signature;
    _lastCount = count;

    if (_atBottom || isOwnSend) _scheduleScrollToBottom();
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  /// Animates to the newest message. Exposed through the jump-to-bottom pill.
  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    final still =
        widget.reduceMotion ?? MediaQuery.disableAnimationsOf(context);
    if (still) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
      return;
    }
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: BCDuration.normal,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (controller == null) return _buildList(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    final messages = _messages;

    if (messages.isEmpty && widget.header == null && widget.footer == null) {
      return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }

    final rows = _buildRows(context, messages);

    Widget list = ListView.separated(
      controller: _scroll,
      padding:
          widget.padding ??
          const EdgeInsets.symmetric(
            horizontal: BCSpacing.md,
            vertical: BCSpacing.sm + 4,
          ),
      itemCount: rows.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: widget.messageSpacing),
      itemBuilder: (context, index) => rows[index],
    );

    if (widget.showScrollShadow) list = BCScrollShadow(child: list);

    if (!widget.showJumpToBottom) return list;

    return Stack(
      children: [
        Positioned.fill(child: list),
        Positioned(
          bottom: BCSpacing.sm,
          left: 0,
          right: 0,
          child: _JumpToBottomPill(
            visible: !_atBottom,
            onPressed: _jumpToBottom,
            reduceMotion: widget.reduceMotion,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRows(BuildContext context, List<BCChatMessage> messages) {
    final rows = <Widget>[];

    if (widget.header != null) rows.add(widget.header!);

    DateTime? lastDay;
    for (final message in messages) {
      if (widget.showDateSeparators && message.createdAt != null) {
        final at = message.createdAt!;
        final day = DateTime(at.year, at.month, at.day);
        if (lastDay == null || day != lastDay) {
          lastDay = day;
          rows.add(
            widget.dateSeparatorBuilder?.call(context, day) ??
                _DateSeparator(day: day),
          );
        }
      }

      final view = BCChatMessageView(
        message: message,
        variant: widget.variant,
        avatar: widget.avatarBuilder?.call(context, message),
        actions:
            widget.actionsBuilder?.call(context, message) ??
            const <BCChatMessageAction>[],
        contentBuilder: widget.contentBuilder,
        attachmentBuilder: widget.attachmentBuilder,
        stepBuilder: widget.stepBuilder,
        onLinkTap: widget.onLinkTap,
        onLongPress: widget.onMessageLongPress == null
            ? null
            : () => widget.onMessageLongPress!(message),
        typingLabel: widget.typingLabel,
        maxWidthFactor: widget.maxWidthFactor,
        reduceMotion: widget.reduceMotion,
      );

      rows.add(widget.messageBuilder?.call(context, message, view) ?? view);
    }

    if (widget.footer != null) rows.add(widget.footer!);
    return rows;
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: ShapeDecoration(
          color: bc.surfaceSecondary,
          shape: BCShapes.continuous(BCRadius.full),
        ),
        child: Text(
          _label(day),
          style: BCTypography.textXs.copyWith(color: bc.muted),
        ),
      ),
    );
  }

  static String _label(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(day).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${day.year}-${_two(day.month)}-${_two(day.day)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _JumpToBottomPill extends StatelessWidget {
  const _JumpToBottomPill({
    required this.visible,
    required this.onPressed,
    this.reduceMotion,
  });

  final bool visible;
  final VoidCallback onPressed;
  final bool? reduceMotion;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final still = reduceMotion ?? MediaQuery.disableAnimationsOf(context);

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: still ? Duration.zero : BCDuration.fast,
        child: Center(
          child: Semantics(
            button: true,
            label: 'Jump to latest message',
            child: BCPressable(
              onPressed: onPressed,
              feedback: BCPressFeedback.scaleHighlight,
              shape: BCShapes.continuous(BCRadius.full),
              child: Container(
                decoration: ShapeDecoration(
                  color: bc.surface,
                  shape: BCShapes.continuous(
                    BCRadius.full,
                    side: bc.overlayShadow.innerBorder ?? BorderSide.none,
                  ),
                  shadows: bc.overlayShadow.shadows,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 14,
                      color: bc.foreground,
                    ),
                    Text(
                      'Latest',
                      style: BCTypography.textSm.copyWith(
                        color: bc.foreground,
                        fontWeight: BCTypography.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
