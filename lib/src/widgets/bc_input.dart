import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';

enum BCInputVariant { primary, secondary }

/// HeroUI Native Input (input.css): min-height 48, 12px horizontal padding,
/// 14px continuous corners, field background + field shadow (primary) or
/// `default` background (secondary), 2px accent focus outline
/// (danger when invalid), muted placeholder.
class BCInput extends StatefulWidget {
  const BCInput({
    super.key,
    this.controller,
    this.focusNode,
    this.variant = BCInputVariant.primary,
    this.placeholder,
    this.isInvalid = false,
    this.isDisabled = false,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.minHeight = 48,
    this.verticalPadding,
    this.contentPadding,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.autofillHints,
    this.contentInsertionConfiguration,
    this.prefix,
    this.suffix,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final BCInputVariant variant;
  final String? placeholder;
  final bool isInvalid;
  final bool isDisabled;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final double minHeight;

  /// Vertical padding inside the field; used by multiline fields
  /// (TextArea uses 8).
  final double? verticalPadding;

  /// Overrides the default `EdgeInsets.symmetric(horizontal: 12)`.
  final EdgeInsetsGeometry? contentPadding;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;

  /// What the OS should offer to fill in — [AutofillHints.email],
  /// [AutofillHints.telephoneNumberNational], and so on. Without it the
  /// keychain and iOS's one-tap SMS code are unavailable.
  final Iterable<String>? autofillHints;

  /// What to do when the keyboard or clipboard inserts rich content — a
  /// pasted image, a GIF from the keyboard's picker. Null uses Flutter's
  /// default, which is to refuse the insertion.
  ///
  /// Only Android delivers these today; on every other platform the callback
  /// never fires, so a desktop app wanting paste-to-attach still has to read
  /// the clipboard itself.
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  final Widget? prefix;
  final Widget? suffix;

  @override
  State<BCInput> createState() => _BCInputState();
}

class _BCInputState extends State<BCInput> {
  FocusNode? _internalNode;
  bool _isFocused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(BCInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalNode)
          ?.removeListener(_handleFocusChange);
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _internalNode)?.removeListener(_handleFocusChange);
    _internalNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final BorderSide side;
    if (widget.isInvalid) {
      side = BorderSide(color: bc.danger, width: 2);
    } else if (_isFocused) {
      side = BorderSide(color: bc.accent, width: 2);
    } else {
      side = BorderSide.none;
    }

    final multiline = (widget.maxLines ?? 2) != 1;

    final textField = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: !widget.isDisabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      cursorColor: widget.isInvalid ? bc.danger : bc.accent,
      style: BCTypography.textBase.copyWith(color: bc.foreground),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.placeholder,
        hintStyle:
            BCTypography.textBase.copyWith(color: bc.fieldPlaceholder),
      ),
    );

    Widget field = Container(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      decoration: ShapeDecoration(
        color: widget.variant == BCInputVariant.primary
            ? bc.field
            : bc.defaultColor,
        shape: BCShapes.continuous(BCRadius.field, side: side),
        shadows: widget.variant == BCInputVariant.primary
            ? bc.fieldShadow.shadows
            : null,
      ),
      padding: widget.contentPadding ??
          EdgeInsets.symmetric(
            horizontal: 12,
            vertical: widget.verticalPadding ?? 0,
          ),
      alignment: multiline ? Alignment.topLeft : null,
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          ?widget.prefix,
          Expanded(child: textField),
          ?widget.suffix,
        ],
      ),
    );

    // Tapping anywhere on the field (padding, border, empty space in a
    // multiline area) focuses the input; taps directly on the text still
    // position the caret normally because the inner TextField's gesture
    // recognizer wins where they overlap.
    field = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: field,
    );

    if (widget.isDisabled) {
      field = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: field),
      );
    }

    return field;
  }
}
