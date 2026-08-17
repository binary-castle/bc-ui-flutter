import 'dart:async';

import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class AiChatShowcaseScreen extends StatelessWidget {
  const AiChatShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'AIChat',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => const _Frame(child: _LiveChatDemo()),
        ),
        UsageVariant(
          title: 'Streaming',
          builder: (context) => const _Frame(child: _StreamingDemo()),
        ),
        UsageVariant(
          title: 'Markdown',
          builder: (context) => const _Frame(child: _MarkdownDemo()),
        ),
        UsageVariant(
          title: 'Agent steps',
          builder: (context) => const _Frame(child: _AgentStepsDemo()),
        ),
        UsageVariant(
          title: 'Attachments',
          builder: (context) => const _Frame(child: _AttachmentsDemo()),
        ),
        UsageVariant(
          title: 'Voice mode',
          builder: (context) => const _Frame(child: _VoiceDemo()),
        ),
        UsageVariant(
          title: 'Custom skin',
          builder: (context) => const _Frame(child: _CustomSkinDemo()),
        ),
        UsageVariant(
          title: 'Empty state',
          builder: (context) => const _Frame(child: _EmptyStateDemo()),
        ),
      ],
    );
  }
}

/// A phone-sized window, since a chat UI needs bounded height and the
/// showcase page centres whatever it is given.
///
/// 360 rather than something roomier: the page centres its content and the
/// variant pagination overlays the bottom-left, so anything taller runs
/// underneath the variant labels.
class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: bc.background,
        shape: BCShapes.continuous(
          BCRadius.xxxl,
          side: BorderSide(color: bc.border),
        ),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// A canned agent, so the showcase behaves like the real thing offline.
// ---------------------------------------------------------------------------

/// Streams a scripted reply token by token.
///
/// Every timer it starts is held so [cancel] can stop them — the showcase
/// smoke test pumps each screen for 600ms and then tears it down, and a timer
/// that outlived the tree would fire into a disposed State.
class _FakeAgent {
  _FakeAgent(this.chat);

  final BCChatController chat;
  Timer? _timer;
  var _generation = 0;

  static const _replies = <String>[
    'Sure — the short version is that a **composer** owns the draft and the '
        'attachments, and the thread owns the transcript. They are separate '
        'controllers so either can be swapped out.',
    'Here is what I found:\n\n- The thread follows the bottom only while you '
        'are already there\n- Streaming appends to the same message\n- '
        '`appendChunk` is the only call you need in the loop',
    'Done. I edited `bc_input.dart` and re-ran the tests — all 64 pass.',
  ];

  void reply({List<BCAgentStep> steps = const []}) {
    final id = 'a${DateTime.now().microsecondsSinceEpoch}';
    final body = _replies[_generation++ % _replies.length];

    chat.add(
      BCChatMessage(
        id: id,
        role: BCChatRole.assistant,
        status: BCChatMessageStatus.streaming,
        steps: steps,
        createdAt: DateTime.now(),
      ),
    );
    chat.isGenerating = true;

    // Chunked by a few characters rather than by token — it looks the same
    // and keeps the script simple.
    var cursor = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 28), (timer) {
      if (cursor >= body.length) {
        timer.cancel();
        chat.finish(id);
        return;
      }
      final next = (cursor + 3).clamp(0, body.length);
      chat.appendChunk(id, body.substring(cursor, next));
      cursor = next;
    });
  }

  void stop() {
    _timer?.cancel();
    final last = chat.last;
    if (last != null && last.isStreaming) chat.finish(last.id);
    chat.isGenerating = false;
  }

  void cancel() => _timer?.cancel();
}

