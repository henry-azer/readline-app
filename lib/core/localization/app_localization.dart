import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'language_option.dart';

class AppLocalization {
  static Map<String, dynamic> _localizedStrings = {};
  static String _currentLanguage = 'en';
  static TextDirection _textDirection = TextDirection.ltr;

  static String get currentLanguage => _currentLanguage;
  static bool get isRTL => _textDirection == TextDirection.rtl;
  static TextDirection get textDirection => _textDirection;

  /// Discovers available language codes by scanning assets/lang/*.json via the AssetManifest.
  static Future<List<String>> _discoverLanguageCodes() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      final codes = assets
          .where(
            (path) => path.startsWith('assets/lang/') && path.endsWith('.json'),
          )
          .map(
            (path) =>
                path.replaceFirst('assets/lang/', '').replaceFirst('.json', ''),
          )
          .toList();
      // Ensure 'en' is first as the default fallback
      codes.remove('en');
      codes.insert(0, 'en');
      return codes;
    } catch (e) {
      debugPrint('Error discovering language codes: $e');
      return ['en'];
    }
  }

  static Future<void> initialize({String language = 'en'}) async {
    _currentLanguage = language;
    await _loadLanguage(language);
  }

  static Future<void> _loadLanguage(String language) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/lang/$language.json',
      );
      _localizedStrings = json.decode(jsonString);

      final metadata = _localizedStrings['_metadata'] as Map<String, dynamic>?;
      final direction = metadata?['text_direction'] as String?;
      _textDirection = direction == 'rtl'
          ? TextDirection.rtl
          : TextDirection.ltr;
    } catch (e) {
      debugPrint('Error loading language $language: $e');
      if (language != 'en') {
        await _loadLanguage('en');
      } else {
        _textDirection = TextDirection.ltr;
      }
    }
  }

  static Future<void> changeLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      await _loadLanguage(language);
    }
  }

  static String tr(String key, [Map<String, String>? params]) {
    String result = _getNestedValue(_localizedStrings, key) ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{{$paramKey}}', paramValue);
      });
    }
    return result;
  }

  static String? _getNestedValue(Map<String, dynamic> map, String key) {
    final keys = key.split('.');
    dynamic current = map;
    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null;
      }
    }
    return current?.toString();
  }

  static Future<List<LanguageOption>> getAvailableLanguages() async {
    final codes = await _discoverLanguageCodes();
    final List<LanguageOption> languages = [];
    for (final code in codes) {
      try {
        final jsonString = await rootBundle.loadString(
          'assets/lang/$code.json',
        );
        final langData = json.decode(jsonString) as Map<String, dynamic>;
        final metadata = langData['_metadata'] as Map<String, dynamic>?;
        languages.add(
          LanguageOption(
            code: metadata?['language_code'] ?? code,
            countryCode: metadata?['country_code'] ?? code.toUpperCase(),
            name: metadata?['language_name'] ?? code.toUpperCase(),
            nativeName: metadata?['language_native_name'] ?? code.toUpperCase(),
            textDirection: metadata?['text_direction'] ?? 'ltr',
          ),
        );
      } catch (e) {
        debugPrint('Error loading language $code: $e');
      }
    }
    if (languages.isEmpty) {
      return [
        LanguageOption(
          code: 'en',
          countryCode: 'US',
          name: 'English',
          nativeName: 'English',
        ),
      ];
    }
    return languages;
  }

  static bool hasKey(String key) =>
      _getNestedValue(_localizedStrings, key) != null;
}

extension LocalizationExtension on String {
  String get tr => AppLocalization.tr(this);
  String trParams(Map<String, String> params) =>
      AppLocalization.tr(this, params);
}
