import 'dart:async';

import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../overlay/bc_overlay_anchor.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';
import 'bc_button.dart';
import 'bc_picker_presentation.dart';
import 'bc_pressable.dart';
import 'bc_search_field.dart';
import 'bc_spinner.dart';

class BCSelectItem<T> {
  const BCSelectItem({
    required this.value,
    required this.label,
    this.description,
    this.leading,
    this.trailing,
    this.onTap,
    this.isDisabled = false,
  });

  final T value;
  final String label;
  final String? description;

  /// Prefix widget — an avatar, a flag, an icon. Sized by you; the row
  /// centres it against the label.
  final Widget? leading;

  /// Suffix widget — a price, a chip, a shortcut hint. Sits between the
  /// label and the selection check.
  final Widget? trailing;

  /// Runs when this row is picked, alongside [BCSelect.onValueChange]. Use it
  /// for the side errand a row sometimes carries: logging, prefetching, or
  /// pushing a 'manage…' route.
  final VoidCallback? onTap;

  /// Greys the row out and stops it being picked.
  final bool isDisabled;
}

/// How a [BCSelect] surfaces its options.
enum BCSelectPresentation {
  /// Anchored list under the trigger, matching its width.
  popover,

  /// Modal sheet — more room for a long list, and the search field sits
  /// above the keyboard rather than behind it.
  bottomSheet,

  /// A spinning wheel in a sheet, committed with Done. Suits short ordered
  /// lists — a quantity, a unit, a duration — where spinning beats reading.
  wheel,
}

/// HeroUI Native Select (select.css): a surface-styled trigger
/// (py12/px16, radius 16, surface shadow) with a rotating chevron, opening
/// an option list (overlay bg, p12, radius 24) with accent check indicators.
///
/// [presentation] chooses where the options appear. Both list presentations
/// ([BCSelectPresentation.popover] and [BCSelectPresentation.bottomSheet])
/// share the same list features:
///
/// * `isSearchable` filters [items] by label and description as you type.
/// * `onSearch` replaces that with your own lookup — debounced, awaited, and
///   free to hit the network. Whatever it returns is what the list shows.
/// * `onLoadMore` fires as the list nears its end, so the next page can be
///   appended to [items]; `isLoadingMore` shows a spinner meanwhile.
///
/// ```dart
/// BCSelect<String>(
///   presentation: BCSelectPresentation.bottomSheet,
///   isSearchable: true,
///   items: countries,
///   value: country,
///   onValueChange: (value) => setState(() => country = value),
/// )
/// ```
class BCSelect<T> extends StatefulWidget {
  const BCSelect({
    super.key,
    required this.items,
    this.value,
    this.onValueChange,
    this.placeholder = 'Select an option',
    this.listLabel,
    this.isDisabled = false,
    this.placement = BCOverlayPlacement.auto,
    this.presentation = BCSelectPresentation.popover,
    this.isSearchable = false,
    this.searchPlaceholder = 'Search',
    this.onSearch,
    this.searchDebounce = const Duration(milliseconds: 250),
    this.onLoadMore,
    this.isLoadingMore = false,
    this.emptyPlaceholder,
    this.itemBuilder,
    this.triggerBuilder,
    this.matchTriggerWidth = true,
    this.triggerFeedback = BCPressFeedback.scale,
    this.maxListHeight,
  });

  final List<BCSelectItem<T>> items;
  final T? value;
  final ValueChanged<T>? onValueChange;
  final String placeholder;

  /// Optional label above the option list (select__list-label). Doubles as
  /// the header title in the sheet presentations.
  final String? listLabel;

  final bool isDisabled;

  /// Where the list opens relative to the trigger. Popover only.
  final BCOverlayPlacement placement;

  final BCSelectPresentation presentation;

  /// Shows a search field above the list, filtering [items] on label and
  /// description. Implied by [onSearch].
  final bool isSearchable;

  final String searchPlaceholder;

  /// Your own lookup, in place of the built-in filter — debounced by
  /// [searchDebounce] and awaited with a spinner while it runs.
  final Future<List<BCSelectItem<T>>> Function(String query)? onSearch;

  final Duration searchDebounce;

  /// Called as the list scrolls within 200px of its end, once per page.
  /// Append to [items] and the list keeps going.
  final VoidCallback? onLoadMore;

  /// Shows a spinner below the last option while a page is in flight.
  final bool isLoadingMore;

  /// Shown when the list has nothing in it. Defaults to 'No results'.
  final Widget? emptyPlaceholder;

