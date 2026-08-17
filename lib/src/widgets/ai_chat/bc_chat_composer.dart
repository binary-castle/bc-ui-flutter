import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/bc_duration.dart';
import '../../tokens/bc_radius.dart';
import '../../tokens/bc_shapes.dart';
import '../../tokens/bc_spacing.dart';
import '../bc_input.dart';
import '../bc_pressable.dart';
import '../bc_spinner.dart';
import 'bc_chat_attachments.dart';
import 'bc_chat_controller.dart';
import 'bc_chat_models.dart';

/// Where the composer's buttons sit.
///
/// [inline] puts them on the same row as the text, in the field's prefix and
/// suffix slots — the pill every mobile assistant uses. [stacked] puts the
/// text on its own row with the buttons underneath, which is what desktop
/// assistants do once the draft can run to paragraphs.
enum BCChatComposerLayout { inline, stacked }

/// What the Enter key does.
///
/// [enter] sends, and Shift+Enter inserts a newline. [modifierEnter] is the
/// reverse: Enter inserts a newline and Cmd/Ctrl+Enter sends. [buttonOnly]
/// leaves Enter as a plain newline, so only the button sends.
enum BCChatSubmitBehavior { enter, modifierEnter, buttonOnly }

/// The input row: a draft that grows with its content, staged attachments,
/// and the send button that becomes a stop button while the agent works.
///
/// The text field grows from one line up to [maxLines] and then scrolls, so
/// a long paste never pushes the transcript off screen.
///
/// bc_ui does no file picking. Wire [onAttachPressed] to your own picker and
/// hand what it returns to [BCChatComposerController.addAttachments].
///
/// ```dart
/// BCChatComposer(
///   controller: _composer,
///   isGenerating: _chat.isGenerating,
///   onSend: _send,
///   onStop: _cancel,
///   onAttachPressed: _pickFiles,
///   onVoicePressed: _openVoiceMode,
/// );
/// ```
class BCChatComposer extends StatefulWidget {
  const BCChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.focusNode,
    this.layout = BCChatComposerLayout.inline,
    this.submitBehavior,
    this.placeholder = 'Ask anything',
    this.isGenerating = false,
    this.isDisabled = false,
    this.onStop,
    this.onAttachPressed,
    this.onVoicePressed,
    this.onContentInserted,
    this.onAttachmentRemoved,
    this.attachmentBuilder,
    this.leading = const <Widget>[],
    this.trailing = const <Widget>[],
    this.maxLines = 6,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.autofocus = false,
  });

  /// Owns the draft text and the staged attachments.
  final BCChatComposerController controller;

  /// Called with the trimmed draft when the user sends. The composer does not
  /// clear itself — call [BCChatComposerController.reset] once you have taken
  /// the text, so a failed send can leave the draft in place.
  final void Function(String text, List<BCChatAttachment> attachments) onSend;

  final FocusNode? focusNode;

  final BCChatComposerLayout layout;

  /// Overrides the per-platform default: [BCChatSubmitBehavior.enter] on
  /// desktop and web, [BCChatSubmitBehavior.buttonOnly] on phones and
  /// tablets, where Enter has to stay a newline.
  final BCChatSubmitBehavior? submitBehavior;

  final String placeholder;

  /// Whether the agent is mid-turn. Swaps send for stop.
  final bool isGenerating;

  final bool isDisabled;

  /// Called when the stop button is pressed. The stop button only appears
  /// when this is set and [isGenerating] is true.
  final VoidCallback? onStop;

  /// Called when the attach button is pressed. The button only appears when
  /// this is set.
  final VoidCallback? onAttachPressed;

  /// Called when the mic button is pressed. The button only appears when
  /// this is set.
  final VoidCallback? onVoicePressed;

  /// Called when the keyboard or clipboard inserts an image. Android only —
  /// see [BCInput.contentInsertionConfiguration].
  final ValueChanged<KeyboardInsertedContent>? onContentInserted;

  /// Called when an attachment's remove badge is tapped. Defaults to removing
  /// it from [controller].
  final ValueChanged<BCChatAttachment>? onAttachmentRemoved;

  /// Wraps or replaces each staged attachment chip.
  final Widget Function(BuildContext, BCChatAttachment, Widget)?
  attachmentBuilder;

  /// Extra buttons before the attach button.
  final List<Widget> leading;

  /// Extra buttons after the mic button, before send.
  final List<Widget> trailing;

  /// How many lines the draft grows to before it starts scrolling instead.
  /// Overrides the default 6.
  final int maxLines;

  /// Overrides the default `EdgeInsets.all(8)` inside the composer surface.
  final EdgeInsetsGeometry? padding;

  /// Overrides the default `bc.field`.
  final Color? backgroundColor;

  /// Overrides the default [BCRadius.xxl].
  final double? borderRadius;

  final bool autofocus;

  @override
  State<BCChatComposer> createState() => _BCChatComposerState();
}

