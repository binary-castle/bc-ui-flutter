import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ToggleButtonShowcaseScreen extends StatefulWidget {
  const ToggleButtonShowcaseScreen({super.key});

  @override
  State<ToggleButtonShowcaseScreen> createState() =>
      _ToggleButtonShowcaseScreenState();
}

class _ToggleButtonShowcaseScreenState
    extends State<ToggleButtonShowcaseScreen> {
  bool _liked = true;
  bool _saved = false;
  bool _likedIcon = true;
  bool _savedIcon = false;
  bool _accent = true;
  bool _ghost = true;
  Set<String> _formats = {'bold'};
  Set<String> _view = {'list'};

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'ToggleButton',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              BCToggleButton(
                isSelected: _liked,
                onSelectedChange: (v) => setState(() => _liked = v),
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite_border),
                label: 'Like',
              ),
              BCToggleButton(
                isSelected: _saved,
                onSelectedChange: (v) => setState(() => _saved = v),
                icon: const Icon(Icons.bookmark_border),
                label: 'Save',
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Icon only',
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              BCToggleButton(
                isSelected: _likedIcon,
                onSelectedChange: (v) => setState(() => _likedIcon = v),
                icon: const Icon(Icons.favorite_border),
                isIconOnly: true,
              ),
              BCToggleButton(
                isSelected: _savedIcon,
                onSelectedChange: (v) => setState(() => _savedIcon = v),
                icon: const Icon(Icons.bookmark_border),
                isIconOnly: true,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Variants',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              BCToggleButton(
                isSelected: _liked,
                onSelectedChange: (v) => setState(() => _liked = v),
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite),
                label: 'Standard',
              ),
              BCToggleButton(
                variant: BCToggleButtonVariant.accent,
                isSelected: _accent,
                onSelectedChange: (v) => setState(() => _accent = v),
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite),
                label: 'Accent',
              ),
              BCToggleButton(
                variant: BCToggleButtonVariant.ghost,
                isSelected: _ghost,
                onSelectedChange: (v) => setState(() => _ghost = v),
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite),
                label: 'Ghost',
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Sizes',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              for (final size in BCToggleButtonSize.values)
                BCToggleButton(
                  size: size,
                  isSelected: true,
                  icon: const Icon(Icons.notifications_none),
                  label: size.name,
                  onSelectedChange: (_) {},
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Group (multi-select)',
          builder: (context) => BCToggleButtonGroup<String>(
            allowMultiple: true,
            isIconOnly: true,
            selectedValues: _formats,
            onSelectionChange: (v) => setState(() => _formats = v),
            options: const [
              BCToggleButtonOption(
                value: 'bold',
                icon: Icon(Icons.format_bold),
              ),
              BCToggleButtonOption(
                value: 'italic',
                icon: Icon(Icons.format_italic),
              ),
              BCToggleButtonOption(
                value: 'underline',
                icon: Icon(Icons.format_underlined),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Group (single-select)',
          builder: (context) => BCToggleButtonGroup<String>(
            allowEmpty: false,
            variant: BCToggleButtonVariant.accent,
            selectedValues: _view,
            onSelectionChange: (v) => setState(() => _view = v),
            options: const [
              BCToggleButtonOption(
                value: 'list',
                icon: Icon(Icons.view_list),
                label: 'List',
              ),
              BCToggleButtonOption(
                value: 'grid',
                icon: Icon(Icons.grid_view),
                label: 'Grid',
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              const BCToggleButton(
                isSelected: true,
                isDisabled: true,
                icon: Icon(Icons.favorite_border),
                label: 'Selected',
              ),
              const BCToggleButton(
                isSelected: false,
                isDisabled: true,
                icon: Icon(Icons.bookmark_border),
                label: 'Unselected',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
