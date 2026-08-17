import 'package:flutter/widgets.dart';

import '../../tokens/bc_spacing.dart';
import '../bc_empty_state.dart';
import 'bc_chat_bubble.dart';
import 'bc_chat_composer.dart';
import 'bc_chat_controller.dart';
import 'bc_chat_models.dart';
import 'bc_chat_suggestions.dart';
import 'bc_chat_thread.dart';

/// A complete AI chat screen: the transcript, the composer, and the empty
/// state that greets a new conversation.
///
/// This component is bc_ui-specific — heroui-native has no equivalent.
///
/// It is a convenience over the primitives, not a black box. Every visual
/// slot has a builder that receives the widget it would otherwise have used,
/// so you can wrap or replace any of them and keep the rest; and if the
/// layout itself is wrong for you, drop to `BCChatThread` and
/// `BCChatComposer` directly and lay them out yourself.
///
/// Nothing here talks to a model. [onSend] hands you the text and the
/// attachments, and you drive the reply back in through the controller:
///
/// ```dart
/// BCAIChat(
///   controller: _chat,
///   composerController: _composer,
///   greeting: 'What can I help with?',
///   suggestions: const [
///     BCChatSuggestion(label: 'Summarise my inbox'),
///     BCChatSuggestion(label: 'Draft a reply'),
///   ],
///   onSend: (text, attachments) async {
///     _chat.add(BCChatMessage(
///       id: '${DateTime.now().microsecondsSinceEpoch}',
///       role: BCChatRole.user,
///       text: text,
///       attachments: attachments,
///     ));
///     _composer.reset();
///     await _streamReply(text);
///   },
/// );
/// ```
class BCAIChat extends StatefulWidget {
  const BCAIChat({
    super.key,
    required this.controller,
    required this.onSend,
    this.composerController,
    this.scrollController,
    this.composerFocusNode,
    this.variant = BCChatBubbleVariant.plain,
    this.greeting,
    this.greetingDescription,
    this.suggestions = const <BCChatSuggestion>[],
    this.onSuggestionSelected,
    this.onStop,
    this.onAttachPressed,
    this.onVoicePressed,
    this.onContentInserted,
    this.onLinkTap,
    this.onMessageLongPress,
    this.messageBuilder,
    this.contentBuilder,
    this.attachmentBuilder,
    this.stepBuilder,
    this.avatarBuilder,
    this.actionsBuilder,
    this.emptyBuilder,
    this.composerBuilder,
    this.header,
    this.footer,
    this.composerLayout = BCChatComposerLayout.inline,
    this.submitBehavior,
    this.placeholder = 'Ask anything',
    this.threadPadding,
    this.composerPadding,
    this.maxComposerLines = 6,
    this.maxWidthFactor,
    this.typingLabel,
    this.showScrollShadow = true,
    this.showJumpToBottom = true,
    this.showDateSeparators = true,
    this.isDisabled = false,
    this.reduceMotion,
  });

  /// The transcript's state.
  final BCChatController controller;

  /// Called when the user sends. The composer is not cleared for you — call
  /// [BCChatComposerController.reset] once you have taken the draft, so a
  /// failed send can leave it in place.
  final void Function(String text, List<BCChatAttachment> attachments) onSend;

  /// Owns the draft and staged attachments. One is created and disposed here
  /// when omitted, which is enough for a screen that never touches the draft
  /// itself.
  final BCChatComposerController? composerController;

  final ScrollController? scrollController;

  final FocusNode? composerFocusNode;

  /// How assistant messages are drawn.
  final BCChatBubbleVariant variant;

  /// Headline on the empty state. Without one, and without [suggestions], an
  /// empty thread renders nothing.
  final String? greeting;

  /// Second line under [greeting].
  final String? greetingDescription;

  /// Starter prompts on the empty state.
  final List<BCChatSuggestion> suggestions;

  /// Overrides the default, which sends the suggestion's text immediately.
  final ValueChanged<BCChatSuggestion>? onSuggestionSelected;

  /// Interrupts the agent. The send button becomes a stop button while
  /// [BCChatController.isGenerating] and this is set.
  final VoidCallback? onStop;

  /// Opens your file picker. The attach button only appears when set.
  final VoidCallback? onAttachPressed;

  /// Opens voice mode — typically `BCVoiceOverlay.show`. The mic button only
  /// appears when set.
  final VoidCallback? onVoicePressed;

  /// An image pasted into the composer. Android only; see
  /// [BCChatComposer.onContentInserted].
  final ValueChanged<KeyboardInsertedContent>? onContentInserted;

  final ValueChanged<String>? onLinkTap;

  final void Function(BCChatMessage)? onMessageLongPress;

  /// Wraps or replaces a whole message row.
  final Widget Function(BuildContext, BCChatMessage, Widget)? messageBuilder;

  /// Replaces the markdown body — the hook for a full CommonMark renderer.
  final Widget Function(BuildContext, BCChatMessage)? contentBuilder;

  /// Wraps or replaces each attachment chip.
  final Widget Function(BuildContext, BCChatAttachment, Widget)?
  attachmentBuilder;