  /// Replaces the row layout wholesale — price columns, two-line meta,
  /// whatever the screen needs. Press feedback, the tap and the disabled
  /// state still come from the list, and `isSelected` is handed to you so
  /// the selection can be shown however you like.
  ///
  /// Ignored by [BCSelectPresentation.wheel], which spins labels.
  final Widget Function(
    BuildContext context,
    BCSelectItem<T> item,
    bool isSelected,
  )? itemBuilder;

  /// Replaces the trigger wholesale — a flag and a dial code inside a phone
  /// field, an avatar beside a name, a bare icon. The press feedback, the tap,
  /// the disabled dimming and the popover anchoring still come from the
  /// Select; `selected` is null until something is picked, and `isOpen` is
  /// handed to you so a chevron can rotate with the list.
  ///
  /// A trigger narrower than its list wants [matchTriggerWidth] turned off.
  final Widget Function(
    BuildContext context,
    BCSelectItem<T>? selected,
    bool isOpen,
  )? triggerBuilder;

  /// Sizes the popover list to the trigger. Turn it off when [triggerBuilder]
  /// makes the trigger narrower than its list — an 80px flag button would
  /// otherwise open an 80px-wide list with an unusable search field.
  ///
  /// Popover only; the sheet presentations are routes and ignore it.
  final bool matchTriggerWidth;

  /// Press feedback on the trigger. The scale is width-compensated, so a small
  /// [triggerBuilder] trigger pops harder than the default one —
  /// [BCPressFeedback.highlight] or [BCPressFeedback.none] suits an inline
  /// control better.
  final BCPressFeedback triggerFeedback;

  /// Cap on the popover list's height. Defaults to 280.
  final double? maxListHeight;

  @override
  State<BCSelect<T>> createState() => _BCSelectState<T>();
}

class _BCSelectState<T> extends State<BCSelect<T>> {
  final BCAnchoredOverlayController _controller =
      BCAnchoredOverlayController();
  bool _isOpen = false;

  /// The item last picked. With an async [BCSelect.onSearch] the selection
  /// can drop out of `items` on the next query, and the trigger should keep
  /// showing its label rather than falling back to the placeholder.
  BCSelectItem<T>? _lastSelected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BCSelectItem<T>? get _selected {
    for (final item in widget.items) {
      if (item.value == widget.value) return item;
    }
    if (_lastSelected?.value == widget.value) return _lastSelected;
    return null;
  }

  void _commit(BCSelectItem<T> item) {
    _lastSelected = item;
    widget.onValueChange?.call(item.value);
  }

  Future<void> _open() async {
    switch (widget.presentation) {
      case BCSelectPresentation.popover:
        _controller.toggle();

      case BCSelectPresentation.bottomSheet:
        setState(() => _isOpen = true);
        final picked = await showBCPickerSheet<BCSelectItem<T>>(
          context,
          builder: (sheetContext) => _BCSelectListPanel<T>(
            select: widget,
            showTitle: true,
            autofocusSearch: true,
            // Half the screen when the sheet has the room for it; the panel's
            // own bounds trim this back as the keyboard takes the lower half.
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.5,
            onSelected: (item) => Navigator.of(sheetContext).pop(item),
          ),
        );
        if (!mounted) return;
        setState(() => _isOpen = false);
        if (picked != null) _commit(picked);

      case BCSelectPresentation.wheel:
        if (widget.items.isEmpty) return;
        setState(() => _isOpen = true);
        final selectedIndex = widget.items.indexWhere(
          (item) => item.value == widget.value,
        );
        final picked = await showBCPickerSheet<BCSelectItem<T>>(
          context,
          builder: (sheetContext) => _BCSelectWheelPanel<T>(
            items: widget.items,
            title: widget.listLabel,
            initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onDone: (item) => Navigator.of(sheetContext).pop(item),
          ),
        );
        if (!mounted) return;
        setState(() => _isOpen = false);
        if (picked != null) _commit(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final selected = _selected;
    final buildTrigger = widget.triggerBuilder;

    Widget trigger = buildTrigger != null
        ? buildTrigger(context, selected, _isOpen)
        : Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: bc.surface,
              shape: BCShapes.continuous(BCRadius.xxl),
              shadows: bc.surfaceShadow.shadows,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Text(
                    selected?.label ?? widget.placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BCTypography.textBase.copyWith(
                      color:
                          selected != null ? bc.foreground : bc.fieldPlaceholder,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: bc.muted,
                  ),
                ),
              ],
            ),
          );

    if (widget.isDisabled) {
      trigger = Opacity(opacity: bc.opacityDisabled, child: trigger);
    }

    final pressable = BCPressable(
      feedback: widget.triggerFeedback,
      enabled: !widget.isDisabled,
      onPressed: widget.isDisabled ? null : _open,
      child: trigger,
    );

