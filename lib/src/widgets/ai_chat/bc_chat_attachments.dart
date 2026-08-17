import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/bc_duration.dart';
import '../../tokens/bc_radius.dart';
import '../../tokens/bc_shapes.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';
import '../bc_pressable.dart';
import 'bc_chat_models.dart';

/// One staged or sent file.
///
/// Images render as a square thumbnail tile; everything else renders as an
/// icon-and-name row. While the attachment is uploading a progress bar runs
/// along the bottom, and a failure turns the border red and swaps the
/// subtitle for the error.
class BCChatAttachmentChip extends StatelessWidget {
  const BCChatAttachmentChip({
    super.key,
    required this.attachment,
    this.onRemove,
    this.onPressed,
    this.size = 56,
    this.fileWidth = 220,
    this.backgroundColor,
    this.borderRadius,
  });

  final BCChatAttachment attachment;

  /// Shows the remove badge when set. Leave it null on a sent message, where
  /// there is nothing left to remove.
  final ValueChanged<BCChatAttachment>? onRemove;

  /// Tap-through, for opening a preview.
  final ValueChanged<BCChatAttachment>? onPressed;

  /// Edge length of an image tile, and the height of a file row. Overrides
  /// the default 56.
  final double size;

  /// Width of a non-image chip. Overrides the default 220.
  final double fileWidth;

  /// Overrides the default `bc.surfaceSecondary`.
  final Color? backgroundColor;

  /// Overrides the default [BCRadius.xl].
  final double? borderRadius;

  bool get _isImage =>
      attachment.kind == BCChatAttachmentKind.image &&
      attachment.thumbnail != null;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final failed = attachment.status == BCChatAttachmentStatus.failed;
    final radius = borderRadius ?? BCRadius.xl;

    Widget body = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: backgroundColor ?? bc.surfaceSecondary,
        shape: BCShapes.continuous(
          radius,
          side: failed ? BorderSide(color: bc.danger) : BorderSide.none,
        ),
      ),
      child: _isImage ? _imageTile(context, bc) : _fileRow(context, bc),
    );

    if (onPressed != null) {
      body = BCPressable(
        onPressed: () => onPressed!(attachment),
        feedback: BCPressFeedback.scale,
        shape: BCShapes.continuous(radius),
        child: body,
      );
    }

    if (onRemove == null) return body;

    // The badge overhangs the tile, so the stack cannot clip.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(padding: const EdgeInsets.only(top: 6, right: 6), child: body),
        PositionedDirectional(
          top: 0,
          end: 0,
          child: Semantics(
            button: true,
            label: 'Remove ${attachment.name}',
            child: BCPressable(
              onPressed: () => onRemove!(attachment),
              feedback: BCPressFeedback.scale,
              shape: const CircleBorder(),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: bc.backgroundInverse,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: bc.background,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageTile(BuildContext context, BCThemeExtension bc) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: attachment.thumbnail!, fit: BoxFit.cover),
          if (attachment.status == BCChatAttachmentStatus.uploading)
            Container(
              color: bc.backdrop,
              alignment: Alignment.center,
              child: Text(
                attachment.progress == null
                    ? '…'
                    : '${(attachment.progress! * 100).round()}%',
                style: BCTypography.textXs.copyWith(color: bc.dangerForeground),
              ),
            ),
          if (attachment.status == BCChatAttachmentStatus.failed)
            Container(
              color: bc.backdrop,
              alignment: Alignment.center,
              child: Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: bc.dangerForeground,
              ),
            ),
        ],
      ),
    );
  }

  Widget _fileRow(BuildContext context, BCThemeExtension bc) {
    final subtitle = attachment.status == BCChatAttachmentStatus.failed
        ? (attachment.error ?? 'Upload failed')
        : _describe(attachment);

    // A definite width, not an intrinsic one: the strip scrolls horizontally,
    // so the chip is offered unbounded width and the progress bar's fraction
    // would have nothing to resolve against.
    return SizedBox(
      width: fileWidth,
      height: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: BCSpacing.sm,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: ShapeDecoration(
                      color: bc.background,
                      shape: BCShapes.continuous(BCRadius.md),
                    ),
                    child: Icon(
                      _iconFor(attachment.kind),
                      size: 16,
                      color: bc.muted,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          attachment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BCTypography.textSm.copyWith(
                            color: bc.foreground,
                            fontWeight: BCTypography.medium,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BCTypography.textXs.copyWith(
                              color:
                                  attachment.status ==
                                      BCChatAttachmentStatus.failed
                                  ? bc.danger
                                  : bc.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (attachment.status == BCChatAttachmentStatus.uploading)
            _progressBar(bc),
        ],
      ),
    );
  }

  Widget _progressBar(BCThemeExtension bc) {
    return SizedBox(
      height: 3,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: bc.border)),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: (attachment.progress ?? 0).clamp(0.0, 1.0),
            child: ColoredBox(color: bc.accent),
          ),
        ],
      ),
    );
  }

  static String? _describe(BCChatAttachment attachment) {
    if (attachment.status == BCChatAttachmentStatus.uploading) {
      final progress = attachment.progress;
      return progress == null
          ? 'Uploading…'
          : 'Uploading ${(progress * 100).round()}%';
    }
    final bytes = attachment.sizeBytes;
    if (bytes == null) return null;
    return formatBytes(bytes);
  }

  /// Renders a byte count the way a file manager would.
  ///
  /// Visible for testing.
  @visibleForTesting
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    const units = ['KB', 'MB', 'GB', 'TB'];
    var value = bytes / 1024;
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final rounded = value >= 10
        ? value.round().toString()
        : value.toStringAsFixed(1);
    return '$rounded ${units[unit]}';
  }

  static IconData _iconFor(BCChatAttachmentKind kind) {
    return switch (kind) {
      BCChatAttachmentKind.image => Icons.image_outlined,
      BCChatAttachmentKind.video => Icons.movie_outlined,
      BCChatAttachmentKind.audio => Icons.graphic_eq_rounded,
      BCChatAttachmentKind.document => Icons.description_outlined,
      BCChatAttachmentKind.code => Icons.code_rounded,
      BCChatAttachmentKind.archive => Icons.folder_zip_outlined,
      BCChatAttachmentKind.other => Icons.attach_file_rounded,
    };
  }
}

