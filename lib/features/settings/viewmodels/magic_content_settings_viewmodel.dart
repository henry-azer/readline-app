import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/content_generation/groq_credential_validator.dart';
import 'package:readline_app/core/services/content_generation/magic_content_settings_service.dart';

enum MagicContentSettingsStatus {
  connectionSuccessful,
  invalidKey,
  serviceUnreachable,
  keySaved,
}

class MagicContentSettingsViewModel {
  final MagicContentSettingsService _settingsService;
  final GroqCredentialValidator _validator;

  final BehaviorSubject<bool> hasKey$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> isWorking$ = BehaviorSubject.seeded(false);

  /// Fire-once outcome events. Consumed by the screen as snackbar triggers,
  /// so a `PublishSubject` is the right shape — no replay on screen rebuild.
  final PublishSubject<MagicContentSettingsStatus> status$ =
      PublishSubject<MagicContentSettingsStatus>();

  StreamSubscription<bool>? _hasKeySub;

  MagicContentSettingsViewModel({
    MagicContentSettingsService? settingsService,
    GroqCredentialValidator? validator,
  }) : _settingsService =
           settingsService ?? getIt<MagicContentSettingsService>(),
       _validator = validator ?? getIt<GroqCredentialValidator>();

  Future<void> init() async {
    hasKey$.add(_settingsService.hasKey$.value);
    _hasKeySub = _settingsService.hasKey$.listen((val) {
      if (!hasKey$.isClosed) hasKey$.add(val);
    });
  }

  Future<void> testConnection(String key) async {
    if (isWorking$.value) return;
    isWorking$.add(true);
    try {
      final result = await _validator.validate(key);
      status$.add(_statusFromResult(result));
    } finally {
      isWorking$.add(false);
    }
  }

  Future<void> saveKey(String key) async {
    if (isWorking$.value) return;
    isWorking$.add(true);
    try {
      final result = await _validator.validate(key);
      if (result == GroqCredentialResult.valid) {
        await _settingsService.saveKey(key);
        status$.add(MagicContentSettingsStatus.keySaved);
      } else {
        status$.add(_statusFromResult(result));
      }
    } finally {
      isWorking$.add(false);
    }
  }

  /// Deletes the saved key and returns its prior value (or null if none was
  /// saved) so the caller can offer an undo. Snackbar / undo wiring stays in
  /// the screen — this method just owns the persistence side.
  Future<String?> clearKey() async {
    final previous = await _settingsService.getKey();
    await _settingsService.deleteKey();
    return previous;
  }

  Future<void> restoreKey(String key) async {
    await _settingsService.saveKey(key);
  }

  MagicContentSettingsStatus _statusFromResult(GroqCredentialResult result) =>
      switch (result) {
        GroqCredentialResult.valid =>
          MagicContentSettingsStatus.connectionSuccessful,
        GroqCredentialResult.unauthorized =>
          MagicContentSettingsStatus.invalidKey,
        GroqCredentialResult.network =>
          MagicContentSettingsStatus.serviceUnreachable,
        GroqCredentialResult.server =>
          MagicContentSettingsStatus.serviceUnreachable,
      };

  void dispose() {
    _hasKeySub?.cancel();
    hasKey$.close();
    isWorking$.close();
    status$.close();
  }
}
