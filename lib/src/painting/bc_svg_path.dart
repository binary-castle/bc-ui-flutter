import 'dart:ui';

const String _commandChars = 'MmLlHhVvCcSsQqTtAaZz';

/// Parses SVG path data (the `d` attribute) into a [Path].
///
/// Covers the whole path grammar — M/L/H/V/C/S/Q/T/A/Z, absolute and
/// relative, with implicit repeats and packed arc flags. Coordinates come out
/// in the source viewBox space; scale them on the canvas before painting
/// (see `bc_brand_logo.dart`).
///
/// Fill rule is left at [PathFillType.nonZero], matching the SVG default.
Path parseSvgPathData(String data) {
  final scanner = _SvgPathScanner(data);
  final path = Path();

  var current = Offset.zero;
  var subpathStart = Offset.zero;
  // Reflection anchors for the smooth curve commands. They collapse onto the
  // current point after any non-curve command, as the spec requires.
  var cubicControl = Offset.zero;
  var quadControl = Offset.zero;
  var command = '';

  while (!scanner.atEnd) {
    final next = scanner.readCommandOrNull();
    if (next != null) {
      command = next;
    } else if (command.isEmpty) {
      throw FormatException('SVG path data must start with a command', data);
    }

    Offset resolve(Offset value, bool relative) =>
        relative ? current + value : value;

    switch (command) {
      case 'M' || 'm':
        final relative = command == 'm';
        current = resolve(scanner.readOffset(), relative);
        path.moveTo(current.dx, current.dy);
        subpathStart = current;
        cubicControl = quadControl = current;
        // Extra coordinate pairs after a moveto are implicit linetos.
        command = relative ? 'l' : 'L';
      case 'L' || 'l':
        current = resolve(scanner.readOffset(), command == 'l');
        path.lineTo(current.dx, current.dy);
        cubicControl = quadControl = current;
      case 'H' || 'h':
        final x = scanner.readNumber();
        current = Offset(command == 'h' ? current.dx + x : x, current.dy);
        path.lineTo(current.dx, current.dy);
        cubicControl = quadControl = current;
      case 'V' || 'v':
        final y = scanner.readNumber();
        current = Offset(current.dx, command == 'v' ? current.dy + y : y);
        path.lineTo(current.dx, current.dy);
        cubicControl = quadControl = current;
      case 'C' || 'c':
        final relative = command == 'c';
        final c1 = resolve(scanner.readOffset(), relative);
        final c2 = resolve(scanner.readOffset(), relative);
        final end = resolve(scanner.readOffset(), relative);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        cubicControl = c2;
        quadControl = current = end;
      case 'S' || 's':
        final relative = command == 's';
        final c1 = current * 2 - cubicControl;
        final c2 = resolve(scanner.readOffset(), relative);
        final end = resolve(scanner.readOffset(), relative);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        cubicControl = c2;
        quadControl = current = end;
      case 'Q' || 'q':
        final relative = command == 'q';
        final control = resolve(scanner.readOffset(), relative);
        final end = resolve(scanner.readOffset(), relative);
        path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
        quadControl = control;
        cubicControl = current = end;
      case 'T' || 't':
        final control = current * 2 - quadControl;
        final end = resolve(scanner.readOffset(), command == 't');
        path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
        quadControl = control;
        cubicControl = current = end;
      case 'A' || 'a':
        final rx = scanner.readNumber().abs();
        final ry = scanner.readNumber().abs();
        final rotation = scanner.readNumber();
        final largeArc = scanner.readFlag();
        final clockwise = scanner.readFlag();
        final end = resolve(scanner.readOffset(), command == 'a');
        if (end != current) {
          if (rx == 0 || ry == 0) {
            // A degenerate radius draws a straight line (spec F.6.2).
            path.lineTo(end.dx, end.dy);
          } else {
            path.arcToPoint(
              end,
              radius: Radius.elliptical(rx, ry),
              rotation: rotation,
              largeArc: largeArc,
              clockwise: clockwise,
            );
          }
        }
        cubicControl = quadControl = current = end;
      case 'Z' || 'z':
        path.close();
        cubicControl = quadControl = current = subpathStart;
      default:
        throw FormatException('Unsupported SVG path command', data);
    }
  }

  return path;
}

class _SvgPathScanner {
  _SvgPathScanner(this.data);

  final String data;
  int _index = 0;

  bool get atEnd {
    _skipSeparators();
    return _index >= data.length;
  }

  /// Reads the next command letter, or null when the next token is an
  /// argument (an implicit repeat of the previous command).
  String? readCommandOrNull() {
    _skipSeparators();
    if (_index >= data.length) return null;
    final char = data[_index];
    if (!_commandChars.contains(char)) return null;
    _index++;
    return char;
  }

  Offset readOffset() => Offset(readNumber(), readNumber());

  double readNumber() {
    _skipSeparators();
    final start = _index;
    _consumeSign();
    _consumeDigits();
    if (_index < data.length && data[_index] == '.') {
      _index++;
      _consumeDigits();
    }
    if (_index < data.length && (data[_index] == 'e' || data[_index] == 'E')) {
      _index++;
      _consumeSign();
      _consumeDigits();
    }
    final value = double.tryParse(data.substring(start, _index));
    if (value == null) {
      throw FormatException('Expected a number in SVG path data', data, start);
    }
    return value;
  }

  /// Arc flags are single characters and may be packed without separators
  /// ("a1 1 0 011 1"), so they cannot go through [readNumber].
  bool readFlag() {
    _skipSeparators();
    if (_index >= data.length) {
      throw FormatException('Expected an arc flag in SVG path data', data);
    }
    final char = data[_index];
    if (char != '0' && char != '1') {
      throw FormatException(
        'Expected an arc flag in SVG path data',
        data,
        _index,
      );
    }
    _index++;
    return char == '1';
  }

  void _consumeSign() {
    if (_index < data.length && (data[_index] == '-' || data[_index] == '+')) {
      _index++;
    }
  }

  void _consumeDigits() {
    while (_index < data.length) {
      final code = data.codeUnitAt(_index);
      if (code < 0x30 || code > 0x39) break;
      _index++;
    }
  }

  void _skipSeparators() {
    while (_index < data.length) {
      switch (data[_index]) {
        case ' ' || ',' || '\n' || '\r' || '\t':
          _index++;
        default:
          return;
      }
    }
  }
}
