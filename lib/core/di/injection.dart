import 'package:get_it/get_it.dart';
import 'package:readline_app/core/services/celebration_service.dart';
import 'package:readline_app/core/services/dictionary_service.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';
import 'package:readline_app/core/services/content_generation/groq_credential_validator.dart';
import 'package:readline_app/core/services/content_generation/magic_content_settings_service.dart';
import 'package:readline_app/core/services/content_generation/settings_aware_content_generation_service.dart';
import 'package:readline_app/core/services/reading_engine_service.dart';
import 'package:readline_app/core/services/streak_service.dart';
import 'package:readline_app/core/services/tts_service.dart';
import 'package:readline_app/core/services/vocabulary_service.dart';
import 'package:readline_app/data/contracts/content_generation_service.dart';
import 'package:readline_app/data/contracts/document_repository.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/contracts/session_repository.dart';
import 'package:readline_app/data/contracts/vocabulary_repository.dart';
import 'package:readline_app/data/datasources/local/hive_definition_cache_source.dart';
import 'package:readline_app/data/datasources/local/hive_milestone_source.dart';
import 'package:readline_app/data/datasources/local/hive_document_source.dart';
import 'package:readline_app/data/datasources/local/hive_preferences_source.dart';
import 'package:readline_app/data/datasources/local/hive_session_source.dart';
import 'package:readline_app/data/datasources/local/hive_streak_source.dart';
import 'package:readline_app/data/datasources/local/hive_vocabulary_source.dart';
import 'package:readline_app/data/repositories/document_repository_impl.dart';
import 'package:readline_app/data/repositories/preferences_repository_impl.dart';
import 'package:readline_app/data/repositories/session_repository_impl.dart';
import 'package:readline_app/data/repositories/vocabulary_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Data sources
  getIt.registerLazySingleton(() => HivePreferencesSource());
  getIt.registerLazySingleton(() => HiveDocumentSource());
  getIt.registerLazySingleton(() => HiveSessionSource());
  getIt.registerLazySingleton(() => HiveVocabularySource());
  getIt.registerLazySingleton(() => HiveStreakSource());
  getIt.registerLazySingleton(() => HiveDefinitionCacheSource());
  getIt.registerLazySingleton(() => HiveMilestoneSource());

  // Repositories
  getIt.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(getIt<HivePreferencesSource>()),
  );
  getIt.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(getIt<HiveDocumentSource>()),
  );
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(getIt<HiveSessionSource>()),
  );
  getIt.registerLazySingleton<VocabularyRepository>(
    () => VocabularyRepositoryImpl(getIt<HiveVocabularySource>()),
  );

  // Services
  getIt.registerLazySingleton(() => PdfProcessingService());
  getIt.registerLazySingleton(() => StreakService(getIt<HiveStreakSource>()));
  getIt.registerLazySingleton(() => ReadingEngineService());
  getIt.registerLazySingleton(
    () => VocabularyService(
      getIt<VocabularyRepository>(),
      getIt<PdfProcessingService>(),
    ),
  );
  getIt.registerLazySingleton(
    () => CelebrationService(
      getIt<StreakService>(),
      getIt<SessionRepository>(),
      getIt<PreferencesRepository>(),
      getIt<HiveMilestoneSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => DictionaryService(getIt<HiveDefinitionCacheSource>()),
  );
  getIt.registerLazySingleton(() => TtsService());
  getIt.registerLazySingleton(
    () => HapticService(prefsRepo: getIt<PreferencesRepository>()),
  );
  getIt.registerLazySingleton<MagicContentSettingsService>(
    () => MagicContentSettingsService(
      prefsRepo: getIt<PreferencesRepository>(),
    ),
  );
  getIt.registerLazySingleton<GroqCredentialValidator>(
    () => GroqCredentialValidator(),
  );
  getIt.registerLazySingleton<ContentGenerationService>(
    () => SettingsAwareContentGenerationService(
      getIt<MagicContentSettingsService>(),
    ),
  );
}
