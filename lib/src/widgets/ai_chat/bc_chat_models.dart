import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show IconData, ImageProvider;

/// Who authored a [BCChatMessage].
///
/// [system] messages are rendered as a centred notice rather than a bubble —
/// use them for "model switched to …" or a moderation notice, not for the
/// system prompt itself.
enum BCChatRole { user, assistant, system }

/// Where a [BCChatMessage] is in its lifecycle.
///
/// [pending] is a user message whose send has not been acknowledged yet;
/// [streaming] is an assistant message still being written into. Both the
/// typing indicator and the streaming caret key off these, so keep them
/// accurate while tokens arrive.
enum BCChatMessageStatus { pending, streaming, complete, failed }

/// What kind of file a [BCChatAttachment] points at.
///
/// This only picks the chip layout and the fallback icon — images get a
/// thumbnail tile, everything else gets an icon-and-name row. It is not a
/// content-type check; set it from your own MIME sniffing.
enum BCChatAttachmentKind {
  image,
  video,
  audio,
  document,
  code,
  archive,
  other,
}

/// How far along a [BCChatAttachment] is.
///
/// Only [ready] attachments count towards
/// [BCChatComposerController.canSend], so an upload in flight cannot be sent
/// by accident.
enum BCChatAttachmentStatus { pending, uploading, ready, failed }

/// How a [BCAgentStep] ended, or that it has not ended.
enum BCAgentStepStatus { pending, running, success, error, skipped }

/// A file riding along with a message.
///
/// bc_ui never touches the filesystem: there are no bytes and no path here.
/// You pick the file, you upload it, and you describe the result with one of
/// these. [thumbnail] is any [ImageProvider], so a memory image, a file image
/// or a network URL all work.
///
/// ```dart
/// BCChatAttachment(
///   id: 'a1',
///   name: 'receipt.png',
///   kind: BCChatAttachmentKind.image,
///   sizeBytes: 84213,
///   thumbnail: FileImage(file),
///   status: BCChatAttachmentStatus.uploading,
///   progress: 0.4,
/// );
/// ```
@immutable
class BCChatAttachment {
  const BCChatAttachment({
    required this.id,
    required this.name,
    this.kind = BCChatAttachmentKind.other,
    this.sizeBytes,
    this.thumbnail,
    this.status = BCChatAttachmentStatus.ready,
    this.progress,
    this.error,
    this.metadata,
  }) : assert(
         progress == null || (progress >= 0 && progress <= 1),
         'BCChatAttachment.progress must be between 0 and 1',
       );

  /// Stable identity. Removing and updating an attachment both match on this.
  final String id;

  /// The filename shown on the chip.
  final String name;

  final BCChatAttachmentKind kind;

  /// Size in bytes, rendered as a human-readable subtitle when present.
  final int? sizeBytes;

  /// Preview image for [BCChatAttachmentKind.image]. Without one the chip
  /// falls back to the kind's icon.
  final ImageProvider? thumbnail;

  final BCChatAttachmentStatus status;

  /// Upload progress 0–1. Null renders an indeterminate bar while
  /// [status] is [BCChatAttachmentStatus.uploading].
  final double? progress;

  /// Shown on the chip when [status] is [BCChatAttachmentStatus.failed].
  final String? error;

  /// Anything your app needs to carry along; bc_ui ignores it.
  final Map<String, Object?>? metadata;

  BCChatAttachment copyWith({
    String? id,
    String? name,
    BCChatAttachmentKind? kind,
    int? sizeBytes,
    ImageProvider? thumbnail,
    BCChatAttachmentStatus? status,
    double? progress,
    String? error,
    Map<String, Object?>? metadata,
  }) {
    return BCChatAttachment(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      thumbnail: thumbnail ?? this.thumbnail,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BCChatAttachment &&
        other.id == id &&
        other.name == name &&
        other.kind == kind &&
        other.sizeBytes == sizeBytes &&
        other.thumbnail == thumbnail &&
        other.status == status &&
        other.progress == progress &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    sizeBytes,
    thumbnail,
    status,
    progress,
    error,
  );
}

/// One thing the agent did on the user's behalf — a tool call, a search, a
/// file edit — rendered as a row in a [BCAgentStepList].
///
/// [children] nests one level, for a step that fans out into sub-calls.
/// Deeper nesting renders flat.
@immutable
class BCAgentStep {
  const BCAgentStep({
    required this.id,
    required this.label,
    this.detail,
    this.icon,
    this.status = BCAgentStepStatus.pending,
    this.duration,
    this.output,
    this.children = const <BCAgentStep>[],
  });