/// Sends a message and schedules the canned reply.
mixin _ChatDemoMixin<T extends StatefulWidget> on State<T> {
  final chat = BCChatController();
  final composer = BCChatComposerController();
  late final agent = _FakeAgent(chat);
  Timer? _pending;

  @override
  void dispose() {
    _pending?.cancel();
    agent.cancel();
    composer.dispose();
    chat.dispose();
    super.dispose();
  }

  void send(String text, List<BCChatAttachment> attachments) {
    if (text.isEmpty && attachments.isEmpty) return;
    chat.add(
      BCChatMessage(
        id: 'u${DateTime.now().microsecondsSinceEpoch}',
        role: BCChatRole.user,
        text: text,
        attachments: attachments,
        createdAt: DateTime.now(),
      ),
    );
    composer.reset();
    chat.isGenerating = true;

    _pending?.cancel();
    _pending = Timer(const Duration(milliseconds: 400), agent.reply);
  }
}

// ---------------------------------------------------------------------------
// Variants
// ---------------------------------------------------------------------------

class _LiveChatDemo extends StatefulWidget {
  const _LiveChatDemo();

  @override
  State<_LiveChatDemo> createState() => _LiveChatDemoState();
}

class _LiveChatDemoState extends State<_LiveChatDemo>
    with _ChatDemoMixin<_LiveChatDemo> {
  @override
  Widget build(BuildContext context) {
    return BCAIChat(
      controller: chat,
      composerController: composer,
      greeting: 'What can I help with?',
      greetingDescription: 'Ask a question, or pick one of these to start.',
      suggestions: const [
        BCChatSuggestion(label: 'Explain the architecture'),
        BCChatSuggestion(label: 'Find the bug'),
        BCChatSuggestion(label: 'Write tests'),
      ],
      onSend: send,
      onStop: agent.stop,
      onAttachPressed: () {},
      onVoicePressed: () {},
      actionsBuilder: (context, message) => message.role == BCChatRole.assistant
          ? [
              BCChatMessageAction(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onPressed: () {},
              ),
              BCChatMessageAction(
                icon: Icons.refresh_rounded,
                label: 'Regenerate',
                onPressed: () {},
              ),
            ]
          : const [],
    );
  }
}

class _StreamingDemo extends StatefulWidget {
  const _StreamingDemo();

  @override
  State<_StreamingDemo> createState() => _StreamingDemoState();
}

class _StreamingDemoState extends State<_StreamingDemo>
    with _ChatDemoMixin<_StreamingDemo> {
  @override
  void initState() {
    super.initState();
    chat.addAll([
      const BCChatMessage(
        id: 'u1',
        role: BCChatRole.user,
        text: 'How does the thread decide when to auto-scroll?',
      ),
    ]);
    agent.reply();
  }

  @override
  Widget build(BuildContext context) {
    return BCAIChat(
      controller: chat,
      composerController: composer,
      typingLabel: 'Thinking',
      onSend: send,
      onStop: agent.stop,
    );
  }
}

class _MarkdownDemo extends StatelessWidget {
  const _MarkdownDemo();

  static const _answer = '''
## Auto-scroll

The thread follows the bottom **only** while you are already near it.

1. Read `position.maxScrollExtent`
2. Compare against `autoScrollThreshold`
3. Follow, or show the pill

```dart
final atBottom =
    position.maxScrollExtent - position.pixels <= threshold;
```

| Prop | Default |
|---|---|
| `autoScrollThreshold` | 80 |
| `messageSpacing` | 16 |

> Scrolling up always wins — a streaming reply never yanks the view.

See the [docs](https://pub.dev/packages/bc_ui) for the rest.
''';

  @override
  Widget build(BuildContext context) {
    return BCChatThread(
      messages: const [
        BCChatMessage(
          id: 'u1',
          role: BCChatRole.user,
          text: 'Explain the scroll behaviour.',
        ),
        BCChatMessage(id: 'a1', role: BCChatRole.assistant, text: _answer),
      ],
      onLinkTap: (href) =>
          BCToast.show(context, BCToastData(title: 'Would open $href')),
    );
  }
}

class _AgentStepsDemo extends StatelessWidget {
  const _AgentStepsDemo();

