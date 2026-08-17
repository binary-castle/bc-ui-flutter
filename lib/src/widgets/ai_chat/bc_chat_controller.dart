import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show TextEditingController;

import 'bc_chat_models.dart';

/// Owns a thread's messages and whether the agent is currently working.
///
/// Create one in a [State] and dispose it there:
///
/// ```dart
/// final _chat = BCChatController(messages: [
///   const BCChatMessage(id: '1', role: BCChatRole.assistant, text: 'Hi!'),
/// ]);
///
/// @override
/// void dispose() {
///   _chat.dispose();
///   super.dispose();
/// }
/// ```
///
/// Streaming a reply is three calls — open the message, push chunks as they
/// arrive, close it:
///
/// ```dart
/// _chat.add(const BCChatMessage(
///   id: 'reply',
///   role: BCChatRole.assistant,
///   status: BCChatMessageStatus.streaming,
/// ));
/// await for (final chunk in response) {
///   _chat.appendChunk('reply', chunk);
/// }
/// _chat.finish('reply');
/// ```
///
/// [isGenerating] is set for you by [appendChunk] and cleared by [finish] and
/// [fail], so the composer's send button becomes a stop button on its own.
class BCChatController extends ChangeNotifier {
  BCChatController({List<BCChatMessage> messages = const <BCChatMessage>[]})
    : _messages = List<BCChatMessage>.of(messages);

  List<BCChatMessage> _messages;
  bool _isGenerating = false;

  /// The thread, oldest first. The view returned here is unmodifiable, so
  /// mutating it in place is not an option — use the methods below or assign
  /// a new list to [messages].
  List<BCChatMessage> get messages =>
      UnmodifiableListView<BCChatMessage>(_messages);

  set messages(List<BCChatMessage> next) {
    if (listEquals(_messages, next)) return;
    _messages = List<BCChatMessage>.of(next);
    notifyListeners();
  }

  /// Whether the agent is mid-turn. Drives the composer's send↔stop morph.
  ///
  /// Set automatically by [appendChunk]/[finish]/[fail]; assign it yourself
  /// for the gap between hitting send and the first token arriving.
  bool get isGenerating => _isGenerating;

  set isGenerating(bool value) {
    if (_isGenerating == value) return;
    _isGenerating = value;
    notifyListeners();
  }

  /// The last message, or null on an empty thread.
  BCChatMessage? get last => _messages.isEmpty ? null : _messages.last;

  /// The message with this id, or null if the thread has no such message.
  BCChatMessage? byId(String id) {
    for (final message in _messages) {
      if (message.id == id) return message;
    }
    return null;
  }

  /// Appends a message to the end of the thread.
  void add(BCChatMessage message) {
    _messages = [..._messages, message];
    notifyListeners();
  }

  /// Appends several messages in one notification.
  void addAll(Iterable<BCChatMessage> messages) {
    final incoming = List<BCChatMessage>.of(messages);
    if (incoming.isEmpty) return;
    _messages = [..._messages, ...incoming];
    notifyListeners();
  }

  /// Inserts at [index], for prepending loaded history.
  void insert(int index, BCChatMessage message) {
    _messages = [..._messages]..insert(index, message);
    notifyListeners();
  }

  /// Drops the message with this id. A no-op if there is no such message.
  void remove(String id) {
    final next = _messages.where((message) => message.id != id).toList();
    if (next.length == _messages.length) return;
    _messages = next;
    notifyListeners();
  }

  /// Replaces one message with the result of [transform].
  ///
  /// A no-op if there is no such message, or if [transform] returns something
  /// equal to what was already there.
  void update(String id, BCChatMessage Function(BCChatMessage) transform) {
    final index = _messages.indexWhere((message) => message.id == id);
    if (index == -1) return;
    final next = transform(_messages[index]);
    if (next == _messages[index]) return;
    _messages = [..._messages]..[index] = next;
    notifyListeners();
  }

  /// Adds [chunk] to the end of a message's text and marks it streaming.
  ///
  /// This is the streaming primitive: call it once per token, or once per
  /// buffered batch of them. Empty chunks are dropped rather than causing a
  /// pointless rebuild.
  void appendChunk(String id, String chunk) {
    if (chunk.isEmpty) return;
    final index = _messages.indexWhere((message) => message.id == id);
    if (index == -1) return;
    final current = _messages[index];
    _messages = [..._messages]
      ..[index] = current.copyWith(
        text: current.text + chunk,
        status: BCChatMessageStatus.streaming,
      );
    _isGenerating = true;
    notifyListeners();
  }

  /// Replaces a message's agent steps — call it as tool calls start and
  /// finish.
  void updateSteps(String id, List<BCAgentStep> steps) {
    update(id, (message) => message.copyWith(steps: steps));
  }

