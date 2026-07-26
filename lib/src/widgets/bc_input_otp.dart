import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/otp_theme.dart';
import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:bc_ui/src/theme/component_themes/otp_theme.dart'
    show BCInputOTPVariant;

class BCInputOTP extends StatefulWidget {
  const BCInputOTP({
    super.key,
    required this.maxLength,
    required this.child,
    this.value,
    this.onChanged,
    this.onCompleted,
    this.controller,
    this.focusNode,
    this.isDisabled = false,
    this.isInvalid = false,
    this.variant = BCInputOTPVariant.primary,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.placeholder,
    this.autofocus = false,
    this.onFocus,
    this.onBlur,
  });

  final int maxLength;
  final Widget child;
  final String? value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isDisabled;
  final bool isInvalid;
  final BCInputOTPVariant variant;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? placeholder;
  final bool autofocus;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;

  @override
  State<BCInputOTP> createState() => _BCInputOTPState();
}

class _BCInputOTPState extends State<BCInputOTP> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.value != null) {
      _controller.text = widget.value!;
    }

    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(BCInputOTP oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != null && widget.value != _controller.text) {
      _controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused == _isFocused) return;

    setState(() => _isFocused = focused);

    if (focused) {
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
  }

  void _handleTextChange() {
    final text = _controller.text;
    widget.onChanged?.call(text);

    if (text.length == widget.maxLength) {
      widget.onCompleted?.call(text);
    }

    setState(() {});
  }

  List<TextInputFormatter> get _formatters {
    return widget.inputFormatters ??
        [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(widget.maxLength),
        ];
  }

  @override
  Widget build(BuildContext context) {
    final content = _BCInputOTPScope(
      value: _controller.text,
      maxLength: widget.maxLength,
      isFocused: _isFocused,
      isDisabled: widget.isDisabled,
      isInvalid: widget.isInvalid,
      variant: widget.variant,
      placeholder: widget.placeholder,
      focusNode: _focusNode,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isDisabled,
                autofocus: widget.autofocus,
                keyboardType: widget.keyboardType,
                inputFormatters: _formatters,
                maxLength: widget.maxLength,
                showCursor: false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.isDisabled) return content;

    return Opacity(
      opacity: context.bcTheme.opacityDisabled,
      child: IgnorePointer(child: content),
    );
  }
}

class BCInputOTPGroup extends StatelessWidget {
  const BCInputOTPGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _withGap(children),
    );
  }

  List<Widget> _withGap(List<Widget> items) {
    if (items.isEmpty) return const [];

    final result = <Widget>[items.first];
    for (var i = 1; i < items.length; i++) {
      result
        ..add(const SizedBox(width: BCInputOTPTheme.slotGap))
        ..add(items[i]);
    }
    return result;
  }
}

class BCInputOTPSlot extends StatelessWidget {
  const BCInputOTPSlot({
    super.key,
    required this.index,
    this.variant,
    this.child,
  });

  final int index;
  final BCInputOTPVariant? variant;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scope = _BCInputOTPScope.of(context)!;
    final bc = context.bcTheme;

    final char = index < scope.value.length ? scope.value[index] : '';
    final activeIndex = scope.value.length.clamp(0, scope.maxLength - 1);
    final isActive = scope.isFocused && index == activeIndex;
    final placeholderChar = scope.placeholder != null &&
            index < scope.placeholder!.length
        ? scope.placeholder![index]
        : '';

    final slotVariant = variant ?? scope.variant;

