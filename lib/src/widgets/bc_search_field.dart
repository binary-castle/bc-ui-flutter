import 'package:flutter/material.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_motion.dart';
import 'bc_input.dart';
import 'bc_pressable.dart';

/// HeroUI Native SearchField (search-field.css): an [BCInput] with a leading
/// search icon (absolute left 12) and an animated 24×24 clear button
/// (absolute right 12) that appears while the field has text.
class BCSearchField extends StatefulWidget {
  const BCSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.variant = BCInputVariant.primary,
    this.placeholder,
    this.isInvalid = false,
    this.isDisabled = false,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final BCInputVariant variant;
  final String? placeholder;
  final bool isInvalid;
  final bool isDisabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  State<BCSearchField> createState() => _BCSearchFieldState();
}

class _BCSearchFieldState extends State<BCSearchField> {
  TextEditingController? _internalController;
  bool _hasText = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(BCSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)
          ?.removeListener(_handleTextChange);
      _controller.addListener(_handleTextChange);
      _hasText = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    (widget.controller ?? _internalController)
        ?.removeListener(_handleTextChange);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return BCInput(
      controller: _controller,
      focusNode: widget.focusNode,
      variant: widget.variant,
      placeholder: widget.placeholder,
      isInvalid: widget.isInvalid,
      isDisabled: widget.isDisabled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      prefix: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(Icons.search, size: 20, color: bc.muted),
      ),
      suffix: AnimatedOpacity(
        opacity: _hasText ? 1 : 0,
        duration: BCMotion.highlightDuration,
        child: IgnorePointer(
          ignoring: !_hasText,
          child: BCPressable(
            feedback: BCPressFeedback.none,
            onPressed: _clear,
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: bc.defaultColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 14, color: bc.muted),
            ),
          ),
        ),
      ),
    );
  }
}