  @override
  Widget build(BuildContext context) {
    return BCChatThread(
      messages: [
        const BCChatMessage(
          id: 'u1',
          role: BCChatRole.user,
          text: 'Find why the modal hides behind the keyboard and fix it.',
        ),
        BCChatMessage(
          id: 'a1',
          role: BCChatRole.assistant,
          text:
              'Fixed. The dialog now lays out in the band above the '
              'keyboard, and tall content scrolls inside it.',
          steps: const [
            BCAgentStep(
              id: 's1',
              label: 'Searched the repo',
              detail: 'viewInsets in lib/src/widgets',
              status: BCAgentStepStatus.success,
              duration: Duration(milliseconds: 820),
              output: 'bc_dialog.dart:214\nbc_select.dart:98',
            ),
            BCAgentStep(
              id: 's2',
              label: 'Read bc_dialog.dart',
              status: BCAgentStepStatus.success,
              duration: Duration(milliseconds: 340),
            ),
            BCAgentStep(
              id: 's3',
              label: 'Edited bc_dialog.dart',
              detail: '+62 −8',
              status: BCAgentStepStatus.success,
              duration: Duration(seconds: 2, milliseconds: 100),
              children: [
                BCAgentStep(
                  id: 's3a',
                  label: 'Reflowed the content band',
                  status: BCAgentStepStatus.success,
                ),
                BCAgentStep(
                  id: 's3b',
                  label: 'Kept the swipe gesture',
                  status: BCAgentStepStatus.success,
                ),
              ],
            ),
            BCAgentStep(
              id: 's4',
              label: 'Running the test suite',
              status: BCAgentStepStatus.running,
            ),
          ],
        ),
      ],
    );
  }
}

class _AttachmentsDemo extends StatefulWidget {
  const _AttachmentsDemo();

  @override
  State<_AttachmentsDemo> createState() => _AttachmentsDemoState();
}

class _AttachmentsDemoState extends State<_AttachmentsDemo> {
  final _composer = BCChatComposerController(initialText: 'What is in these?');

  @override
  void initState() {
    super.initState();
    _composer.addAttachments(const [
      BCChatAttachment(
        id: 'f1',
        name: 'q3-report.pdf',
        kind: BCChatAttachmentKind.document,
        sizeBytes: 2411724,
      ),
      BCChatAttachment(
        id: 'f2',
        name: 'main.dart',
        kind: BCChatAttachmentKind.code,
        sizeBytes: 8214,
        status: BCChatAttachmentStatus.uploading,
        progress: 0.62,
      ),
      BCChatAttachment(
        id: 'f3',
        name: 'screenshot.png',
        kind: BCChatAttachmentKind.image,
        sizeBytes: 184320,
        status: BCChatAttachmentStatus.failed,
        error: 'Too large',
      ),
    ]);
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'You pick the files and drive the upload — bc_ui only draws '
                'the chips. Progress, failure and removal are all states you '
                'set on BCChatAttachment.',
                textAlign: TextAlign.center,
                style: BCTypography.textSm.copyWith(color: bc.muted),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: BCChatComposer(
            controller: _composer,
            layout: BCChatComposerLayout.stacked,
            onSend: (_, _) {},
            onAttachPressed: () {},
            onVoicePressed: () {},
          ),
        ),
      ],
    );
  }
}

class _VoiceDemo extends StatefulWidget {
  const _VoiceDemo();

  @override
  State<_VoiceDemo> createState() => _VoiceDemoState();
}

class _VoiceDemoState extends State<_VoiceDemo> {
  final _voice = BCVoiceController(state: BCVoiceState.listening);
  Timer? _ticker;
  var _tick = 0;