  /// Wraps or replaces each agent-step tile.
  final Widget Function(BuildContext, BCAgentStep, Widget)? stepBuilder;

  /// The avatar beside a message. Return null for none — the default.
  final Widget? Function(BuildContext, BCChatMessage)? avatarBuilder;

  /// The actions offered under a message.
  final List<BCChatMessageAction> Function(BuildContext, BCChatMessage)?
  actionsBuilder;

  /// Replaces the whole empty state, [greeting] and [suggestions] included.
  final WidgetBuilder? emptyBuilder;

  /// Wraps or replaces the composer.
  final Widget Function(BuildContext, Widget)? composerBuilder;

  /// Pinned above the transcript, inside the scroll view.
  final Widget? header;

  /// Pinned below the transcript, inside the scroll view.
  final Widget? footer;

  final BCChatComposerLayout composerLayout;

  /// Overrides the per-platform Enter behaviour.
  final BCChatSubmitBehavior? submitBehavior;

  final String placeholder;

  /// Overrides the thread's default padding.
  final EdgeInsetsGeometry? threadPadding;

  /// Overrides the default `EdgeInsets.fromLTRB(12, 0, 12, 8)` around the
  /// composer.
  final EdgeInsetsGeometry? composerPadding;

  /// How many lines the composer grows to before it scrolls. Overrides the
  /// default 6.
  final int maxComposerLines;

  /// Forwarded to every bubble.
  final double? maxWidthFactor;

  /// Text beside the typing dots.
  final String? typingLabel;

  final bool showScrollShadow;

  final bool showJumpToBottom;

  final bool showDateSeparators;

  /// Blocks the composer — mid-send, or while the conversation is read-only.
  final bool isDisabled;

  /// Overrides `MediaQuery.disableAnimationsOf` for every animated part.
  final bool? reduceMotion;

  @override
  State<BCAIChat> createState() => _BCAIChatState();
}

class _BCAIChatState extends State<BCAIChat> {
  BCChatComposerController? _internalComposer;

  BCChatComposerController get _composer =>
      widget.composerController ??
      (_internalComposer ??= BCChatComposerController());

  @override
  void dispose() {
    _internalComposer?.dispose();
    super.dispose();
  }

  void _onSuggestion(BCChatSuggestion suggestion) {
    if (widget.onSuggestionSelected != null) {
      widget.onSuggestionSelected!(suggestion);
      return;
    }
    widget.onSend(suggestion.text, const <BCChatAttachment>[]);
  }

  @override
  Widget build(BuildContext context) {
    // The composer sits outside the thread's own listener, so it needs its
    // own subscription to see `isGenerating` flip.
    final composer = ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => BCChatComposer(
        controller: _composer,
        focusNode: widget.composerFocusNode,
        layout: widget.composerLayout,
        submitBehavior: widget.submitBehavior,
        placeholder: widget.placeholder,
        isGenerating: widget.controller.isGenerating,
        isDisabled: widget.isDisabled,
        onSend: widget.onSend,
        onStop: widget.onStop,
        onAttachPressed: widget.onAttachPressed,
        onVoicePressed: widget.onVoicePressed,
        onContentInserted: widget.onContentInserted,
        attachmentBuilder: widget.attachmentBuilder,
        maxLines: widget.maxComposerLines,
      ),
    );

    return Column(
      children: [
        Expanded(
          child: BCChatThread(
            controller: widget.controller,
            scrollController: widget.scrollController,
            variant: widget.variant,
            messageBuilder: widget.messageBuilder,
            contentBuilder: widget.contentBuilder,
            attachmentBuilder: widget.attachmentBuilder,
            stepBuilder: widget.stepBuilder,
            avatarBuilder: widget.avatarBuilder,
            actionsBuilder: widget.actionsBuilder,
            emptyBuilder: widget.emptyBuilder ?? _buildEmpty,
            header: widget.header,
            footer: widget.footer,
            onLinkTap: widget.onLinkTap,
            onMessageLongPress: widget.onMessageLongPress,
            padding: widget.threadPadding,
            showScrollShadow: widget.showScrollShadow,
            showJumpToBottom: widget.showJumpToBottom,
            showDateSeparators: widget.showDateSeparators,
            typingLabel: widget.typingLabel,
            maxWidthFactor: widget.maxWidthFactor,
            reduceMotion: widget.reduceMotion,
          ),
        ),
        Padding(
          padding:
              widget.composerPadding ??
              const EdgeInsets.fromLTRB(
                BCSpacing.sm + 4,
                0,
                BCSpacing.sm + 4,
                BCSpacing.sm,
              ),
          child: widget.composerBuilder?.call(context, composer) ?? composer,
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final hasGreeting = widget.greeting != null;
    if (!hasGreeting && widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(BCSpacing.lg),
        child: BCEmptyState(
          title: widget.greeting ?? '',
          description: widget.greetingDescription,
          actions: [
            if (widget.suggestions.isNotEmpty)
              BCChatSuggestions(
                suggestions: widget.suggestions,
                onSelected: _onSuggestion,
              ),
          ],
        ),
      ),
    );
  }
}
