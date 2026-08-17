import 'package:flutter/widgets.dart';

import '../../tokens/bc_spacing.dart';
import '../bc_chip.dart';

/// One starter prompt offered on an empty thread.
@immutable
class BCChatSuggestion {
  const BCChatSuggestion({required this.label, this.prompt, this.icon});

  /// What the user reads on the pill.
  final String label;

  /// What to actually send. Defaults to [label] — set it when the pill reads
  /// as a short title but should expand into a fuller prompt.
  final String? prompt;

  /// Optional leading icon.
  final Widget? icon;

  /// The text this suggestion sends.
  String get text => prompt ?? label;
}

/// A wrapping row of starter prompts.
///
/// ```dart
/// BCChatSuggestions(
///   suggestions: const [
///     BCChatSuggestion(label: 'Summarise my inbox'),
///     BCChatSuggestion(label: 'Plan a sprint'),
///   ],
///   onSelected: (s) => _send(s.text),
/// );
/// ```
class BCChatSuggestions extends StatelessWidget {
  const BCChatSuggestions({
    super.key,
    required this.suggestions,
    required this.onSelected,
    this.variant = BCChipVariant.secondary,
    this.size = BCChipSize.md,
    this.alignment = WrapAlignment.center,
    this.spacing = BCSpacing.sm,
    this.runSpacing = BCSpacing.sm,
  });

  final List<BCChatSuggestion> suggestions;

  final ValueChanged<BCChatSuggestion> onSelected;

  final BCChipVariant variant;

  final BCChipSize size;

  final WrapAlignment alignment;

  final double spacing;

  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final suggestion in suggestions)
          BCChip(
            variant: variant,
            size: size,
            startContent: suggestion.icon,
            onPressed: () => onSelected(suggestion),
            child: Text(suggestion.label),
          ),
      ],
    );
  }
}