class _BCChatComposerState extends State<BCChatComposer> {
  FocusNode? _internalNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalNode ??= FocusNode());

  BCChatSubmitBehavior get _submitBehavior {
    if (widget.submitBehavior != null) return widget.submitBehavior!;
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => BCChatSubmitBehavior.enter,
      _ => BCChatSubmitBehavior.buttonOnly,
    };
  }

  @override
  void dispose() {
    _internalNode?.dispose();
    super.dispose();
  }

  void _send() {
    if (!widget.controller.canSend || widget.isDisabled) return;
    widget.onSend(
      widget.controller.text.text.trim(),
      List<BCChatAttachment>.of(widget.controller.attachments),
    );
  }

  void _removeAttachment(BCChatAttachment attachment) {
    if (widget.onAttachmentRemoved != null) {
      widget.onAttachmentRemoved!(attachment);
      return;
    }
    widget.controller.removeAttachment(attachment.id);
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => _buildComposer(context, bc),
    );
  }

  Widget _buildComposer(BuildContext context, BCThemeExtension bc) {
    final attachments = widget.controller.attachments;

    final field = _shortcuts(
      BCInput(
        controller: widget.controller.text,
        focusNode: _focusNode,
        variant: BCInputVariant.primary,
        placeholder: widget.placeholder,
        isDisabled: widget.isDisabled,
        autofocus: widget.autofocus,
        // A finite maxLines, not null-plus-a-height-cap: a multiline BCInput
        // aligns its content, which makes it fill whatever height it is
        // offered, and a Column offers non-flex children an unbounded one.
        // Capping by lines keeps it content-sized until it starts scrolling.
        maxLines: widget.maxLines,
        minLines: 1,
        minHeight: 40,
        verticalPadding: 9,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        textCapitalization: TextCapitalization.sentences,
        contentInsertionConfiguration: widget.onContentInserted == null
            ? null
            : ContentInsertionConfiguration(
                onContentInserted: widget.onContentInserted!,
              ),
        prefix: widget.layout == BCChatComposerLayout.inline
            ? _inlineLeading()
            : null,
        suffix: widget.layout == BCChatComposerLayout.inline
            ? _inlineTrailing(bc)
            : null,
      ),
    );

    final children = <Widget>[
      if (attachments.isNotEmpty)
        BCChatAttachmentStrip(
          attachments: attachments,
          onRemove: _removeAttachment,
          chipBuilder: widget.attachmentBuilder,
          padding: const EdgeInsets.only(top: 4),
        ),
      field,
      if (widget.layout == BCChatComposerLayout.stacked) _actionRow(bc),
    ];

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: BCSpacing.sm,
      children: children,
    );

    // The `inline` layout leans on BCInput's own field decoration, so an
    // extra surface around it would double the border.
    if (widget.layout == BCChatComposerLayout.inline) {
      return Padding(padding: widget.padding ?? EdgeInsets.zero, child: body);
    }

    return Container(
      decoration: ShapeDecoration(
        color: widget.backgroundColor ?? bc.field,
        shape: BCShapes.continuous(
          widget.borderRadius ?? BCRadius.xxl,
          side: BorderSide(color: bc.fieldBorder),
        ),
      ),
      padding: widget.padding ?? const EdgeInsets.all(8),
      child: body,
    );
  }

  /// Wires Enter and its modifier variants, per [BCChatSubmitBehavior].
  Widget _shortcuts(Widget child) {
    final behavior = _submitBehavior;
    if (behavior == BCChatSubmitBehavior.buttonOnly) return child;

    final activator = behavior == BCChatSubmitBehavior.enter
        ? const SingleActivator(LogicalKeyboardKey.enter)
        : const SingleActivator(LogicalKeyboardKey.enter, meta: true);
    final alternate = behavior == BCChatSubmitBehavior.modifierEnter
        ? const SingleActivator(LogicalKeyboardKey.enter, control: true)
        : null;

    // Built imperatively rather than with a null-aware map entry: a `?key:`
    // element holding a const value crashes the CFE's constant evaluator
    // when compiling for a device.
    final shortcuts = <ShortcutActivator, Intent>{
      activator: const _SubmitIntent(),
    };
    if (alternate != null) shortcuts[alternate] = const _SubmitIntent();

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          _SubmitIntent: CallbackAction<_SubmitIntent>(
            onInvoke: (_) {
              _send();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }

  Widget? _inlineLeading() {
    final buttons = <Widget>[
      ...widget.leading,
      if (widget.onAttachPressed != null)
        _IconAction(
          icon: Icons.add_rounded,
          label: 'Attach files',
          onPressed: widget.isDisabled ? null : widget.onAttachPressed,
        ),
    ];
    if (buttons.isEmpty) return null;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
    );
  }

  Widget? _inlineTrailing(BCThemeExtension bc) {
    final buttons = <Widget>[
      ...widget.trailing,
      if (widget.onVoicePressed != null)
        _IconAction(
          icon: Icons.mic_none_rounded,
          label: 'Start voice mode',
          onPressed: widget.isDisabled ? null : widget.onVoicePressed,
        ),
      _sendButton(bc),
    ];
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Row(mainAxisSize: MainAxisSize.min, spacing: 2, children: buttons),
    );
  }

  Widget _actionRow(BCThemeExtension bc) {
    return Row(
      spacing: 2,
      children: [
        ...widget.leading,
        if (widget.onAttachPressed != null)
          _IconAction(
            icon: Icons.add_rounded,
            label: 'Attach files',
            onPressed: widget.isDisabled ? null : widget.onAttachPressed,
          ),
        const Spacer(),
        ...widget.trailing,
        if (widget.onVoicePressed != null)
          _IconAction(
            icon: Icons.mic_none_rounded,
            label: 'Start voice mode',
            onPressed: widget.isDisabled ? null : widget.onVoicePressed,
          ),
        _sendButton(bc),
      ],
    );
  }

  Widget _sendButton(BCThemeExtension bc) {
    final stopping = widget.isGenerating && widget.onStop != null;
    final enabled =
        !widget.isDisabled && (stopping || widget.controller.canSend);

    // Send and stop are the same 32px box, so the row never reflows when the
    // agent starts or finishes.
    return Semantics(
      button: true,
      label: stopping ? 'Stop generating' : 'Send message',
      child: BCPressable(
        onPressed: enabled ? (stopping ? widget.onStop : _send) : null,
        enabled: enabled,
        feedback: BCPressFeedback.scale,
        shape: const CircleBorder(),
        child: AnimatedContainer(
          duration: BCDuration.fast,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled ? bc.accent : bc.defaultColor,
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: BCDuration.fast,
            child: widget.isGenerating && widget.onStop == null
                ? const Center(
                    key: ValueKey('working'),
                    child: BCSpinner(size: BCSpinnerSize.sm),
                  )
                : Icon(
                    stopping ? Icons.stop_rounded : Icons.arrow_upward_rounded,
                    key: ValueKey(stopping ? 'stop' : 'send'),
                    size: 18,
                    color: enabled ? bc.accentForeground : bc.muted,
                  ),
          ),
        ),
      ),
    );
  }
}

class _SubmitIntent extends Intent {
  const _SubmitIntent();
}

/// A 32px round icon button sized to line up with the send button.
class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.label, this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    return Semantics(
      button: true,
      label: label,
      child: BCPressable(
        onPressed: onPressed,
        enabled: onPressed != null,
        feedback: BCPressFeedback.highlight,
        shape: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 19,
            color: onPressed == null ? bc.muted : bc.foreground,
          ),
        ),
      ),
    );
  }
}
