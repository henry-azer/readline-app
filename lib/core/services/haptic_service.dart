import 'package:flutter/services.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';

/// Wraps platform `HapticFeedback` and gates every call by the user's
/// `hapticsEnabled` preference. The flag is cached in memory after the first
/// read so taps don't pay the Hive-read cost; settings changes call
/// [setEnabled] to flush the cache.
class HapticService {
  final PreferencesRepository _prefsRepo;
  bool _enabled = true;
  bool _hydrated = false;

  HapticService({PreferencesRepository? prefsRepo})
    : _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>() {
    _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await _prefsRepo.get();
      _enabled = prefs.hapticsEnabled;
    } catch (_) {
      _enabled = true;
    } finally {
      _hydrated = true;
    }
  }

  /// Update the cached flag from outside (e.g., when the settings toggle
  /// changes) so we don't have to re-read prefs on every haptic call.
  void setEnabled(bool enabled) {
    _enabled = enabled;
    _hydrated = true;
  }

  Future<void> light() async {
    if (await _isEnabled()) HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (await _isEnabled()) HapticFeedback.mediumImpact();
  }

  Future<void> selection() async {
    if (await _isEnabled()) HapticFeedback.selectionClick();
  }

  Future<bool> _isEnabled() async {
    if (!_hydrated) await _hydrate();
    return _enabled;
  }
}