    return _BCInputOTPSlotScope(
      char: char,
      placeholderChar: placeholderChar,
      isActive: isActive,
      isCaretVisible: isActive && char.isEmpty,
      variant: slotVariant,
      child: SizedBox(
        width: BCInputOTPTheme.slotWidth,
        height: BCInputOTPTheme.slotHeight,
        child: DecoratedBox(
          decoration: BCInputOTPTheme.slotDecoration(
            bc: bc,
            variant: slotVariant,
            isActive: isActive,
            isInvalid: scope.isInvalid,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BCInputOTPTheme.radius),
            child: Center(
              child: child ??
                  const Stack(
                    alignment: Alignment.center,
                    children: [
                      BCInputOTPSlotPlaceholder(),
                      BCInputOTPSlotValue(),
                      BCInputOTPSlotCaret(),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class BCInputOTPSlotPlaceholder extends StatelessWidget {
  const BCInputOTPSlotPlaceholder({super.key, this.child});

  final String? child;

  @override
  Widget build(BuildContext context) {
    final slotScope = _BCInputOTPSlotScope.of(context)!;
    final bc = context.bcTheme;

    final displayChar = child ?? slotScope.placeholderChar;

    if (slotScope.char.isNotEmpty ||
        slotScope.isActive ||
        displayChar.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      displayChar,
      style: BCInputOTPTheme.placeholderTextStyle(bc),
    );
  }
}

class BCInputOTPSlotValue extends StatelessWidget {
  const BCInputOTPSlotValue({super.key, this.child});

  final String? child;

  @override
  Widget build(BuildContext context) {
    final slotScope = _BCInputOTPSlotScope.of(context)!;
    final bc = context.bcTheme;

    final displayChar = child ?? slotScope.char;

    if (displayChar.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: BCDuration.normal,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        displayChar,
        key: ValueKey(displayChar),
        style: BCInputOTPTheme.valueTextStyle(bc),
      ),
    );
  }
}

class BCInputOTPSlotCaret extends StatefulWidget {
  const BCInputOTPSlotCaret({super.key});

  @override
  State<BCInputOTPSlotCaret> createState() => _BCInputOTPSlotCaretState();
}

class _BCInputOTPSlotCaretState extends State<BCInputOTPSlotCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: BCInputOTPTheme.caretBlink,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slotScope = _BCInputOTPSlotScope.of(context)!;

    if (!slotScope.isCaretVisible) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: BCInputOTPTheme.caretWidth,
        height: BCInputOTPTheme.caretHeight,
        decoration: BoxDecoration(
          color: BCInputOTPTheme.caretColor(context.bcTheme),
          borderRadius: BorderRadius.circular(BCInputOTPTheme.caretWidth),
        ),
      ),
    );
  }
}

class BCInputOTPSeparator extends StatelessWidget {
  const BCInputOTPSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BCInputOTPTheme.slotGap),
      child: Container(
        width: BCInputOTPTheme.separatorWidth,
        height: BCInputOTPTheme.separatorHeight,
        decoration: BoxDecoration(
          color: BCInputOTPTheme.separatorColor(context.bcTheme),
          borderRadius: BorderRadius.circular(BCInputOTPTheme.separatorHeight),
        ),
      ),
    );
  }
}

class _BCInputOTPScope extends InheritedWidget {
  const _BCInputOTPScope({
    required this.value,
    required this.maxLength,
    required this.isFocused,
    required this.isDisabled,
    required this.isInvalid,
    required this.variant,
    required this.placeholder,
    required this.focusNode,
    required super.child,
  });

  final String value;
  final int maxLength;
  final bool isFocused;
  final bool isDisabled;
  final bool isInvalid;
  final BCInputOTPVariant variant;
  final String? placeholder;
  final FocusNode focusNode;

  static _BCInputOTPScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_BCInputOTPScope>();
  }

  @override
  bool updateShouldNotify(_BCInputOTPScope oldWidget) {
    return value != oldWidget.value ||
        maxLength != oldWidget.maxLength ||
        isFocused != oldWidget.isFocused ||
        isDisabled != oldWidget.isDisabled ||
        isInvalid != oldWidget.isInvalid ||
        variant != oldWidget.variant ||
        placeholder != oldWidget.placeholder;
  }
}

class _BCInputOTPSlotScope extends InheritedWidget {
  const _BCInputOTPSlotScope({
    required this.char,
    required this.placeholderChar,
    required this.isActive,
    required this.isCaretVisible,
    required this.variant,
    required super.child,
  });

  final String char;
  final String placeholderChar;
  final bool isActive;
  final bool isCaretVisible;
  final BCInputOTPVariant variant;

  static _BCInputOTPSlotScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_BCInputOTPSlotScope>();
  }

  @override
  bool updateShouldNotify(_BCInputOTPSlotScope oldWidget) {
    return char != oldWidget.char ||
        placeholderChar != oldWidget.placeholderChar ||
        isActive != oldWidget.isActive ||
        isCaretVisible != oldWidget.isCaretVisible ||
        variant != oldWidget.variant;
  }
}
