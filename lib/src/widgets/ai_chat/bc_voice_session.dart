import 'dart:math' as math;

import 'package:flutter/material.dart' show Icons, Material;
import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../theme/component_themes/ai_chat_theme.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/bc_duration.dart';
import '../../tokens/bc_radius.dart';
import '../../tokens/bc_shapes.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';
import '../bc_pressable.dart';
import 'bc_voice_controller.dart';

/// The breathing blob at the centre of voice mode.
///
/// It idles with a slow breath, swells with [BCVoiceController.amplitude]
/// while listening, rotates while thinking and pulses faster while speaking.
/// Painted, not animated with widgets, so it stays cheap at 60fps.
class BCVoiceOrb extends StatefulWidget {
  const BCVoiceOrb({
    super.key,
    required this.controller,
    this.size = 180,
    this.color,
    this.reduceMotion,
  });

  final BCVoiceController controller;

  /// Diameter of the orb's resting circle. Overrides the default 180.
  final double size;

  /// Overrides the colour derived from [BCVoiceController.state].
  final Color? color;

  /// Overrides `MediaQuery.disableAnimationsOf`.
  final bool? reduceMotion;

  @override
  State<BCVoiceOrb> createState() => _BCVoiceOrbState();
}

class _BCVoiceOrbState extends State<BCVoiceOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  /// Amplitude is smoothed here rather than in the controller, so a jittery
  /// audio source does not make the orb flicker.
  double _smoothed = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onVoiceChanged);
  }

  @override
  void didUpdateWidget(BCVoiceOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onVoiceChanged);
      widget.controller.addListener(_onVoiceChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still =
        widget.reduceMotion ?? MediaQuery.disableAnimationsOf(context);
    if (still) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat();
    }
  }

  void _onVoiceChanged() {
    final target = widget.controller.amplitude;
    // Rise quickly, fall slowly — the shape a level meter needs to read as
    // responsive without twitching.
    final next = target > _smoothed
        ? _smoothed + (target - _smoothed) * 0.5
        : _smoothed + (target - _smoothed) * 0.12;
    setState(() => _smoothed = next);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVoiceChanged);
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final state = widget.controller.state;
    final color =
        widget.color ?? (state == BCVoiceState.error ? bc.danger : bc.accent);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _breath,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(widget.size),
            painter: _VoiceOrbPainter(
              phase: _breath.value,
              amplitude: _smoothed,
              state: state,
              color: color,
              isMuted: widget.controller.isMuted,
            ),
          );
        },
      ),
    );
  }
}

class _VoiceOrbPainter extends CustomPainter {
  const _VoiceOrbPainter({
    required this.phase,
    required this.amplitude,
    required this.state,
    required this.color,
    required this.isMuted,
  });

  final double phase;
  final double amplitude;
  final BCVoiceState state;
  final Color color;
  final bool isMuted;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = size.width / 2;

    // Each state gets its own breath: idle barely moves, listening tracks the
    // voice, thinking swirls, speaking pulses at roughly a syllable rate.
    final breath = math.sin(phase * 2 * math.pi);
    final (pulse, ringSpread) = switch (state) {
      BCVoiceState.idle => (breath * 0.015, 0.0),
      BCVoiceState.connecting => (breath * 0.03, 0.04),
      BCVoiceState.listening => (amplitude * 0.16 + breath * 0.02, 0.16),
      BCVoiceState.thinking => (breath * 0.04, 0.10),
      BCVoiceState.speaking => (
        math.sin(phase * 6 * math.pi).abs() * 0.07 + 0.02,
        0.12,
      ),
      BCVoiceState.error => (0.0, 0.0),
    };

    final radius = base * (0.62 + pulse);

    // Halo rings, widest first.
    if (ringSpread > 0) {
      for (var ring = 3; ring >= 1; ring--) {
        final t = ring / 3;
        final ringRadius = radius * (1 + ringSpread * t * 1.5);
        canvas.drawCircle(
          center,
          ringRadius,
          Paint()
            ..color = color.withValues(alpha: 0.10 * (1 - t) + 0.04)
            ..style = PaintingStyle.fill,
        );
      }
    }

    // The body: a soft radial gradient rather than a flat disc, so it reads
    // as a light source.
    final bodyRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(color, const Color(0xFFFFFFFF), 0.35)!,
            color,
            color.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.62, 1.0],
          center: const Alignment(-0.25, -0.35),
        ).createShader(bodyRect),
    );

    if (state == BCVoiceState.thinking) {
      // A brighter arc sweeping the rim reads as "working" without needing a
      // separate spinner.
      final sweep = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [
            color.withValues(alpha: 0),
            Color.lerp(color, const Color(0xFFFFFFFF), 0.6)!,
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(phase * 2 * math.pi),
        ).createShader(bodyRect);
      canvas.drawCircle(center, radius + 6, sweep);
    }

    if (isMuted) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = const Color(0x66000000),
      );
    }
  }

  @override
  bool shouldRepaint(_VoiceOrbPainter old) {
    return old.phase != phase ||
        old.amplitude != amplitude ||
        old.state != state ||
        old.color != color ||
        old.isMuted != isMuted;
  }
}

