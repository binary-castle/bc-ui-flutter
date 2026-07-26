/// HeroUI Native radius scale — all multiples of the 8px base radius
/// (`--radius: 0.5rem` in heroui-native/src/styles/variables.css).
abstract final class BCRadius {
  static const double none = 0;

  /// `--radius` base value.
  static const double base = 8;

  static const double xs = 2; // base * 0.25
  static const double sm = 4; // base * 0.5
  static const double md = 6; // base * 0.75
  static const double lg = 8; // base * 1
  static const double xl = 12; // base * 1.5
  static const double xxl = 16; // base * 2
  static const double xxxl = 24; // base * 3
  static const double xxxxl = 32; // base * 4

  /// `--field-radius` = base * 1.75, used by form fields.
  static const double field = 14;

  static const double full = 999;
}
