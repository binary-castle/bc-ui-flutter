import 'dart:async';

import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart' show Icons, SelectionArea;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../theme/component_themes/ai_chat_theme.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/bc_radius.dart';
import '../../tokens/bc_shapes.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';
import '../bc_pressable.dart';

/// A fenced code block with a language label and a copy button.
///
/// Long lines scroll horizontally rather than wrapping, because wrapped code
/// is unreadable. No syntax highlighting: [language] is displayed, not
/// tokenized.
class BCChatCodeBlock extends StatefulWidget {
  const BCChatCodeBlock({
    super.key,
    required this.code,
    this.language,
    this.showCopyButton = true,
    this.onCopy,
    this.backgroundColor,
    this.textStyle,
    this.padding,
  });

  final String code;

  /// The info string after the opening fence, shown in the header.
  final String? language;

  final bool showCopyButton;

  /// Called after the code reaches the clipboard — raise your own toast here.
  final VoidCallback? onCopy;

  /// Overrides the default `bc.surfaceSecondary` fill.
  final Color? backgroundColor;

  /// Overrides the default monospace style.
  final TextStyle? textStyle;

  /// Overrides the default `EdgeInsets.all(12)` around the code itself.
  final EdgeInsetsGeometry? padding;

  @override
  State<BCChatCodeBlock> createState() => _BCChatCodeBlockState();
}

