/// HeroUI Native spacing — tailwind's 4px unit (`--spacing: 0.25rem`).
///
/// `BCSpacing.unit(n)` mirrors tailwind's `calc(var(--spacing) * n)`;
/// the named steps are convenience aliases.
abstract final class BCSpacing {
  /// Tailwind `--spacing` base unit in logical pixels.
  static const double base = 4;

  static double unit(double n) => base * n;

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