  @override
  void initState() {
    super.initState();
    // Stands in for a real amplitude stream. Cancelled in dispose so the
    // showcase smoke test does not trip over a pending timer.
    _ticker = Timer.periodic(const Duration(milliseconds: 60), (_) {
      _tick++;
      _voice
        ..amplitude = (0.25 + 0.7 * _pseudoLevel(_tick)).clamp(0.0, 1.0)
        ..transcript = _tick > 30
            ? 'What does bc_ui use for the voice orb?'
            : 'What does bc_ui use';
      if (_tick % 120 == 0) {
        _voice.state = switch (_voice.state) {
          BCVoiceState.listening => BCVoiceState.thinking,
          BCVoiceState.thinking => BCVoiceState.speaking,
          _ => BCVoiceState.listening,
        };
      }
    });
  }

  /// A cheap repeatable wobble — Random is avoided so the frame is stable
  /// under a test that pumps a fixed number of milliseconds.
  double _pseudoLevel(int tick) {
    final a = (tick * 7 % 13) / 13;
    final b = (tick * 3 % 5) / 5;
    return (a + b) / 2;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    return Column(
      children: [
        // Just the orb and the meter as a preview — the full session is a
        // route, which the button below opens the way an app would.
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: BCSpacing.md,
              children: [
                BCVoiceOrb(controller: _voice, size: 130),
                BCVoiceWaveform(controller: _voice),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(BCSpacing.md),
          child: Column(
            spacing: BCSpacing.sm,
            children: [
              BCButton(
                fullWidth: true,
                startContent: const Icon(Icons.mic_none_rounded, size: 18),
                onPressed: () => BCVoiceOverlay.show(
                  context,
                  controller: _voice,
                  title: 'bc_ui assistant',
                  onKeyboard: () {},
                ),
                child: const Text('Open full-screen voice mode'),
              ),
              Text(
                'bc_ui opens no microphone — you push state, amplitude and '
                'transcript into BCVoiceController yourself.',
                textAlign: TextAlign.center,
                style: BCTypography.textXs.copyWith(color: bc.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomSkinDemo extends StatelessWidget {
  const _CustomSkinDemo();

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    return BCChatThread(
      variant: BCChatBubbleVariant.surface,
      messageSpacing: 20,
      messages: const [
        BCChatMessage(
          id: 'u1',
          role: BCChatRole.user,
          text: 'Can I reskin all of this?',
        ),
        BCChatMessage(
          id: 'a1',
          role: BCChatRole.assistant,
          text:
              'Every slot takes a builder that receives the default widget, '
              'so you wrap rather than rewrite.',
        ),
      ],
      // Avatars, a filled assistant bubble, and a name above each message —
      // all through builders, with the same models underneath.
      avatarBuilder: (context, message) => message.role == BCChatRole.assistant
          ? BCAvatar.withInitials('AI', size: BCAvatarSize.small)
          : BCAvatar.withInitials(
              'You',
              size: BCAvatarSize.small,
              color: BCAvatarColor.success,
            ),
      messageBuilder: (context, message, child) => Column(
        crossAxisAlignment: message.role == BCChatRole.user
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 44, bottom: 4),
            child: Text(
              message.role == BCChatRole.user ? 'You' : 'Assistant',
              style: BCTypography.textXs.copyWith(color: bc.muted),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _EmptyStateDemo extends StatefulWidget {
  const _EmptyStateDemo();

  @override
  State<_EmptyStateDemo> createState() => _EmptyStateDemoState();
}

class _EmptyStateDemoState extends State<_EmptyStateDemo>
    with _ChatDemoMixin<_EmptyStateDemo> {
  @override
  Widget build(BuildContext context) {
    return BCAIChat(
      controller: chat,
      composerController: composer,
      greeting: 'Good evening',
      greetingDescription: 'What would you like to work on?',
      placeholder: 'Message the assistant',
      suggestions: const [
        BCChatSuggestion(label: 'Summarise my inbox'),
        BCChatSuggestion(label: 'Plan the sprint'),
        BCChatSuggestion(label: 'Review this PR'),
        BCChatSuggestion(label: 'Draft a changelog'),
      ],
      onSend: send,
      onStop: agent.stop,
      onAttachPressed: () {},
      onVoicePressed: () {},
    );
  }
}