/// A bar-graph level meter fed by [BCVoiceController.amplitude].
///
/// It keeps its own short history, so the bars scroll rather than all moving
/// together.
class BCVoiceWaveform extends StatefulWidget {
  const BCVoiceWaveform({
    super.key,
    required this.controller,
    this.barCount = 32,
    this.height = 44,
    this.barWidth = 3,
    this.spacing = 3,
    this.color,
  });

  final BCVoiceController controller;

  final int barCount;

  final double height;

  final double barWidth;

  final double spacing;

  /// Overrides the default `bc.accent`.
  final Color? color;

  @override
  State<BCVoiceWaveform> createState() => _BCVoiceWaveformState();
}

class _BCVoiceWaveformState extends State<BCVoiceWaveform> {
  late List<double> _levels = List<double>.filled(widget.barCount, 0);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_push);
  }

  @override
  void didUpdateWidget(BCVoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_push);
      widget.controller.addListener(_push);
    }
    if (oldWidget.barCount != widget.barCount) {
      _levels = List<double>.filled(widget.barCount, 0);
    }
  }

  void _push() {
    setState(() {
      _levels = [..._levels.skip(1), widget.controller.amplitude];
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_push);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(
          widget.barCount * (widget.barWidth + widget.spacing),
          widget.height,
        ),
        painter: _WaveformPainter(
          levels: _levels,
          color: widget.color ?? bc.accent,
          barWidth: widget.barWidth,
          spacing: widget.spacing,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.levels,
    required this.color,
    required this.barWidth,
    required this.spacing,
  });

  final List<double> levels;
  final Color color;
  final double barWidth;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final midY = size.height / 2;
    for (var i = 0; i < levels.length; i++) {
      final x = i * (barWidth + spacing);
      // Never fully collapse a bar — a flat line reads as "broken", a row of
      // dots reads as "silent".
      final height = (barWidth + levels[i] * (size.height - barWidth)).clamp(
        barWidth,
        size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, midY - height / 2, barWidth, height),
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.levels != levels || old.color != color;
}

/// The composer's inline microphone, pulsing while the session listens.
class BCMicButton extends StatelessWidget {
  const BCMicButton({
    super.key,
    this.controller,
    this.onPressed,
    this.size = 32,
    this.color,
  });

  /// Drives the listening pulse. Without one the button is a plain icon.
  final BCVoiceController? controller;

  final VoidCallback? onPressed;

  final double size;

  /// Overrides the default `bc.foreground`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final voice = controller;

    Widget icon = Icon(
      voice?.isMuted ?? false ? Icons.mic_off_rounded : Icons.mic_none_rounded,
      size: size * 0.6,
      color: color ?? bc.foreground,
    );

    if (voice != null) {
      icon = ListenableBuilder(
        listenable: voice,
        builder: (context, child) {
          final active = voice.state == BCVoiceState.listening;
          return AnimatedContainer(
            duration: BCDuration.fast,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: active ? bc.accentSoft : null,
              shape: BoxShape.circle,
            ),
            child: Center(child: child),
          );
        },
        child: icon,
      );
    } else {
      icon = SizedBox(
        width: size,
        height: size,
        child: Center(child: icon),
      );
    }

    return Semantics(
      button: true,
      label: 'Voice mode',
      child: BCPressable(
        onPressed: onPressed,
        enabled: onPressed != null,
        feedback: BCPressFeedback.highlight,
        shape: const CircleBorder(),
        child: icon,
      ),
    );
  }
}

/// Full-screen voice mode: the orb, what is being heard, and the controls to
/// mute, go back to typing, or end the call.
///
/// bc_ui draws this and nothing more — no microphone is opened, no audio is
/// played, no permission is asked for. Drive [controller] from your own audio
/// stack.
///
/// Present it with [BCVoiceOverlay.show], which returns when the session is
/// ended:
///
/// ```dart
/// await BCVoiceOverlay.show(
///   context,
///   controller: _voice,
///   onEnd: _stopRecording,
/// );
/// ```
class BCVoiceOverlay extends StatelessWidget {
  const BCVoiceOverlay({
    super.key,
    required this.controller,
    this.onEnd,
    this.onKeyboard,
    this.onMuteToggle,
    this.title,
    this.orbSize = 180,
    this.showWaveform = true,
    this.showTranscript = true,
    this.stateLabelBuilder,
    this.visualizerBuilder,
    this.backgroundColor,
    this.reduceMotion,
  });

  final BCVoiceController controller;

  /// Ends the session. The default pops the route.
  final VoidCallback? onEnd;

  /// Returns to the text composer. The button is hidden when this is null.
  final VoidCallback? onKeyboard;

  /// Overrides the default, which toggles [BCVoiceController.isMuted].
  final VoidCallback? onMuteToggle;

  /// Optional heading above the orb — a model name, an agent name.
  final String? title;

  final double orbSize;

  final bool showWaveform;

  final bool showTranscript;