    // The sheet presentations are routes; only the popover needs an anchor.
    if (widget.presentation != BCSelectPresentation.popover) return pressable;

    return BCAnchoredOverlay(
      controller: _controller,
      placement: widget.placement,
      matchAnchorWidth: widget.matchTriggerWidth,
      onOpenChange: (open) => setState(() => _isOpen = open),
      overlayBuilder: (overlayContext) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: bc.overlay,
          shape: BCShapes.continuous(
            BCRadius.xxxl,
            side: bc.overlayShadow.innerBorder ?? BorderSide.none,
          ),
          shadows: bc.overlayShadow.shadows,
        ),
        padding: const EdgeInsets.all(12),
        child: _BCSelectListPanel<T>(
          select: widget,
          maxHeight: widget.maxListHeight ?? 280,
          onSelected: (item) {
            _controller.close();
            _commit(item);
          },
        ),
      ),
      child: pressable,
    );
  }
}

/// The searchable, paginating option list behind the popover and the sheet.
class _BCSelectListPanel<T> extends StatefulWidget {
  const _BCSelectListPanel({
    required this.select,
    required this.onSelected,
    required this.maxHeight,
    this.showTitle = false,
    this.autofocusSearch = false,
  });

  final BCSelect<T> select;
  final ValueChanged<BCSelectItem<T>> onSelected;
  final double maxHeight;

  /// Sheets get a centred header; the popover keeps the compact list label.
  final bool showTitle;

  final bool autofocusSearch;

  @override
  State<_BCSelectListPanel<T>> createState() => _BCSelectListPanelState<T>();
}

class _BCSelectListPanelState<T> extends State<_BCSelectListPanel<T>> {
  final ScrollController _scroll = ScrollController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;
  String _query = '';

  /// Results of the last [BCSelect.onSearch] call; null until one returns.
  List<BCSelectItem<T>>? _results;
  bool _isSearching = false;

  /// Extent at which a page was last requested, so scrolling to the end
  /// doesn't fire [BCSelect.onLoadMore] once per frame.
  double _requestedAtExtent = -1;

  BCSelect<T> get _select => widget.select;

  bool get _hasSearch => _select.isSearchable || _select.onSearch != null;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_handleScroll);
    if (widget.autofocusSearch && _hasSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_handleScroll);
    _scroll.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<BCSelectItem<T>> get _visible {
    if (_select.onSearch != null) return _results ?? _select.items;

    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _select.items;
    return [
      for (final item in _select.items)
        if (item.label.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false))
          item,
    ];
  }

  void _handleQuery(String value) {
    setState(() => _query = value);

    final search = _select.onSearch;
    if (search == null) return;

    _debounce?.cancel();
    _debounce = Timer(_select.searchDebounce, () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        final results = await search(value);
        if (!mounted) return;
        setState(() {
          _results = results;
          // A new result set starts pagination over.
          _requestedAtExtent = -1;
        });
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _handleScroll() {
    final onLoadMore = _select.onLoadMore;
    if (onLoadMore == null || _select.isLoadingMore) return;
    if (!_scroll.hasClients) return;

    final position = _scroll.position;
    if (position.pixels < position.maxScrollExtent - 200) return;
    if (position.maxScrollExtent == _requestedAtExtent) return;

    _requestedAtExtent = position.maxScrollExtent;
    onLoadMore();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final items = _visible;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_select.listLabel != null)
          Padding(
            padding: widget.showTitle
                ? const EdgeInsets.fromLTRB(
                    BCSpacing.sm,
                    0,
                    BCSpacing.sm,
                    BCSpacing.sm,
                  )
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              _select.listLabel!,
              textAlign: widget.showTitle ? TextAlign.center : TextAlign.start,
              style: widget.showTitle
                  ? BCTypography.textBase.copyWith(
                      color: bc.foreground,
                      fontWeight: BCTypography.semiBold,
                    )
                  : BCTypography.textSm.copyWith(
                      color: bc.muted,
                      fontWeight: BCTypography.medium,
                    ),
            ),
          ),
        if (_hasSearch)
          Padding(
            padding: const EdgeInsets.only(bottom: BCSpacing.sm),
            child: BCSearchField(
              focusNode: _searchFocus,
              placeholder: _select.searchPlaceholder,
              onChanged: _handleQuery,
              onClear: () => _handleQuery(''),
            ),
          ),
        if (_isSearching && items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: BCSpacing.lg),
            child: Center(child: BCSpinner(size: BCSpinnerSize.sm)),
          )
        else if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: BCSpacing.lg),
            child: Center(
              child: _select.emptyPlaceholder ??
                  Text(
                    'No results',
                    style: BCTypography.textSm.copyWith(color: bc.muted),
                  ),
            ),
          )
        else
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              child: ListView.builder(
                controller: _scroll,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: items.length + (_select.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: BCSpacing.md),
                      child: Center(child: BCSpinner(size: BCSpinnerSize.sm)),
                    );
                  }
                  final item = items[index];
                  return _SelectOption<T>(
                    item: item,
                    isSelected: item.value == _select.value,
                    itemBuilder: _select.itemBuilder,
                    onPressed: item.isDisabled
                        ? null
                        : () {
                            item.onTap?.call();
                            widget.onSelected(item);
                          },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _SelectOption<T> extends StatelessWidget {
  const _SelectOption({
    required this.item,
    required this.isSelected,
    required this.onPressed,
    this.itemBuilder,
  });

  final BCSelectItem<T> item;
  final bool isSelected;

  /// Null for a disabled row.
  final VoidCallback? onPressed;

  final Widget Function(
    BuildContext context,
    BCSelectItem<T> item,
    bool isSelected,
  )? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final builder = itemBuilder;
    Widget content = builder != null
        ? builder(context, item, isSelected)
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              spacing: 12,
              children: [
                ?item.leading,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: BCTypography.textBase.copyWith(
                          color: bc.foreground,
                          fontWeight: BCTypography.medium,
                        ),
                      ),
                      if (item.description != null)
                        Text(
                          item.description!,
                          style: BCTypography.textSm.copyWith(
                            color: bc.muted,
                            height: 1.375,
                          ),
                        ),
                    ],
                  ),
                ),
                ?item.trailing,
                SizedBox(
                  width: 20,
                  height: 20,
                  child: isSelected
                      ? Icon(Icons.check, size: 18, color: bc.accent)
                      : null,
                ),
              ],
            ),
          );

    if (item.isDisabled) {
      content = Opacity(opacity: bc.opacityDisabled, child: content);
    }

    return BCPressable(
      feedback: BCPressFeedback.highlight,
      shape: BCShapes.continuous(BCRadius.xxl),
      highlightColor: bc.surfaceHover,
      highlightOpacityRange: (0.0, 1.0),
      enabled: !item.isDisabled,
      onPressed: onPressed,
      child: content,
    );
  }
}