class _BCChatCodeBlockState extends State<BCChatCodeBlock> {
  Timer? _resetLabel;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    widget.onCopy?.call();
    if (!mounted) return;
    setState(() => _copied = true);
    // A held Timer rather than a delayed Future, so leaving the screen
    // mid-confirmation cancels it instead of firing into a dead State.
    _resetLabel?.cancel();
    _resetLabel = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _resetLabel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final foreground = BCAIChatTheme.codeBlockForeground(bc);
    final hasHeader =
        (widget.language != null && widget.language!.isNotEmpty) ||
        widget.showCopyButton;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: widget.backgroundColor ?? BCAIChatTheme.codeBlockBackground(bc),
        shape: BCShapes.continuous(BCRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 6, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.language ?? '',
                      style: BCTypography.textXs.copyWith(color: bc.muted),
                    ),
                  ),
                  if (widget.showCopyButton)
                    BCPressable(
                      onPressed: _copy,
                      feedback: BCPressFeedback.highlight,
                      shape: BCShapes.continuous(BCRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            Icon(
                              _copied ? Icons.check : Icons.copy_rounded,
                              size: 13,
                              color: bc.muted,
                            ),
                            Text(
                              _copied ? 'Copied' : 'Copy',
                              style: BCTypography.textXs.copyWith(
                                color: bc.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: widget.padding ?? const EdgeInsets.all(12),
            child: Text(
              widget.code,
              style: widget.textStyle ?? BCAIChatTheme.monospace(foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the markdown subset an assistant actually emits, with no
/// third-party dependency.
///
/// Blocks: fenced code with an optional language, ATX headings, `-`/`*`/`+`
/// and ordered lists, `>` blockquotes, `---` rules, pipe tables, paragraphs.
/// Inline: `**bold**`, `*italic*`, `` `code` ``, `~~strike~~`, `[text](url)`
/// and bare URLs.
///
/// It is built for streaming: a fence that has been opened but not yet closed
/// renders as a code block of whatever has arrived so far, and an unbalanced
/// `**` renders as literal text rather than swallowing the rest of the
/// message. Text only ever settles as more of it arrives.
///
/// This is deliberately a subset. If you need full CommonMark — footnotes,
/// nested block quotes, HTML passthrough — pass your own renderer through
/// `BCAIChat.contentBuilder` and use `flutter_markdown` or `gpt_markdown`
/// instead; nothing here is load-bearing for the rest of the chat UI.
class BCChatMarkdown extends StatelessWidget {
  const BCChatMarkdown({
    super.key,
    required this.data,
    this.textStyle,
    this.color,
    this.onLinkTap,
    this.selectable = true,
    this.blockSpacing = BCSpacing.sm,
    this.showCodeCopyButton = true,
    this.onCodeCopied,
  });

  final String data;

  /// Overrides the default `BCTypography.textBase`.
  final TextStyle? textStyle;

  /// Overrides the default `bc.foreground` for body text.
  final Color? color;

  /// Called with the href when a link is tapped. Links render as plain
  /// coloured text when this is null — bc_ui does not open URLs itself.
  final ValueChanged<String>? onLinkTap;

  /// Whether the text can be selected. Turn it off inside a list that already
  /// hosts its own [SelectionArea].
  final bool selectable;

  /// Gap between blocks. Overrides the default 8.
  final double blockSpacing;

  final bool showCodeCopyButton;

  /// Forwarded to every [BCChatCodeBlock.onCopy] — raise your toast here.
  final VoidCallback? onCodeCopied;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final baseStyle = (textStyle ?? BCTypography.textBase).copyWith(
      color: color ?? bc.foreground,
      height: 1.5,
    );

    final blocks = _parseBlocks(data);
    if (blocks.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[
      for (final block in blocks) _buildBlock(context, block, baseStyle, bc),
    ];

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: blockSpacing,
      children: children,
    );

    return selectable ? SelectionArea(child: column) : column;
  }

  Widget _buildBlock(
    BuildContext context,
    _MdBlock block,
    TextStyle base,
    BCThemeExtension bc,
  ) {
    switch (block.kind) {
      case _MdKind.code:
        return BCChatCodeBlock(
          code: block.text,
          language: block.language,
          showCopyButton: showCodeCopyButton,
          onCopy: onCodeCopied,
        );

      case _MdKind.heading:
        final style = switch (block.level) {
          1 => BCTypography.text2xl,
          2 => BCTypography.textXl,
          3 => BCTypography.textLg,
          _ => BCTypography.textBase,
        };
        return _RichLine(
          spans: _inlineSpans(
            block.text,
            style.copyWith(
              color: base.color,
              fontWeight: BCTypography.semiBold,
            ),
            bc,
          ),
        );

      case _MdKind.rule:
        return Container(height: 1, color: bc.separator);

      case _MdKind.quote:
        return Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: bc.border, width: 2)),
          ),
          child: _RichLine(
            spans: _inlineSpans(block.text, base.copyWith(color: bc.muted), bc),
          ),
        );

      case _MdKind.list:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            for (var i = 0; i < block.items.length; i++)
              _listRow(block, i, base, bc),
          ],
        );

      case _MdKind.table:
        return _MdTable(
          rows: block.rows,
          base: base,
          bc: bc,
          spanBuilder: (text, style) => _inlineSpans(text, style, bc),
        );

      case _MdKind.paragraph:
        return _RichLine(spans: _inlineSpans(block.text, base, bc));
    }
  }

  Widget _listRow(_MdBlock block, int i, TextStyle base, BCThemeExtension bc) {
    final item = block.items[i];
    final marker = block.ordered ? '${block.start + i}.' : '•';
    return Padding(
      padding: EdgeInsets.only(left: item.indent * 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: block.ordered ? 24 : 18,
            child: Text(marker, style: base.copyWith(color: bc.muted)),
          ),
          Expanded(child: _RichLine(spans: _inlineSpans(item.text, base, bc))),
        ],
      ),
    );
  }

  List<InlineSpan> _inlineSpans(
    String source,
    TextStyle style,
    BCThemeExtension bc,
  ) {
    return _parseInline(source).map((token) {
      switch (token.kind) {
        case _MdInlineKind.text:
          return TextSpan(text: token.text, style: style.merge(token.style));
        case _MdInlineKind.code:
          return TextSpan(
            text: token.text,
            style: BCAIChatTheme.monospace(
              style.color ?? bc.foreground,
              fontSize: (style.fontSize ?? 16) * 0.92,
            ).copyWith(backgroundColor: bc.surfaceSecondary),
          );
        case _MdInlineKind.link:
          final recognizer = onLinkTap == null
              ? null
              : (TapGestureRecognizer()
                  ..onTap = () => onLinkTap!(token.href ?? token.text));
          return TextSpan(
            text: token.text,
            style: style
                .merge(token.style)
                .copyWith(
                  color: bc.link,
                  decoration: TextDecoration.underline,
                  decorationColor: bc.link,
                ),
            recognizer: recognizer,
          );
      }
    }).toList();
  }
}

