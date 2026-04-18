import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'core/services/pdf_processing_service.dart';
import 'core/services/reading_display_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/database_service.dart';
import 'data/repositories/pdf_repository_impl.dart';
import 'data/repositories/user_preferences_repository_impl.dart';
import 'data/repositories/reading_session_repository_impl.dart';
import 'data/repositories/analytics_repository_impl.dart';
import 'data/datasources/pdf_local_datasource.dart';
import 'data/datasources/user_preferences_local_datasource.dart';
import 'data/datasources/reading_session_local_datasource.dart';
import 'data/datasources/analytics_local_datasource.dart';
import 'features/pdf_processing/providers/pdf_processing_provider.dart';
import 'features/reading_display/providers/reading_display_provider.dart';
import 'features/user_preferences/providers/user_preferences_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'domain/repositories/pdf_repository.dart';
import 'domain/repositories/user_preferences_repository.dart';
import 'domain/repositories/reading_session_repository.dart';

final GetIt sl = GetIt.instance;

List<ChangeNotifierProvider> providers = [
  ChangeNotifierProvider(create: (_) => sl<PdfProcessingProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ReadingDisplayProvider>()),
  ChangeNotifierProvider(create: (_) => sl<UserPreferencesProvider>()),
  ChangeNotifierProvider(create: (_) => sl<AnalyticsProvider>()),
];

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Database
  final database = await _initDatabase();
  sl.registerLazySingleton<Database>(() => database);

  // Core services
  sl.registerLazySingleton(() => DatabaseService(sl()));
  sl.registerLazySingleton(() => PdfProcessingService());
  sl.registerLazySingleton(() => ReadingDisplayService());
  sl.registerLazySingleton(() => AnalyticsService());

  // Data sources
  sl.registerLazySingleton<PdfLocalDataSource>(
    () => PdfLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UserPreferencesLocalDataSource>(
    () => UserPreferencesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ReadingSessionLocalDataSource>(
    () => ReadingSessionLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AnalyticsLocalDataSource>(
    () => AnalyticsLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<PdfRepository>(
    () => PdfRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<UserPreferencesRepository>(
    () => UserPreferencesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReadingSessionRepository>(
    () => ReadingSessionRepositoryImpl(sl()),
  );

  // Providers
  sl.registerFactory(() => PdfProcessingProvider(sl()));
  sl.registerFactory(() => ReadingDisplayProvider(sl(), sl()));
  sl.registerFactory(() => UserPreferencesProvider(sl()));
  sl.registerFactory(() => AnalyticsProvider(sl()));
}

Future<Database> _initDatabase() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'readit.db');

  return await openDatabase(
    path,
    version: 1,
    onCreate: _onCreate,
  );
}

Future<void> _onCreate(Database db, int version) async {
  // Reading Sessions table
  await db.execute('''
    CREATE TABLE reading_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pdf_id TEXT NOT NULL,
      start_time INTEGER NOT NULL,
      end_time INTEGER,
      words_read INTEGER DEFAULT 0,
      average_speed REAL DEFAULT 0,
      settings_snapshot TEXT
    )
  ''');

  // PDF Documents table
  await db.execute('''
    CREATE TABLE pdf_documents (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      file_path TEXT NOT NULL,
      page_count INTEGER DEFAULT 0,
      word_count INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL,
      last_read INTEGER
    )
  ''');

  // User Preferences table
  await db.execute('''
    CREATE TABLE user_preferences (
      id INTEGER PRIMARY KEY,
      reading_speed REAL DEFAULT 200,
      line_spacing REAL DEFAULT 1.5,
      font_size INTEGER DEFAULT 16,
      theme_mode TEXT DEFAULT 'system',
      focus_window_size INTEGER DEFAULT 3
    )
  ''');

  // Vocabulary Words table
  await db.execute('''
    CREATE TABLE vocabulary_words (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      word TEXT NOT NULL,
      context TEXT,
      session_id INTEGER,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (session_id) REFERENCES reading_sessions (id)
    )
  ''');
}