/// The wheel presentation: the metrics of the date and time wheels, committed
/// with Done so a stray spin doesn't change the value.
class _BCSelectWheelPanel<T> extends StatefulWidget {
  const _BCSelectWheelPanel({
    required this.items,
    required this.initialIndex,
    required this.onDone,
    this.title,
  });

  final List<BCSelectItem<T>> items;
  final int initialIndex;
  final ValueChanged<BCSelectItem<T>> onDone;
  final String? title;

  @override
  State<_BCSelectWheelPanel<T>> createState() => _BCSelectWheelPanelState<T>();
}

class _BCSelectWheelPanelState<T> extends State<_BCSelectWheelPanel<T>> {
  static const double _itemExtent = 44;

  late final FixedExtentScrollController _wheel =
      FixedExtentScrollController(initialItem: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            BCSpacing.sm,
            0,
            BCSpacing.xs,
            BCSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title ?? '',
                  style: BCTypography.textBase.copyWith(
                    color: bc.foreground,
                    fontWeight: BCTypography.semiBold,
                  ),
                ),
              ),
              BCButton(
                size: BCButtonSize.sm,
                onPressed: () => widget.onDone(widget.items[_index]),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              // Selection band behind the centre row.
              Center(
                child: Container(
                  height: _itemExtent,
                  margin: const EdgeInsets.symmetric(horizontal: BCSpacing.sm),
                  decoration: ShapeDecoration(
                    color: bc.defaultColor,
                    shape: BCShapes.continuous(BCRadius.xl),
                  ),
                ),
              ),
              ListWheelScrollView.useDelegate(
                controller: _wheel,
                itemExtent: _itemExtent,
                perspective: 0.004,
                diameterRatio: 1.8,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) =>
                    setState(() => _index = index),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.items.length,
                  builder: (context, index) {
                    final distance = (index - _index).abs();
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BCSpacing.md,
                        ),
                        child: Text(
                          widget.items[index].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BCTypography.textLg.copyWith(
                            color: distance == 0
                                ? bc.accent
                                // Rows further from the centre recede.
                                : bc.foreground.withValues(
                                    alpha: distance == 1 ? 1 : 0.45,
                                  ),
                            fontWeight: distance == 0
                                ? BCTypography.semiBold
                                : BCTypography.medium,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