/// A paragraph-shaped [Text.rich] that keeps its own [TapGestureRecognizer]s
/// alive for as long as the spans are mounted, and disposes them after.
class _RichLine extends StatefulWidget {
  const _RichLine({required this.spans});

  final List<InlineSpan> spans;

  @override
  State<_RichLine> createState() => _RichLineState();
}

class _RichLineState extends State<_RichLine> {
  @override
  void didUpdateWidget(_RichLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.spans, widget.spans)) {
      _disposeRecognizers(oldWidget.spans);
    }
  }

  @override
  void dispose() {
    _disposeRecognizers(widget.spans);
    super.dispose();
  }

  void _disposeRecognizers(List<InlineSpan> spans) {
    for (final span in spans) {
      if (span is TextSpan) span.recognizer?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: widget.spans));
  }
}

class _MdTable extends StatelessWidget {
  const _MdTable({
    required this.rows,
    required this.base,
    required this.bc,
    required this.spanBuilder,
  });

  final List<List<String>> rows;
  final TextStyle base;
  final BCThemeExtension bc;
  final List<InlineSpan> Function(String, TextStyle) spanBuilder;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final columns = rows.fold<int>(
      0,
      (max, r) => r.length > max ? r.length : max,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          shape: BCShapes.continuous(
            BCRadius.lg,
            side: BorderSide(color: bc.border),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < rows.length; r++)
              Container(
                decoration: BoxDecoration(
                  color: r == 0 ? bc.surfaceSecondary : null,
                  border: r == 0
                      ? Border(bottom: BorderSide(color: bc.border))
                      : null,
                ),
                // Not `stretch`: the table sits in a horizontal scroll view
                // inside a shrink-wrapping column, so the row's vertical
                // extent is unbounded and stretching cannot resolve. The row
                // fill comes from the Container above instead.
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var c = 0; c < columns; c++)
                      Container(
                        width: 148,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: spanBuilder(
                              c < rows[r].length ? rows[r][c] : '',
                              r == 0
                                  ? base.copyWith(
                                      fontWeight: BCTypography.semiBold,
                                    )
                                  : base,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Block parsing
// ---------------------------------------------------------------------------

enum _MdKind { paragraph, heading, code, list, quote, rule, table }

class _MdListItem {
  const _MdListItem(this.text, this.indent);

  final String text;
  final int indent;
}

class _MdBlock {
  _MdBlock.paragraph(this.text)
    : kind = _MdKind.paragraph,
      level = 0,
      language = null,
      ordered = false,
      start = 1,
      items = const [],
      rows = const [];

  _MdBlock.heading(this.text, this.level)
    : kind = _MdKind.heading,
      language = null,
      ordered = false,
      start = 1,
      items = const [],
      rows = const [];

  _MdBlock.code(this.text, this.language)
    : kind = _MdKind.code,
      level = 0,
      ordered = false,
      start = 1,
      items = const [],
      rows = const [];

  _MdBlock.quote(this.text)
    : kind = _MdKind.quote,
      level = 0,
      language = null,
      ordered = false,
      start = 1,
      items = const [],
      rows = const [];

  _MdBlock.rule()
    : kind = _MdKind.rule,
      text = '',
      level = 0,
      language = null,
      ordered = false,
      start = 1,
      items = const [],
      rows = const [];

  _MdBlock.list(this.items, {required this.ordered, this.start = 1})
    : kind = _MdKind.list,
      text = '',
      level = 0,
      language = null,
      rows = const [];

  _MdBlock.table(this.rows)
    : kind = _MdKind.table,
      text = '',
      level = 0,
      language = null,
      ordered = false,
      start = 1,
      items = const [];

  final _MdKind kind;
  final String text;
  final int level;
  final String? language;
  final bool ordered;
  final int start;
  final List<_MdListItem> items;
  final List<List<String>> rows;
}

final _headingRe = RegExp(r'^(#{1,6})\s+(.*)$');
final _ruleRe = RegExp(r'^\s*([-*_])(\s*\1){2,}\s*$');
final _bulletRe = RegExp(r'^(\s*)[-*+]\s+(.*)$');
final _orderedRe = RegExp(r'^(\s*)(\d+)[.)]\s+(.*)$');
final _fenceRe = RegExp(r'^\s*(`{3,}|~{3,})\s*(\S*)\s*$');
final _quoteRe = RegExp(r'^\s*>\s?(.*)$');
final _tableDividerRe = RegExp(r'^\s*\|?[\s:-]*-[\s:|-]*\|?\s*$');

/// Splits markdown into blocks.
///
/// Visible for testing.
@visibleForTesting
List<Object> parseMarkdownBlocksForTest(String source) => _parseBlocks(
  source,
).map<Object>((b) => '${b.kind.name}:${b.text}').toList();

List<_MdBlock> _parseBlocks(String source) {
  final lines = source.replaceAll('\r\n', '\n').split('\n');
  final blocks = <_MdBlock>[];
  final paragraph = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    final text = paragraph.join('\n').trim();
    paragraph.clear();
    if (text.isNotEmpty) blocks.add(_MdBlock.paragraph(text));
  }

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];

    // Fenced code. An unterminated fence — the normal case mid-stream —
    // runs to the end of what has arrived rather than being dropped.
    final fence = _fenceRe.firstMatch(line);
    if (fence != null) {
      flushParagraph();
      final marker = fence.group(1)!;
      final language = fence.group(2)!;
      final body = <String>[];
      i++;
      while (i < lines.length) {
        final closing = _fenceRe.firstMatch(lines[i]);
        if (closing != null && closing.group(1)!.startsWith(marker[0])) {
          i++;
          break;
        }
        body.add(lines[i]);
        i++;
      }
      blocks.add(
        _MdBlock.code(body.join('\n'), language.isEmpty ? null : language),
      );
      continue;
    }

    if (line.trim().isEmpty) {
      flushParagraph();
      i++;
      continue;
    }

    if (_ruleRe.hasMatch(line)) {
      flushParagraph();
      blocks.add(_MdBlock.rule());
      i++;
      continue;
    }

    final heading = _headingRe.firstMatch(line);
    if (heading != null) {
      flushParagraph();
      blocks.add(
        _MdBlock.heading(heading.group(2)!.trim(), heading.group(1)!.length),
      );
      i++;
      continue;
    }

    // A pipe table needs a divider row directly under its header.
    if (line.contains('|') &&
        i + 1 < lines.length &&
        lines[i + 1].contains('-') &&
        _tableDividerRe.hasMatch(lines[i + 1])) {
      flushParagraph();
      final rows = <List<String>>[_splitTableRow(line)];
      i += 2;
      while (i < lines.length &&
          lines[i].contains('|') &&
          lines[i].trim().isNotEmpty) {
        rows.add(_splitTableRow(lines[i]));
        i++;
      }
      blocks.add(_MdBlock.table(rows));
      continue;
    }

    if (_bulletRe.hasMatch(line) || _orderedRe.hasMatch(line)) {
      flushParagraph();
      final ordered = _orderedRe.hasMatch(line);
      final items = <_MdListItem>[];
      var start = 1;
      var first = true;
      while (i < lines.length) {
        final bullet = _bulletRe.firstMatch(lines[i]);
        final numbered = _orderedRe.firstMatch(lines[i]);
        if (ordered && numbered != null) {
          if (first) start = int.tryParse(numbered.group(2)!) ?? 1;
          items.add(
            _MdListItem(
              numbered.group(3)!.trim(),
              _indentLevel(numbered.group(1)!),
            ),
          );
        } else if (!ordered && bullet != null) {
          items.add(
            _MdListItem(
              bullet.group(2)!.trim(),
              _indentLevel(bullet.group(1)!),
            ),
          );
        } else {
          break;
        }
        first = false;
        i++;
      }
      blocks.add(_MdBlock.list(items, ordered: ordered, start: start));
      continue;
    }

    final quote = _quoteRe.firstMatch(line);
    if (quote != null) {
      flushParagraph();
      final body = <String>[quote.group(1)!];
      i++;
      while (i < lines.length) {
        final next = _quoteRe.firstMatch(lines[i]);
        if (next == null) break;
        body.add(next.group(1)!);
        i++;
      }
      blocks.add(_MdBlock.quote(body.join('\n').trim()));
      continue;
    }

    paragraph.add(line);
    i++;
  }

  flushParagraph();
  return blocks;
}

int _indentLevel(String whitespace) {
  final width = whitespace.replaceAll('\t', '  ').length;
  final level = width ~/ 2;
  return level > 3 ? 3 : level;
}

List<String> _splitTableRow(String line) {
  var trimmed = line.trim();
  if (trimmed.startsWith('|')) trimmed = trimmed.substring(1);
  if (trimmed.endsWith('|')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }
  return trimmed.split('|').map((cell) => cell.trim()).toList();
}

// ---------------------------------------------------------------------------
// Inline parsing
// ---------------------------------------------------------------------------

enum _MdInlineKind { text, code, link }

class _MdInline {
  const _MdInline(this.kind, this.text, {this.style, this.href});