  /// Stable identity, used to keep expansion state across rebuilds.
  final String id;

  /// The headline — "Searched the web", "Edited bc_input.dart".
  final String label;

  /// A dimmer second line: the query, the path, the argument.
  final String? detail;

  /// Overrides the icon derived from [status].
  final IconData? icon;

  final BCAgentStepStatus status;

  /// How long the step took, shown right-aligned once it is set.
  final Duration? duration;

  /// Tool output, rendered in a monospace pane when the step is expanded.
  final String? output;

  final List<BCAgentStep> children;

  /// Whether this step, or anything beneath it, is still running.
  bool get isActive =>
      status == BCAgentStepStatus.running ||
      children.any((child) => child.isActive);

  BCAgentStep copyWith({
    String? id,
    String? label,
    String? detail,
    IconData? icon,
    BCAgentStepStatus? status,
    Duration? duration,
    String? output,
    List<BCAgentStep>? children,
  }) {
    return BCAgentStep(
      id: id ?? this.id,
      label: label ?? this.label,
      detail: detail ?? this.detail,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      output: output ?? this.output,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BCAgentStep &&
        other.id == id &&
        other.label == label &&
        other.detail == detail &&
        other.icon == icon &&
        other.status == status &&
        other.duration == duration &&
        other.output == output &&
        listEquals(other.children, children);
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    detail,
    icon,
    status,
    duration,
    output,
    Object.hashAll(children),
  );
}

/// One turn in the conversation.
///
/// Immutable: streaming works by replacing the message with a copy carrying
/// more text, which is what [BCChatController.appendChunk] does for you.
///
/// ```dart
/// const BCChatMessage(
///   id: 'm1',
///   role: BCChatRole.user,
///   text: 'Summarise this quarter’s churn.',
/// );
/// ```
@immutable
class BCChatMessage {
  const BCChatMessage({
    required this.id,
    required this.role,
    this.text = '',
    this.status = BCChatMessageStatus.complete,
    this.createdAt,
    this.attachments = const <BCChatAttachment>[],
    this.steps = const <BCAgentStep>[],
    this.error,
    this.metadata,
  });

  /// Stable identity. Every controller method that targets a message
  /// matches on this, so it has to be unique within the thread.
  final String id;

  final BCChatRole role;

  /// The body. Rendered as markdown by default — see `BCChatMarkdown`.
  final String text;

  final BCChatMessageStatus status;

  /// Drives the date separators in a `BCChatThread`. Null messages are
  /// grouped under whichever separator precedes them.
  final DateTime? createdAt;

  final List<BCChatAttachment> attachments;

  /// The agent's tool calls for this turn, shown above [text].
  final List<BCAgentStep> steps;

  /// Shown in place of the body when [status] is
  /// [BCChatMessageStatus.failed].
  final String? error;

  /// Anything your app needs to carry along; bc_ui ignores it.
  final Map<String, Object?>? metadata;

  /// Whether the message is still being written into.
  bool get isStreaming => status == BCChatMessageStatus.streaming;

  /// Whether there is nothing to render in the body yet — the case the
  /// typing indicator covers.
  bool get isEmpty => text.trim().isEmpty && attachments.isEmpty;

  BCChatMessage copyWith({
    String? id,
    BCChatRole? role,
    String? text,
    BCChatMessageStatus? status,
    DateTime? createdAt,
    List<BCChatAttachment>? attachments,
    List<BCAgentStep>? steps,
    String? error,
    Map<String, Object?>? metadata,
  }) {
    return BCChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
      steps: steps ?? this.steps,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BCChatMessage &&
        other.id == id &&
        other.role == role &&
        other.text == text &&
        other.status == status &&
        other.createdAt == createdAt &&
        listEquals(other.attachments, attachments) &&
        listEquals(other.steps, steps) &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
    id,
    role,
    text,
    status,
    createdAt,
    Object.hashAll(attachments),
    Object.hashAll(steps),
    error,
  );
}
