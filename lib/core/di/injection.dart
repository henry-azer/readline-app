import 'package:get_it/get_it.dart';
import 'package:read_it/core/services/celebration_service.dart';
import 'package:read_it/core/services/dictionary_service.dart';
import 'package:read_it/core/services/haptic_service.dart';
import 'package:read_it/core/services/sound_service.dart';
import 'package:read_it/core/services/pdf_processing_service.dart';
import 'package:read_it/core/services/share_card_service.dart';
import 'package:read_it/core/services/reading_engine_service.dart';
import 'package:read_it/core/services/streak_service.dart';
import 'package:read_it/core/services/tts_service.dart';
import 'package:read_it/core/services/vocabulary_service.dart';
import 'package:read_it/data/contracts/document_repository.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/data/contracts/session_repository.dart';
import 'package:read_it/data/contracts/vocabulary_repository.dart';
import 'package:read_it/data/datasources/local/hive_definition_cache_source.dart';
import 'package:read_it/data/datasources/local/hive_milestone_source.dart';
import 'package:read_it/data/datasources/local/hive_document_source.dart';
import 'package:read_it/data/datasources/local/hive_preferences_source.dart';
import 'package:read_it/data/datasources/local/hive_session_source.dart';
import 'package:read_it/data/datasources/local/hive_streak_source.dart';
import 'package:read_it/data/datasources/local/hive_vocabulary_source.dart';
import 'package:read_it/data/repositories/document_repository_impl.dart';
import 'package:read_it/data/repositories/preferences_repository_impl.dart';
import 'package:read_it/data/repositories/session_repository_impl.dart';
import 'package:read_it/data/repositories/vocabulary_repository_impl.dart';

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
  getIt.registerLazySingleton(() => ShareCardService());
  getIt.registerLazySingleton(
    () => DictionaryService(getIt<HiveDefinitionCacheSource>()),
  );
  getIt.registerLazySingleton(() => TtsService());
  getIt.registerLazySingleton(
    () => HapticService(prefsRepo: getIt<PreferencesRepository>()),
  );
  getIt.registerLazySingleton(
    () => SoundService(prefsRepo: getIt<PreferencesRepository>()),
  );
}
