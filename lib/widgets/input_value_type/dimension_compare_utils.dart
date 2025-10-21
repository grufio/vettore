/// Trims whitespace and a single trailing dot to stabilize numeric parsing.
String trimTrailingDot(String s) {
  final String t = s.trim();
  return t.endsWith('.') ? t.substring(0, t.length - 1) : t;
}

/// Returns true if the given text represents a parsable number after
/// sanitization (trimming whitespace and a trailing dot).
bool isParsableNumber(String s) {
  if (s.isEmpty) return false;
  final String t = trimTrailingDot(s);
  return double.tryParse(t) != null;
}

/// Normalizes text for comparison by trimming whitespace only.
String normalizeComparable(String s) => s.trim();

/// Compares current text against a baseline string, after normalizing. This
/// does not attempt numeric equivalence; it is a textual baseline comparator.
bool differsFromBaseline(String current, String baseline) {
  return normalizeComparable(current) != normalizeComparable(baseline);
}
