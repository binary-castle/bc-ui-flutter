import 'package:flutter/widgets.dart';

import '../../tokens/bc_radius.dart';
import '../../tokens/bc_shapes.dart';
import '../../tokens/bc_typography.dart';
import '../../widgets/ai_chat/bc_chat_models.dart';
import '../../widgets/ai_chat/bc_voice_controller.dart';
import '../theme_extensions.dart';

/// How an assistant message is drawn.
///
/// [plain] is the reading layout ChatGPT and Claude use — no bubble, no fill,
/// full measure, so long answers read like a document. [surface] puts it in a
/// filled bubble opposite the user's, which suits short back-and-forth.
enum BCChatBubbleVariant { plain, surface }

/// Styling for the AI chat family: bubble fills, agent-step status colours,
/// voice-state colours and the code-block palette.
///
/// Internal to bc_ui. Every value here is derived from [BCThemeExtension], so
/// retheming the app rethemes the chat — there are no chat-specific tokens.
abstract final class BCAIChatTheme {
  /// Corner radius on the three non-tail corners of a bubble.
  static const double bubbleRadius = BCRadius.xxxl;

  /// Corner radius on the tail corner — the bottom corner nearest the
  /// author's side.
  static const double bubbleTailRadius = BCRadius.lg;

  /// Fraction of the available width a filled bubble may occupy.
  static const double maxWidthFactor = 0.78;

  static Color bubbleBackground({
    required BCChatRole role,
    required BCChatBubbleVariant variant,
    required BCThemeExtension bc,
  }) {
    return switch (role) {
      BCChatRole.user => bc.accent,
      BCChatRole.assistant => switch (variant) {
        BCChatBubbleVariant.plain => const Color(0x00000000),
        BCChatBubbleVariant.surface => bc.surfaceSecondary,
      },
      BCChatRole.system => bc.defaultSoft,
    };
  }

  static Color bubbleForeground({
    required BCChatRole role,
    required BCChatBubbleVariant variant,
    required BCThemeExtension bc,
  }) {
    return switch (role) {
      BCChatRole.user => bc.accentForeground,
      BCChatRole.assistant => switch (variant) {
        BCChatBubbleVariant.plain => bc.foreground,
        BCChatBubbleVariant.surface => bc.surfaceSecondaryForeground,
      },
      BCChatRole.system => bc.defaultSoftForeground,
    };
  }

  /// Asymmetric bubble shape — the tail corner is squared off towards the
  /// author's side. [isMine] is true for the side the message is aligned to.
  static ShapeBorder bubbleShape({
    required bool isMine,
    required TextDirection direction,
  }) {
    const full = Radius.circular(bubbleRadius);
    const tail = Radius.circular(bubbleTailRadius);
    final tailOnRight = direction == TextDirection.ltr ? isMine : !isMine;
    return BCShapes.continuousFrom(
      BorderRadius.only(
        topLeft: full,
        topRight: full,
        bottomLeft: tailOnRight ? full : tail,
        bottomRight: tailOnRight ? tail : full,
      ),
    );
  }

  /// The colour of a step's status dot, spinner or icon.
  static Color stepColor({
    required BCAgentStepStatus status,
    required BCThemeExtension bc,
  }) {
    return switch (status) {
      BCAgentStepStatus.pending => bc.muted,
      BCAgentStepStatus.running => bc.accent,
      BCAgentStepStatus.success => bc.success,
      BCAgentStepStatus.error => bc.danger,
      BCAgentStepStatus.skipped => bc.muted,
    };
  }

  /// The colour of the voice state label, and of the orb outside its
  /// resting accent.
  static Color voiceStateColor({
    required BCVoiceState state,
    required BCThemeExtension bc,
  }) {
    return switch (state) {
      BCVoiceState.idle => bc.muted,
      BCVoiceState.connecting => bc.muted,
      BCVoiceState.listening => bc.accent,
      BCVoiceState.thinking => bc.accent,
      BCVoiceState.speaking => bc.success,
      BCVoiceState.error => bc.danger,
    };
  }

  static Color codeBlockBackground(BCThemeExtension bc) => bc.surfaceSecondary;

  static Color codeBlockForeground(BCThemeExtension bc) =>
      bc.surfaceSecondaryForeground;

  /// Inline `code` and fenced-block text. Falls back through the usual
  /// monospace families rather than bundling a font — bc_ui ships Inter only.
  static TextStyle monospace(Color color, {double? fontSize}) {
    return BCTypography.textSm.copyWith(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier New'],
      fontSize: fontSize,
      color: color,
      height: 1.45,
    );
  }
}