/// The horizontal run of attachment chips — above the composer while staging,
/// inside the bubble once sent.
class BCChatAttachmentStrip extends StatelessWidget {
  const BCChatAttachmentStrip({
    super.key,
    required this.attachments,
    this.onRemove,
    this.onPressed,
    this.isEditable = true,
    this.chipBuilder,
    this.spacing = BCSpacing.sm,
    this.padding,
  });

  final List<BCChatAttachment> attachments;

  final ValueChanged<BCChatAttachment>? onRemove;

  final ValueChanged<BCChatAttachment>? onPressed;

  /// Whether chips carry a remove badge. False on a sent message.
  final bool isEditable;

  /// Wraps or replaces each chip.
  final Widget Function(BuildContext, BCChatAttachment, Widget)? chipBuilder;

  final double spacing;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: spacing,
        children: [
          for (final attachment in attachments)
            Builder(
              builder: (context) {
                final chip = BCChatAttachmentChip(
                  attachment: attachment,
                  onRemove: isEditable ? onRemove : null,
                  onPressed: onPressed,
                );
                return chipBuilder?.call(context, attachment, chip) ?? chip;
              },
            ),
        ],
      ),
    );
  }
}

/// A drop affordance for the composer: a dashed accent border and a label
/// that fade in while a drag is over it.
///
/// Flutter has no built-in desktop file drop, and bc_ui takes no dependency to
/// add one. You wire up whatever drag plugin you use — `super_drag_and_drop`,
/// `desktop_drop` — and drive [isActive] from its hover callbacks; this only
/// draws the state.
///
/// ```dart
/// DropTarget(
///   onDragEntered: (_) => setState(() => _dragging = true),
///   onDragExited: (_) => setState(() => _dragging = false),
///   onDragDone: (detail) => _stage(detail.files),
///   child: BCChatDropTarget(
///     isActive: _dragging,
///     child: BCChatComposer(controller: _composer, onSend: _send),
///   ),
/// );
/// ```
class BCChatDropTarget extends StatelessWidget {
  const BCChatDropTarget({
    super.key,
    required this.isActive,
    required this.child,
    this.label = 'Drop files to attach',
    this.overlay,
    this.borderRadius,
  });

  /// Whether a drag is currently over the target.
  final bool isActive;

  final Widget child;

  /// Text shown over the child while [isActive]. Ignored when [overlay] is
  /// set.
  final String label;

  /// Replaces the whole default overlay.
  final Widget? overlay;

  /// Overrides the default [BCRadius.xxl].
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final radius = borderRadius ?? BCRadius.xxl;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: isActive ? 1 : 0,
              duration: BCDuration.fast,
              child:
                  overlay ??
                  Container(
                    decoration: ShapeDecoration(
                      color: bc.accentSoft,
                      shape: BCShapes.continuous(
                        radius,
                        side: BorderSide(color: bc.accent, width: 2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: BCSpacing.sm,
                      children: [
                        Icon(
                          Icons.file_download_outlined,
                          size: 18,
                          color: bc.accentSoftForeground,
                        ),
                        Text(
                          label,
                          style: BCTypography.textSm.copyWith(
                            color: bc.accentSoftForeground,
                            fontWeight: BCTypography.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
