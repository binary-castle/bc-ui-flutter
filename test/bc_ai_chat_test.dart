import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {double width = 420, double height = 600}) {
  return MaterialApp(
    theme: BCTheme.light(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, height: height, child: child),
      ),
    ),
  );
}

BCChatMessage _user(String text, {String id = 'u1'}) =>
    BCChatMessage(id: id, role: BCChatRole.user, text: text);

BCChatMessage _assistant(
  String text, {
  String id = 'a1',
  BCChatMessageStatus status = BCChatMessageStatus.complete,
}) => BCChatMessage(
  id: id,
  role: BCChatRole.assistant,
  text: text,
  status: status,
);

void main() {
  group('BCChatController', () {
    test('appendChunk grows the message and marks it streaming', () {
      final controller = BCChatController(
        messages: [_assistant('', status: BCChatMessageStatus.pending)],
      );
      addTearDown(controller.dispose);

      controller.appendChunk('a1', 'Hel');
      controller.appendChunk('a1', 'lo');

      expect(controller.byId('a1')!.text, 'Hello');
      expect(controller.byId('a1')!.status, BCChatMessageStatus.streaming);
      expect(controller.isGenerating, isTrue);
    });

    test('appendChunk ignores an unknown id and an empty chunk', () {
      final controller = BCChatController(messages: [_assistant('hi')]);
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.appendChunk('nope', 'x');
      controller.appendChunk('a1', '');

      expect(notifications, 0);
      expect(controller.byId('a1')!.text, 'hi');
    });

    test('finish completes the message and stops generating', () {
      final controller = BCChatController(messages: [_assistant('')]);
      addTearDown(controller.dispose);

      controller.appendChunk('a1', 'done');
      controller.finish('a1');

      expect(controller.byId('a1')!.status, BCChatMessageStatus.complete);
      expect(controller.isGenerating, isFalse);
    });

    test('fail records the error and stops generating', () {
      final controller = BCChatController(messages: [_assistant('')]);
      addTearDown(controller.dispose);

      controller.appendChunk('a1', 'partial');
      controller.fail('a1', 'Network is down');

      expect(controller.byId('a1')!.status, BCChatMessageStatus.failed);
      expect(controller.byId('a1')!.error, 'Network is down');
      expect(controller.isGenerating, isFalse);
    });

    test('update does not notify when nothing actually changed', () {
      final controller = BCChatController(messages: [_assistant('hi')]);
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.update('a1', (message) => message);
      expect(notifications, 0);

      controller.update('a1', (message) => message.copyWith(text: 'bye'));
      expect(notifications, 1);
    });

    test('remove drops only the matching message', () {
      final controller = BCChatController(
        messages: [_user('one'), _assistant('two')],
      );
      addTearDown(controller.dispose);

      controller.remove('u1');

      expect(controller.messages.map((m) => m.id), ['a1']);
    });

    test('the messages view cannot be mutated in place', () {
      final controller = BCChatController(messages: [_user('one')]);
      addTearDown(controller.dispose);

      expect(
        () => controller.messages.add(_user('two')),
        throwsUnsupportedError,
      );
    });
  });

  group('BCChatComposerController', () {
    test('whitespace alone is not sendable', () {
      final controller = BCChatComposerController(initialText: '   ');
      addTearDown(controller.dispose);

      expect(controller.canSend, isFalse);

      controller.text.text = 'hi';
      expect(controller.canSend, isTrue);
    });

    test('an upload in flight is not sendable until it lands', () {
      final controller = BCChatComposerController();
      addTearDown(controller.dispose);

      controller.addAttachments([
        const BCChatAttachment(
          id: 'f1',
          name: 'a.png',
          status: BCChatAttachmentStatus.uploading,
          progress: 0.3,
        ),
      ]);
      expect(controller.canSend, isFalse);
      expect(controller.isUploading, isTrue);

      controller.updateAttachment(
        'f1',
        (a) => a.copyWith(status: BCChatAttachmentStatus.ready),
      );
      expect(controller.canSend, isTrue);
    });

    test('reset clears both the draft and the attachments', () {
      final controller = BCChatComposerController(initialText: 'draft');
      addTearDown(controller.dispose);
      controller.addAttachments([
        const BCChatAttachment(id: 'f1', name: 'a.png'),
      ]);

      controller.reset();

      expect(controller.text.text, isEmpty);
      expect(controller.attachments, isEmpty);
    });

    test('reset still notifies when only attachments were staged', () {
      final controller = BCChatComposerController();
      addTearDown(controller.dispose);
      controller.addAttachments([
        const BCChatAttachment(id: 'f1', name: 'a.png'),
      ]);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.reset();

      expect(notifications, 1);
      expect(controller.attachments, isEmpty);
    });
  });

  group('BCChatBubble', () {
    testWidgets('a user message sits opposite an assistant one', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              BCChatBubble(role: BCChatRole.user, child: Text('mine')),
              BCChatBubble(
                role: BCChatRole.assistant,
                variant: BCChatBubbleVariant.surface,
                child: Text('theirs'),
              ),
            ],
          ),
        ),
      );

      final mine = tester.getCenter(find.text('mine'));
      final theirs = tester.getCenter(find.text('theirs'));
      final middle = tester.getCenter(find.byType(Column)).dx;

      expect(mine.dx, greaterThan(middle));
      expect(theirs.dx, lessThan(middle));
    });

    testWidgets('a filled bubble is capped short of the full width', (
      tester,
    ) async {
      const long = 'a very long message that would otherwise fill it all';
      await tester.pumpWidget(
        _app(const BCChatBubble(role: BCChatRole.user, child: Text(long))),
      );

      // The bubble widget itself is full-width — it is an Align — so measure
      // the content, which the 0.78 cap plus 14pt of padding bounds.
      final width = tester.getSize(find.text(long)).width;
      expect(width, lessThan(420 * 0.78));
    });
  });

  group('BCChatMessageView', () {
    testWidgets('a streaming message with no text shows the typing dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          BCChatMessageView(
            message: _assistant('', status: BCChatMessageStatus.streaming),
          ),
        ),
      );

      expect(find.byType(BCChatTypingIndicator), findsOneWidget);
    });

    testWidgets('a message with text shows no typing dots', (tester) async {
      await tester.pumpWidget(
        _app(
          BCChatMessageView(
            message: _assistant(
              'here you go',
              status: BCChatMessageStatus.streaming,
            ),
          ),
        ),
      );

      expect(find.byType(BCChatTypingIndicator), findsNothing);
      expect(find.text('here you go'), findsOneWidget);
    });

    testWidgets('a failed message shows its error instead of a body', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          BCChatMessageView(
            message: const BCChatMessage(
              id: 'a1',
              role: BCChatRole.assistant,
              text: 'half an answer',
              status: BCChatMessageStatus.failed,
              error: 'Rate limited',
            ),
          ),
        ),
      );

      expect(find.text('Rate limited'), findsOneWidget);
      expect(find.text('half an answer'), findsNothing);
    });

    testWidgets('a system message is centred and unbubbled', (tester) async {
      await tester.pumpWidget(
        _app(
          BCChatMessageView(
            message: const BCChatMessage(
              id: 's1',
              role: BCChatRole.system,
              text: 'Switched model',
            ),
          ),
        ),
      );

      expect(find.byType(BCChatBubble), findsNothing);
      expect(find.text('Switched model'), findsOneWidget);
    });

    testWidgets('attachments render alongside the body', (tester) async {
      await tester.pumpWidget(
        _app(
          BCChatMessageView(
            message: const BCChatMessage(
              id: 'u1',
              role: BCChatRole.user,
              text: 'have a look',
              attachments: [
                BCChatAttachment(
                  id: 'f1',
                  name: 'report.pdf',
                  kind: BCChatAttachmentKind.document,
                  sizeBytes: 2048,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
      expect(find.text('have a look'), findsOneWidget);
    });

    testWidgets('actions are hidden while the message streams', (tester) async {
      Widget build(BCChatMessageStatus status) => _app(
        BCChatMessageView(
          message: _assistant('answer', status: status),
          actions: [
            BCChatMessageAction(
              icon: Icons.copy_rounded,
              label: 'Copy',
              onPressed: () {},
            ),
          ],
        ),
      );

      await tester.pumpWidget(build(BCChatMessageStatus.streaming));
      expect(find.byType(BCChatMessageActions), findsNothing);

      await tester.pumpWidget(build(BCChatMessageStatus.complete));
      expect(find.byType(BCChatMessageActions), findsOneWidget);
    });
  });

  group('BCChatComposer', () {
    testWidgets('send stays disabled until there is something to send', (
      tester,
    ) async {
      final controller = BCChatComposerController();
      addTearDown(controller.dispose);
      var sends = 0;

      await tester.pumpWidget(
        _app(
          BCChatComposer(controller: controller, onSend: (_, _) => sends++),
          height: 120,
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 300));
      expect(sends, 0);

      await tester.enterText(find.byType(EditableText), 'hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 300));
      expect(sends, 1);
    });

    testWidgets('sending hands over the trimmed draft', (tester) async {
      final controller = BCChatComposerController();
      addTearDown(controller.dispose);
      String? sent;

      await tester.pumpWidget(
        _app(
          BCChatComposer(
            controller: controller,
            onSend: (text, _) => sent = text,
          ),
          height: 120,
        ),
      );

      await tester.enterText(find.byType(EditableText), '  spaced  ');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      expect(sent, 'spaced');
      // The composer deliberately does not clear itself, so a failed send can
      // leave the draft in place.
      expect(controller.text.text, '  spaced  ');
    });

    testWidgets('send becomes stop while the agent is working', (tester) async {
      final controller = BCChatComposerController(initialText: 'hi');
      addTearDown(controller.dispose);
      var stops = 0;

      await tester.pumpWidget(
        _app(
          BCChatComposer(
            controller: controller,
            isGenerating: true,
            onSend: (_, _) {},
            onStop: () => stops++,
          ),
          height: 120,
        ),
      );

      expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      expect(stops, 1);
    });

    testWidgets('Enter sends under BCChatSubmitBehavior.enter', (tester) async {
      final controller = BCChatComposerController(initialText: 'hi');
      addTearDown(controller.dispose);
      var sends = 0;

      await tester.pumpWidget(
        _app(
          BCChatComposer(
            controller: controller,
            submitBehavior: BCChatSubmitBehavior.enter,
            autofocus: true,
            onSend: (_, _) => sends++,
          ),
          height: 120,
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(sends, 1);
    });

    testWidgets('Enter does not send under buttonOnly', (tester) async {
      final controller = BCChatComposerController(initialText: 'hi');
      addTearDown(controller.dispose);
      var sends = 0;

      await tester.pumpWidget(
        _app(
          BCChatComposer(
            controller: controller,
            submitBehavior: BCChatSubmitBehavior.buttonOnly,
            autofocus: true,
            onSend: (_, _) => sends++,
          ),
          height: 120,
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(sends, 0);
    });

    testWidgets('the attach and mic buttons only appear when wired', (
      tester,
    ) async {
      final controller = BCChatComposerController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(
          BCChatComposer(controller: controller, onSend: (_, _) {}),
          height: 120,
        ),
      );
      expect(find.byIcon(Icons.add_rounded), findsNothing);
      expect(find.byIcon(Icons.mic_none_rounded), findsNothing);

      await tester.pumpWidget(
        _app(
          BCChatComposer(
            controller: controller,
            onSend: (_, _) {},
            onAttachPressed: () {},
            onVoicePressed: () {},
          ),
          height: 120,
        ),
      );
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    });

    testWidgets('an uploading chip lays out inside the scrolling strip', (
      tester,
    ) async {
      // The strip scrolls horizontally, so a chip is offered unbounded width.
      // The upload progress bar used to be a fraction of that, which cannot
      // resolve and took the whole composer down with it.
      final controller = BCChatComposerController();
      addTearDown(controller.dispose);
      controller.addAttachments(const [
        BCChatAttachment(
          id: 'f1',
          name: 'q3-report.pdf',
          kind: BCChatAttachmentKind.document,
          sizeBytes: 2411724,
          status: BCChatAttachmentStatus.uploading,
          progress: 0.62,
        ),
      ]);

      await tester.pumpWidget(
        _app(
          BCChatComposer(
            controller: controller,
            layout: BCChatComposerLayout.stacked,
            onSend: (_, _) {},
          ),
          height: 240,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('q3-report.pdf'), findsOneWidget);
      expect(find.text('Uploading 62%'), findsOneWidget);
    });

    testWidgets('removing a staged chip drops it from the controller', (
      tester,
    ) async {
      final controller = BCChatComposerController();
      addTearDown(controller.dispose);
      controller.addAttachments([
        const BCChatAttachment(id: 'f1', name: 'a.png'),
        const BCChatAttachment(id: 'f2', name: 'b.png'),
      ]);

      await tester.pumpWidget(
        _app(
          BCChatComposer(controller: controller, onSend: (_, _) {}),
          height: 200,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Remove a.png'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.attachments.map((a) => a.id), ['f2']);
    });
  });

  group('BCAgentStepList', () {
    const finished = [
      BCAgentStep(
        id: 's1',
        label: 'Searched the web',
        status: BCAgentStepStatus.success,
        duration: Duration(seconds: 2),
        children: [BCAgentStep(id: 's1a', label: 'Opened result 1')],
      ),
    ];

    testWidgets('finished work collapses to a summary that counts nesting', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const BCAgentStepList(steps: finished)));

      expect(find.text('Worked for 2.0s · 2 steps'), findsOneWidget);
      expect(find.text('Searched the web'), findsNothing);
    });

    testWidgets('tapping the summary reveals the steps', (tester) async {
      await tester.pumpWidget(_app(const BCAgentStepList(steps: finished)));

      await tester.tap(find.text('Worked for 2.0s · 2 steps'));
      await tester.pumpAndSettle();

      expect(find.text('Searched the web'), findsOneWidget);
    });

    testWidgets('work still running opens itself and shows a spinner', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const BCAgentStepList(
            steps: [
              BCAgentStep(
                id: 's1',
                label: 'Reading the repo',
                status: BCAgentStepStatus.running,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Reading the repo'), findsOneWidget);
      expect(find.byType(BCSpinner), findsWidgets);
    });

    testWidgets('an empty step list renders nothing', (tester) async {
      await tester.pumpWidget(_app(const BCAgentStepList(steps: [])));
      expect(find.byType(BCPressable), findsNothing);
    });
  });

  group('BCChatThread', () {
    testWidgets('renders one row per message', (tester) async {
      final controller = BCChatController(
        messages: [_user('one'), _assistant('two')],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(BCChatThread(controller: controller)));

      expect(find.byType(BCChatMessageView), findsNWidgets(2));
      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
    });

    testWidgets('an empty thread falls back to the empty builder', (
      tester,
    ) async {
      final controller = BCChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(
          BCChatThread(
            controller: controller,
            emptyBuilder: (_) => const Text('nothing yet'),
          ),
        ),
      );

      expect(find.text('nothing yet'), findsOneWidget);
    });

    testWidgets('a message added to the controller appears', (tester) async {
      final controller = BCChatController(messages: [_user('one')]);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(BCChatThread(controller: controller)));
      expect(find.text('two'), findsNothing);

      controller.add(_assistant('two'));
      await tester.pump();

      expect(find.text('two'), findsOneWidget);
    });

    testWidgets('the jump-to-bottom pill is hidden while at the bottom', (
      tester,
    ) async {
      final controller = BCChatController(
        messages: [for (var i = 0; i < 3; i++) _user('m$i', id: 'm$i')],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(BCChatThread(controller: controller)));

      final pill = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text('Latest'),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(pill.opacity, 0);
    });
  });

  group('BCChatSuggestions', () {
    testWidgets('tapping a suggestion reports it with its prompt', (
      tester,
    ) async {
      BCChatSuggestion? picked;

      await tester.pumpWidget(
        _app(
          BCChatSuggestions(
            suggestions: const [
              BCChatSuggestion(
                label: 'Plan a sprint',
                prompt: 'Plan my sprint',
              ),
            ],
            onSelected: (s) => picked = s,
          ),
        ),
      );

      await tester.tap(find.text('Plan a sprint'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(picked?.text, 'Plan my sprint');
    });
  });

  group('BCVoiceController', () {
    test('amplitude clamps into 0..1', () {
      final controller = BCVoiceController();
      addTearDown(controller.dispose);

      controller.amplitude = 4.2;
      expect(controller.amplitude, 1);

      controller.amplitude = -3;
      expect(controller.amplitude, 0);
    });

    test('fail moves to the error state and keeps the message', () {
      final controller = BCVoiceController();
      addTearDown(controller.dispose);

      controller.fail('No microphone');

      expect(controller.state, BCVoiceState.error);
      expect(controller.errorMessage, 'No microphone');
    });

    test('leaving the error state clears its message', () {
      final controller = BCVoiceController();
      addTearDown(controller.dispose);
      controller.fail('No microphone');

      controller.state = BCVoiceState.listening;

      expect(controller.errorMessage, isNull);
    });

    test('reset returns everything to rest', () {
      final controller = BCVoiceController(
        state: BCVoiceState.speaking,
        transcript: 'hello',
        isMuted: true,
      );
      addTearDown(controller.dispose);

      controller.reset();

      expect(controller.state, BCVoiceState.idle);
      expect(controller.transcript, isEmpty);
      expect(controller.isMuted, isFalse);
    });
  });

  group('BCVoiceOverlay', () {
    testWidgets('the state label follows the controller', (tester) async {
      final controller = BCVoiceController(state: BCVoiceState.listening);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(BCVoiceOverlay(controller: controller)));
      expect(find.text('Listening'), findsOneWidget);

      controller.state = BCVoiceState.thinking;
      await tester.pump();
      expect(find.text('Thinking'), findsOneWidget);
    });

    testWidgets('an error shows its message in place of the state', (
      tester,
    ) async {
      final controller = BCVoiceController();
      addTearDown(controller.dispose);
      controller.fail('Microphone unavailable');

      await tester.pumpWidget(_app(BCVoiceOverlay(controller: controller)));

      expect(find.text('Microphone unavailable'), findsOneWidget);
    });

    testWidgets('the mute button toggles the controller', (tester) async {
      final controller = BCVoiceController(state: BCVoiceState.listening);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(BCVoiceOverlay(controller: controller)));

      await tester.tap(find.bySemanticsLabel('Mute'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.isMuted, isTrue);
      expect(find.bySemanticsLabel('Unmute'), findsOneWidget);
    });

    testWidgets('the live transcript is shown when there is one', (
      tester,
    ) async {
      final controller = BCVoiceController(
        state: BCVoiceState.listening,
        transcript: 'what is the weather',
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(BCVoiceOverlay(controller: controller)));

      expect(find.text('what is the weather'), findsOneWidget);
    });
  });

  group('BCAIChat', () {
    testWidgets('the greeting and suggestions show on an empty thread', (
      tester,
    ) async {
      final controller = BCChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(
          BCAIChat(
            controller: controller,
            greeting: 'What can I help with?',
            suggestions: const [BCChatSuggestion(label: 'Plan a sprint')],
            onSend: (_, _) {},
          ),
        ),
      );

      expect(find.text('What can I help with?'), findsOneWidget);
      expect(find.text('Plan a sprint'), findsOneWidget);
    });

    testWidgets('a suggestion sends its prompt straight away', (tester) async {
      final controller = BCChatController();
      addTearDown(controller.dispose);
      String? sent;

      await tester.pumpWidget(
        _app(
          BCAIChat(
            controller: controller,
            greeting: 'Hi',
            suggestions: const [BCChatSuggestion(label: 'Plan a sprint')],
            onSend: (text, _) => sent = text,
          ),
        ),
      );

      await tester.tap(find.text('Plan a sprint'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(sent, 'Plan a sprint');
    });

    testWidgets('the composer follows the controller into generating', (
      tester,
    ) async {
      final controller = BCChatController(messages: [_user('hi')]);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(
          BCAIChat(controller: controller, onSend: (_, _) {}, onStop: () {}),
        ),
      );
      expect(find.byIcon(Icons.stop_rounded), findsNothing);

      controller.isGenerating = true;
      await tester.pump();

      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    });
  });
}
