import 'package:flutter/foundation.dart';

/// Where a voice session is in its cycle.
///
/// The sequence a full turn walks is
/// [connecting] → [listening] → [thinking] → [speaking] → [listening].
enum BCVoiceState { idle, connecting, listening, thinking, speaking, error }

/// Drives the voice UI: the orb's motion, the waveform's bars, the state
/// label and the live transcript.
///
/// bc_ui captures no audio and recognises no speech — there is no microphone
/// plugin behind this and no permission is requested. You run whatever audio
/// stack you like and push what it reports in here; the widgets only draw it.
///
/// ```dart
/// final _voice = BCVoiceController();
///
/// void _onSessionStart() {
///   _voice.state = BCVoiceState.listening;
///   _amplitudes = recorder.onAmplitudeChanged.listen((a) {
///     _voice.amplitude = a.current.clamp(0, 1);
///   });
/// }
///
/// @override
/// void dispose() {
///   _amplitudes.cancel();
///   _voice.dispose();
///   super.dispose();
/// }
/// ```
///
/// [amplitude] is expected at roughly 30–60Hz; the waveform smooths it, so
/// there is no need to filter it yourself first.
class BCVoiceController extends ChangeNotifier {
  // The parameters cannot be initializing formals: the public names are
  // `state`/`transcript`/`isMuted`, while the fields behind them are private
  // so that each can have a notifying setter.
  // ignore_for_file: prefer_initializing_formals
  BCVoiceController({
    BCVoiceState state = BCVoiceState.idle,
    String transcript = '',
    bool isMuted = false,
  }) : _state = state,
       _transcript = transcript,
       _isMuted = isMuted;

  BCVoiceState _state;
  double _amplitude = 0;
  String _transcript;
  bool _isMuted;
  String? _errorMessage;

  BCVoiceState get state => _state;

  set state(BCVoiceState value) {
    if (_state == value) return;
    _state = value;
    if (value != BCVoiceState.error) _errorMessage = null;
    notifyListeners();
  }

  /// Current input level, 0–1. Values outside that range are clamped rather
  /// than asserted, since audio backends differ on their ceiling.
  double get amplitude => _amplitude;

  set amplitude(double value) {
    final next = value.clamp(0.0, 1.0);
    if (_amplitude == next) return;
    _amplitude = next;
    notifyListeners();
  }

  /// What has been heard so far this turn, shown under the orb.
  String get transcript => _transcript;

  set transcript(String value) {
    if (_transcript == value) return;
    _transcript = value;
    notifyListeners();
  }

  /// Whether the mic is muted. bc_ui only draws the state — muting the actual
  /// input is yours.
  bool get isMuted => _isMuted;

  set isMuted(bool value) {
    if (_isMuted == value) return;
    _isMuted = value;
    notifyListeners();
  }

  /// Shown in place of the state label while [state] is [BCVoiceState.error].
  String? get errorMessage => _errorMessage;

  /// Moves to [BCVoiceState.error] and sets the message in one notification.
  void fail(String message) {
    if (_state == BCVoiceState.error && _errorMessage == message) return;
    _state = BCVoiceState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void toggleMute() => isMuted = !isMuted;

  /// Back to a resting session: idle, silent, no transcript, unmuted.
  void reset() {
    final unchanged =
        _state == BCVoiceState.idle &&
        _amplitude == 0 &&
        _transcript.isEmpty &&
        !_isMuted &&
        _errorMessage == null;
    if (unchanged) return;
    _state = BCVoiceState.idle;
    _amplitude = 0;
    _transcript = '';
    _isMuted = false;
    _errorMessage = null;
    notifyListeners();
  }
}