  final _MdInlineKind kind;
  final String text;
  final TextStyle? style;
  final String? href;
}

final _linkRe = RegExp(r'\[([^\]]*)\]\(([^)\s]+)\)');
// Only ever applied as a prefix match, and `[text](url)` is consumed by
// _linkRe first, so this never has to exclude a URL already inside a link.
final _bareUrlRe = RegExp(r'https?://[^\s<>)\]]+');

/// Splits one line of markdown into styled runs.
///
/// Visible for testing — the widget tests assert on the rendered spans, and
/// these unit-test the grammar directly.
@visibleForTesting
List<String> parseMarkdownInlineForTest(String source) => _parseInline(source)
    .map(
      (t) => '${t.kind.name}:${t.text}${t.href == null ? '' : '->${t.href}'}',
    )
    .toList();

List<_MdInline> _parseInline(String source) {
  final out = <_MdInline>[];
  final buffer = StringBuffer();
  var bold = false;
  var italic = false;
  var strike = false;

  TextStyle currentStyle() {
    return TextStyle(
      fontWeight: bold ? BCTypography.semiBold : null,
      fontStyle: italic ? FontStyle.italic : null,
      decoration: strike ? TextDecoration.lineThrough : null,
    );
  }

  void flush() {
    if (buffer.isEmpty) return;
    out.add(
      _MdInline(_MdInlineKind.text, buffer.toString(), style: currentStyle()),
    );
    buffer.clear();
  }

  var i = 0;
  while (i < source.length) {
    final rest = source.substring(i);

    // Inline code wins over every other marker, so `**` inside backticks
    // stays literal.
    if (source[i] == '`') {
      final close = source.indexOf('`', i + 1);
      if (close != -1) {
        flush();
        out.add(_MdInline(_MdInlineKind.code, source.substring(i + 1, close)));
        i = close + 1;
        continue;
      }
      // No closing backtick — treat it as text. This is the mid-stream case.
      buffer.write(source[i]);
      i++;
      continue;
    }

    final link = _linkRe.matchAsPrefix(rest);
    if (link != null) {
      flush();
      out.add(
        _MdInline(
          _MdInlineKind.link,
          link.group(1)!,
          href: link.group(2),
          style: currentStyle(),
        ),
      );
      i += link.end;
      continue;
    }

    final bare = _bareUrlRe.matchAsPrefix(rest);
    if (bare != null) {
      flush();
      out.add(
        _MdInline(
          _MdInlineKind.link,
          bare.group(0)!,
          href: bare.group(0),
          style: currentStyle(),
        ),
      );
      i += bare.end;
      continue;
    }

    // Two-character runs first, so `**` is never mistaken for two `*`.
    if (rest.startsWith('~~')) {
      if (strike && _canClose(source, i, 2)) {
        flush();
        strike = false;
      } else if (!strike &&
          _canOpen(source, i, 2) &&
          _findCloser(source, i + 2, '~~') != -1) {
        flush();
        strike = true;
      } else {
        // An opener with nothing closing it yet — the normal mid-stream
        // case. Emit it literally rather than falling through to the
        // single-marker branch, which would emphasise the rest of the
        // message.
        buffer.write('~~');
      }
      i += 2;
      continue;
    }

    if (rest.startsWith('**')) {
      if (bold && _canClose(source, i, 2)) {
        flush();
        bold = false;
      } else if (!bold &&
          _canOpen(source, i, 2) &&
          _findCloser(source, i + 2, '**') != -1) {
        flush();
        bold = true;
      } else {
        buffer.write('**');
      }
      i += 2;
      continue;
    }

    final marker = source[i];
    if (marker == '*' || marker == '_') {
      if (italic && _canClose(source, i, 1)) {
        flush();
        italic = false;
        i++;
        continue;
      }
      if (!italic &&
          _canOpen(source, i, 1) &&
          _findCloser(source, i + 1, marker) != -1) {
        flush();
        italic = true;
        i++;
        continue;
      }
    }

    buffer.write(source[i]);
    i++;
  }

  flush();
  return out;
}

/// Whether the delimiter run of [length] at [start] can open emphasis.
///
/// CommonMark's left-flanking rule, trimmed to what an assistant emits: the
/// run must be followed by something other than whitespace, so `2 * 3` is
/// arithmetic rather than an opener. `_` additionally may not follow a word
/// character, which is what keeps `snake_case_word` intact.
bool _canOpen(String source, int start, int length) {
  final after = start + length;
  if (after >= source.length) return false;
  if (_isWhitespace(source.codeUnitAt(after))) return false;
  if (source[start] == '_' && start > 0) {
    if (_isWordChar(source.codeUnitAt(start - 1))) return false;
  }
  return true;
}

/// Whether the delimiter run of [length] at [start] can close emphasis —
/// CommonMark's right-flanking rule, mirrored from [_canOpen].
bool _canClose(String source, int start, int length) {
  if (start == 0) return false;
  if (_isWhitespace(source.codeUnitAt(start - 1))) return false;
  if (source[start] == '_') {
    final after = start + length;
    if (after < source.length && _isWordChar(source.codeUnitAt(after))) {
      return false;
    }
  }
  return true;
}

/// The index of the next run of [token] after [from] that could close
/// emphasis, or -1. Opening only when a closer exists is what keeps a
/// half-arrived `**bold` from emphasising everything after it.
int _findCloser(String source, int from, String token) {
  var at = source.indexOf(token, from);
  while (at != -1) {
    if (_canClose(source, at, token.length)) return at;
    at = source.indexOf(token, at + 1);
  }
  return -1;
}

bool _isWhitespace(int codeUnit) =>
    codeUnit == 0x20 || codeUnit == 0x09 || codeUnit == 0x0A;

bool _isWordChar(int codeUnit) {
  return (codeUnit >= 0x30 && codeUnit <= 0x39) ||
      (codeUnit >= 0x41 && codeUnit <= 0x5A) ||
      (codeUnit >= 0x61 && codeUnit <= 0x7A) ||
      codeUnit == 0x5F;
}
