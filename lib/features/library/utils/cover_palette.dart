import 'package:flutter/material.dart';

/// Stable per-title gradient palettes for the document grid card cover.
///
/// An FNV-1a hash over [title]'s UTF-16 code units selects one of 8 palettes;
/// each palette has a light-mode and dark-mode variant. Same title always
/// yields the same gradient across platforms, giving every document a
/// unique-but-stable visual identity.
abstract final class CoverPalette {
  static const int _count = 8;

  /// Returns 0..7 for [title]. Stable across platforms — uses an FNV-1a
  /// hash over title code units rather than [String.hashCode], which is
  /// not guaranteed to agree across mobile and web.
  static int paletteIndex(String title) {
    var h = 2166136261;
    for (final u in title.codeUnits) {
      h ^= u;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h % _count;
  }

  /// Returns the 3-stop gradient (TL → BR) for [title]. The selected
  /// palette varies by [isDark].
  static List<Color> forTitle(String title, {required bool isDark}) {
    final palettes = isDark ? _darkPalettes : _lightPalettes;
    return palettes[paletteIndex(title)];
  }

  /// Returns the title text color appropriate for the gradient
  /// brightness — near-black on light gradients, off-white on dark.
  static Color titleColor({required bool isDark}) =>
      isDark ? const Color(0xFFF5F1E6) : const Color(0xFF1A1310);

  // ── Palettes ──────────────────────────────────────────────────────────────

  static const List<List<Color>> _lightPalettes = [
    // 0 — cream / linen
    [Color(0xFFF1E8D8), Color(0xFFD4BF95), Color(0xFFB89968)],
    // 1 — sage / olive
    [Color(0xFFE8EDE0), Color(0xFFB9C4A8), Color(0xFF8A9B73)],
    // 2 — dusk / mauve
    [Color(0xFFEDE2E3), Color(0xFFC8A8B3), Color(0xFF98718C)],
    // 3 — mist / cobalt
    [Color(0xFFDDE7EE), Color(0xFF9AB4C9), Color(0xFF6B8EAA)],
    // 4 — apricot / terracotta
    [Color(0xFFF3DCCD), Color(0xFFD99E85), Color(0xFFB66F51)],
    // 5 — lilac / orchid
    [Color(0xFFE2D4DD), Color(0xFFA87F99), Color(0xFF6F4969)],
    // 6 — celadon / fern
    [Color(0xFFDFE6D8), Color(0xFF97A98A), Color(0xFF5C7558)],
    // 7 — platinum / slate
    [Color(0xFFD8DDE6), Color(0xFF8C98AC), Color(0xFF535D75)],
  ];

  static const List<List<Color>> _darkPalettes = [
    // 0 — warm umber → deep gold
    [Color(0xFF3F3522), Color(0xFF6B5530), Color(0xFF8C7338)],
    // 1 — deep moss → forest
    [Color(0xFF2C3424), Color(0xFF4A5638), Color(0xFF697A4F)],
    // 2 — aubergine → wine
    [Color(0xFF362230), Color(0xFF5A3A50), Color(0xFF7C4F6E)],
    // 3 — navy → indigo
    [Color(0xFF1F2A38), Color(0xFF36465E), Color(0xFF4F627F)],
    // 4 — brick → ember
    [Color(0xFF402217), Color(0xFF6B3826), Color(0xFF8E4F39)],
    // 5 — iris → midnight violet
    [Color(0xFF2C2034), Color(0xFF483356), Color(0xFF61477A)],
    // 6 — pine → deep forest
    [Color(0xFF1F2C22), Color(0xFF334736), Color(0xFF4A6650)],
    // 7 — charcoal → ink
    [Color(0xFF252830), Color(0xFF3D434F), Color(0xFF565D6F)],
  ];
}