  /// Replaces the default state caption ("Listening", "Thinking"…).
  final String Function(BCVoiceState)? stateLabelBuilder;

  /// Replaces the orb entirely.
  final Widget Function(BuildContext, BCVoiceController)? visualizerBuilder;

  /// Overrides the default `bc.background`.
  final Color? backgroundColor;

  /// Overrides `MediaQuery.disableAnimationsOf`.
  final bool? reduceMotion;

  /// Presents the overlay as an opaque full-screen route.
  ///
  /// Returns when the session ends — either through the end button or a
  /// system back gesture.
  static Future<void> show(
    BuildContext context, {
    required BCVoiceController controller,
    VoidCallback? onEnd,
    VoidCallback? onKeyboard,
    VoidCallback? onMuteToggle,
    String? title,
    double orbSize = 180,
    bool showWaveform = true,
    bool showTranscript = true,
    String Function(BCVoiceState)? stateLabelBuilder,
    Widget Function(BuildContext, BCVoiceController)? visualizerBuilder,
    Color? backgroundColor,
    bool? reduceMotion,
  }) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        barrierDismissible: false,
        transitionDuration: BCDuration.normal,
        reverseTransitionDuration: BCDuration.fast,
        pageBuilder: (routeContext, animation, secondaryAnimation) {
          return BCVoiceOverlay(
            controller: controller,
            onEnd: () {
              onEnd?.call();
              Navigator.of(routeContext).pop();
            },
            onKeyboard: onKeyboard == null
                ? null
                : () {
                    onKeyboard();
                    Navigator.of(routeContext).pop();
                  },
            onMuteToggle: onMuteToggle,
            title: title,
            orbSize: orbSize,
            showWaveform: showWaveform,
            showTranscript: showTranscript,
            stateLabelBuilder: stateLabelBuilder,
            visualizerBuilder: visualizerBuilder,
            backgroundColor: backgroundColor,
            reduceMotion: reduceMotion,
          );
        },
        transitionsBuilder: (context, animation, secondary, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  static String _defaultLabel(BCVoiceState state) {
    return switch (state) {
      BCVoiceState.idle => 'Tap to start',
      BCVoiceState.connecting => 'Connecting…',
      BCVoiceState.listening => 'Listening',
      BCVoiceState.thinking => 'Thinking',
      BCVoiceState.speaking => 'Speaking',
      BCVoiceState.error => 'Something went wrong',
    };
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    // Material, not a plain ColoredBox: [show] pushes this onto a bare
    // PageRoute, and without a Material ancestor every Text falls back to
    // Flutter's yellow-underline debug style.
    return Material(
      color: backgroundColor ?? bc.background,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => _buildBody(context, bc),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BCThemeExtension bc) {
    final state = controller.state;
    final label =
        controller.errorMessage ?? (stateLabelBuilder ?? _defaultLabel)(state);
    final labelColor = BCAIChatTheme.voiceStateColor(state: state, bc: bc);

    return Column(
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(top: BCSpacing.md),
            child: Text(
              title!,
              style: BCTypography.textSm.copyWith(color: bc.muted),
            ),
          ),
        // Centred, but scrollable: the overlay is normally full-screen, and
        // a short window — a landscape phone, or an embedded preview — must
        // scroll rather than overflow.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: BCSpacing.lg,
              children: [
                visualizerBuilder?.call(context, controller) ??
                    BCVoiceOrb(
                      controller: controller,
                      size: orbSize,
                      reduceMotion: reduceMotion,
                    ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: BCTypography.textLg.copyWith(
                    color: labelColor,
                    fontWeight: BCTypography.medium,
                  ),
                ),
                if (showWaveform && state == BCVoiceState.listening)
                  BCVoiceWaveform(controller: controller),
                if (showTranscript && controller.transcript.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BCSpacing.xl,
                    ),
                    child: Text(
                      controller.transcript,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: BCTypography.textBase.copyWith(
                        color: bc.foreground,
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: BCSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: BCSpacing.lg,
            children: [
              _ControlButton(
                icon: controller.isMuted
                    ? Icons.mic_off_rounded
                    : Icons.mic_none_rounded,
                label: controller.isMuted ? 'Unmute' : 'Mute',
                background: bc.surfaceSecondary,
                foreground: bc.foreground,
                onPressed: onMuteToggle ?? controller.toggleMute,
              ),
              if (onKeyboard != null)
                _ControlButton(
                  icon: Icons.keyboard_alt_outlined,
                  label: 'Back to keyboard',
                  background: bc.surfaceSecondary,
                  foreground: bc.foreground,
                  onPressed: onKeyboard!,
                ),
              _ControlButton(
                icon: Icons.close_rounded,
                label: 'End voice mode',
                background: bc.danger,
                foreground: bc.dangerForeground,
                onPressed: onEnd ?? () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: BCPressable(
        onPressed: onPressed,
        feedback: BCPressFeedback.scaleHighlight,
        shape: BCShapes.continuous(BCRadius.full),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: 24, color: foreground),
        ),
      ),
    );
  }
}
