import 'package:bc_ui/bc_ui.dart';
import 'package:bc_ui/src/widgets/ai_chat/bc_chat_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: BCTheme.light(),
    home: Scaffold(
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    ),
  );
}

void main() {
  group('BCChatMarkdown inline grammar', () {
    test('bold, italic, code and strike are separate runs', () {
      expect(parseMarkdownInlineForTest('**b** *i* `c` ~~s~~'), [
        'text:b',
        'text: ',
        'text:i',
        'text: ',
        'code:c',
        'text: ',
        'text:s',
      ]);
    });

    test('a link keeps its text and href apart', () {
      expect(parseMarkdownInlineForTest('see [docs](https://x.dev) now'), [
        'text:see ',
        'link:docs->https://x.dev',
        'text: now',
      ]);
    });

    test('a bare url becomes its own link', () {
      expect(parseMarkdownInlineForTest('go https://x.dev/a?b=1 ok'), [
        'text:go ',
        'link:https://x.dev/a?b=1->https://x.dev/a?b=1',
        'text: ok',
      ]);
    });

    // Everything below is the mid-stream case: markdown that has only half
    // arrived must render as literal text, never swallow the rest of the
    // message into an emphasis run that closes later.
    test('an unclosed bold marker stays literal', () {
      expect(parseMarkdownInlineForTest('**half written'), [
        'text:**half written',
      ]);
    });

    test('an unclosed backtick stays literal', () {
      expect(parseMarkdownInlineForTest('a `unclosed'), ['text:a `unclosed']);
    });

    test('an unclosed italic marker stays literal', () {
      expect(parseMarkdownInlineForTest('*starting to'), ['text:*starting to']);
    });

    test('asterisks used as multiplication are not emphasis', () {
      expect(parseMarkdownInlineForTest('2 * 3 * 4'), ['text:2 * 3 * 4']);
    });

    test('underscores inside a word do not italicise it', () {
      expect(parseMarkdownInlineForTest('snake_case_word'), [
        'text:snake_case_word',
      ]);
    });

    test('markers inside inline code stay literal', () {
      expect(parseMarkdownInlineForTest('`a ** b`'), ['code:a ** b']);
    });
  });

  group('BCChatMarkdown block grammar', () {
    test('headings, paragraphs and lists split apart', () {
      expect(parseMarkdownBlocksForTest('# Title\n\nbody\n\n- a\n- b'), [
        'heading:Title',
        'paragraph:body',
        'list:',
      ]);
    });

    test('a fenced block keeps its body verbatim', () {
      expect(parseMarkdownBlocksForTest('```dart\nvoid main() {}\n```'), [
        'code:void main() {}',
      ]);
    });

    test('an unterminated fence still renders what arrived', () {
      expect(parseMarkdownBlocksForTest('```dart\nvoid main() {'), [
        'code:void main() {',
      ]);
    });

    test('a pipe table needs its divider row', () {
      expect(parseMarkdownBlocksForTest('| a | b |\n|---|---|\n| 1 | 2 |'), [
        'table:',
      ]);
      // Without the divider it is just a paragraph.
      expect(parseMarkdownBlocksForTest('| a | b |'), ['paragraph:| a | b |']);
    });

    test('consecutive quote lines join into one block', () {
      expect(parseMarkdownBlocksForTest('> one\n> two'), ['quote:one\ntwo']);
    });

    test('a horizontal rule is its own block', () {
      expect(parseMarkdownBlocksForTest('---'), ['rule:']);
    });

    test('empty source produces no blocks', () {
      expect(parseMarkdownBlocksForTest('   \n\n  '), isEmpty);
    });
  });

  group('BCChatMarkdown rendering', () {
    testWidgets('a fenced block renders a code block with its language', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const BCChatMarkdown(data: '```dart\nvoid main() {}\n```')),
      );

      expect(find.byType(BCChatCodeBlock), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
      expect(find.text('void main() {}'), findsOneWidget);
    });

    testWidgets('a code block copies to the clipboard', (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(
        _app(const BCChatCodeBlock(code: 'print(1);', language: 'dart')),
      );
      await tester.tap(find.text('Copy'));
      // Long enough for BCPressable's release animation to finish, short
      // enough that the "Copied" confirmation has not reverted yet.
      await tester.pump(const Duration(milliseconds: 300));

      expect(copied, ['print(1);']);
      expect(find.text('Copied'), findsOneWidget);
    });

    testWidgets('a link reports its href when tapped', (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        _app(
          BCChatMarkdown(
            data: 'read [the docs](https://x.dev)',
            onLinkTap: tapped.add,
          ),
        ),
      );

      await tester.tapOnText(find.textRange.ofSubstring('the docs'));
      await tester.pump();

      expect(tapped, ['https://x.dev']);
    });

    testWidgets('a table lays out inside a message bubble', (tester) async {
      // A table renders in a horizontal scroll view inside a shrink-wrapping
      // column, so its rows are offered unbounded height. Stretching them
      // used to fail that layout and take the whole thread down.
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 320,
            child: BCChatMarkdown(
              data: '| Prop | Default |\n|---|---|\n| `threshold` | 80 |',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Prop'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
    });

    testWidgets('empty markdown renders nothing at all', (tester) async {
      await tester.pumpWidget(_app(const BCChatMarkdown(data: '')));
      expect(find.byType(RichText), findsNothing);
    });
  });
}