  /// Closes out a streaming message and clears [isGenerating].
  void finish(String id) {
    final index = _messages.indexWhere((message) => message.id == id);
    if (index != -1) {
      final current = _messages[index];
      if (current.status != BCChatMessageStatus.complete) {
        _messages = [..._messages]
          ..[index] = current.copyWith(status: BCChatMessageStatus.complete);
      }
    }
    _isGenerating = false;
    notifyListeners();
  }

  /// Marks a message failed with a message to show in place of its body, and
  /// clears [isGenerating].
  void fail(String id, String error) {
    final index = _messages.indexWhere((message) => message.id == id);
    if (index != -1) {
      _messages = [..._messages]
        ..[index] = _messages[index].copyWith(
          status: BCChatMessageStatus.failed,
          error: error,
        );
    }
    _isGenerating = false;
    notifyListeners();
  }

  /// Empties the thread and clears [isGenerating].
  void clear() {
    if (_messages.isEmpty && !_isGenerating) return;
    _messages = <BCChatMessage>[];
    _isGenerating = false;
    notifyListeners();
  }
}

/// Owns what the composer is holding — the draft text and the attachments
/// staged alongside it.
///
/// It wraps a [TextEditingController]. Pass your own if you already have one;
/// otherwise one is created here and disposed with the controller, so the
/// ownership rule is "whoever made it disposes it".
///
/// ```dart
/// final _composer = BCChatComposerController();
///
/// @override
/// void dispose() {
///   _composer.dispose();
///   super.dispose();
/// }
/// ```
///
/// You do the file picking. When your picker returns, describe what it gave
/// you with [BCChatAttachment]s and hand them over:
///
/// ```dart
/// _composer.addAttachments([
///   BCChatAttachment(
///     id: file.path,
///     name: file.name,
///     kind: BCChatAttachmentKind.image,
///     thumbnail: FileImage(File(file.path)),
///     status: BCChatAttachmentStatus.uploading,
///     progress: 0,
///   ),
/// ]);
/// ```
///
/// then walk `progress` up with [updateAttachment] as your upload reports in.
class BCChatComposerController extends ChangeNotifier {
  BCChatComposerController({
    TextEditingController? textController,
    String? initialText,
    List<BCChatAttachment> attachments = const <BCChatAttachment>[],
  }) : _ownsTextController = textController == null,
       text = textController ?? TextEditingController(text: initialText),
       _attachments = List<BCChatAttachment>.of(attachments) {
    text.addListener(notifyListeners);
  }

  /// The draft text. Exposed so you can pass it to your own field if you
  /// replace the composer wholesale.
  final TextEditingController text;

  final bool _ownsTextController;
  List<BCChatAttachment> _attachments;

  /// The staged attachments. Unmodifiable — use the methods below.
  List<BCChatAttachment> get attachments =>
      UnmodifiableListView<BCChatAttachment>(_attachments);

  /// Whether there is anything worth sending: some text, or at least one
  /// attachment that finished uploading. An upload still in flight does not
  /// count, so send stays disabled until it lands.
  bool get canSend =>
      text.text.trim().isNotEmpty ||
      _attachments.any((a) => a.status == BCChatAttachmentStatus.ready);

  /// Whether any attachment is still uploading.
  bool get isUploading =>
      _attachments.any((a) => a.status == BCChatAttachmentStatus.uploading);

  void addAttachments(Iterable<BCChatAttachment> incoming) {
    final list = List<BCChatAttachment>.of(incoming);
    if (list.isEmpty) return;
    _attachments = [..._attachments, ...list];
    notifyListeners();
  }

  void removeAttachment(String id) {
    final next = _attachments.where((a) => a.id != id).toList();
    if (next.length == _attachments.length) return;
    _attachments = next;
    notifyListeners();
  }

  /// Replaces one attachment with the result of [transform] — how upload
  /// progress and failures get reported.
  void updateAttachment(
    String id,
    BCChatAttachment Function(BCChatAttachment) transform,
  ) {
    final index = _attachments.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final next = transform(_attachments[index]);
    if (next == _attachments[index]) return;
    _attachments = [..._attachments]..[index] = next;
    notifyListeners();
  }

  void clearAttachments() {
    if (_attachments.isEmpty) return;
    _attachments = <BCChatAttachment>[];
    notifyListeners();
  }

  /// Clears the draft and the attachments — what to call once a send has
  /// been handed off.
  void reset() {
    final hadAttachments = _attachments.isNotEmpty;
    _attachments = <BCChatAttachment>[];
    if (text.text.isEmpty) {
      if (hadAttachments) notifyListeners();
      return;
    }
    // Clearing the text controller notifies through the listener installed
    // in the constructor, so this covers both halves.
    text.clear();
  }

  @override
  void dispose() {
    text.removeListener(notifyListeners);
    if (_ownsTextController) text.dispose();
    super.dispose();
  }
}
