class LanguageOption {
  final String code;
  final String countryCode;
  final String name;
  final String nativeName;
  final String textDirection;

  LanguageOption({
    required this.code,
    required this.countryCode,
    required this.name,
    required this.nativeName,
    this.textDirection = 'ltr',
  });

  /// Returns the flag emoji from [countryCode] (e.g., "US" => US flag).
  String get flagEmoji {
    return countryCode
        .toUpperCase()
        .runes
        .map((r) => String.fromCharCode(r - 0x41 + 0x1F1E6))
        .join();
  }
}
