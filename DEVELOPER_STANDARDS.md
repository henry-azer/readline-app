# Asset-It App Developer Standards

## Overview

This document outlines the comprehensive development standards and patterns used in the Asset-It Flutter application. These standards ensure consistency, maintainability, and scalability across all development efforts.

## Table of Contents

1. [Project Architecture](#project-architecture)
2. [Folder Structure](#folder-structure)
3. [State Management](#state-management)
4. [Dependency Injection](#dependency-injection)
5. [Localization Standards](#localization-standards)
6. [Theming System](#theming-system)
7. [Feature Implementation Patterns](#feature-implementation-patterns)
8. [Code Quality Standards](#code-quality-standards)
9. [Database Management](#database-management)
10. [Authentication & Security](#authentication--security)
11. [Testing Standards](#testing-standards)
12. [Performance Guidelines](#performance-guidelines)

---

## Project Architecture

### Clean Architecture Principles

The Asset-It app follows Clean Architecture with clear separation of concerns:

```
lib/
├── app.dart                 # Main app widget with providers
├── main.dart               # App entry point
├── injection_container.dart # Dependency injection setup
├── config/                 # Configuration layer
├── core/                   # Core business logic
├── data/                   # Data layer
└── features/              # Feature modules
```

### Key Architectural Decisions

- **State Management**: Provider pattern with ChangeNotifier
- **Dependency Injection**: GetIt service locator
- **Database**: SQLite with sqflite for local storage
- **Authentication**: Supabase with biometric support
- **Localization**: Custom JSON-based system
- **Theming**: Material 3 with custom color schemes

---

## Folder Structure

### Root Structure

```
asset-it-app/
├── lib/
│   ├── app.dart
│   ├── main.dart
│   ├── injection_container.dart
│   ├── config/
│   ├── core/
│   ├── data/
│   └── features/
├── assets/
│   ├── images/
│   ├── fonts/
│   └── lang/
├── android/
├── ios/
├── test/
└── pubspec.yaml
```

### Config Layer (`lib/config/`)

```
config/
├── localization/           # Internationalization
│   ├── app_localization.dart
│   ├── language_option.dart
│   └── language_provider.dart
├── routes/                # Navigation
│   └── app_routes.dart
├── themes/               # App theming
│   ├── app_theme.dart
│   └── theme_provider.dart
├── admob/               # Ad configuration
│   └── admob_config.dart
└── supabase/            # Backend configuration
    └── supabase_config.dart
```

### Core Layer (`lib/core/`)

```
core/
├── constants/            # App constants
├── data/               # Core data entities
│   ├── datasources/
│   ├── repositories/
│   └── models/
├── domain/             # Business logic
├── managers/           # System managers
│   ├── database-manager/
│   ├── storage-manager/
│   ├── ads-manager/
│   └── purchase-manager/
├── providers/          # Core providers
├── services/           # External services
├── utils/              # Utility functions
└── factories/          # Object factories
```

### Data Layer (`lib/data/`)

```
data/
├── datasources/        # Data sources
│   ├── asset_local_datasource.dart
│   ├── salary_local_datasource.dart
│   └── ...
├── entities/          # Data models
│   ├── asset.dart
│   ├── user.dart
│   └── ...
├── enums/            # Enum definitions
├── services/         # Data services
└── strings/          # String constants
```

### Feature Layer (`lib/features/`)

Each feature follows this structure:

```
features/
└── [feature_name]/
    ├── presentation/
    │   ├── providers/      # State management
    │   ├── screens/        # UI screens
    │   └── widgets/        # Reusable widgets
    ├── data/              # Feature-specific data
    │   ├── models/
    │   └── repositories/
    └── domain/            # Feature business logic
```

---

## State Management

### Provider Pattern Implementation

All state management uses the Provider pattern with ChangeNotifier:

```dart
class ExampleProvider extends ChangeNotifier {
  // Private state
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;

  // Public getters
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // State mutation methods
  Future<void> loadItems() async {
    _setLoading(true);
    try {
      _items = await _dataSource.getItems();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### Provider Registration

All providers are registered in `app.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => LanguageProvider()),
    ChangeNotifierProvider(create: (_) => ExampleProvider()),
    // ... other providers
  ],
  child: MaterialApp(...),
)
```

### State Management Best Practices

1. **Single Responsibility**: Each provider manages one specific domain
2. **Immutable State**: Never mutate state directly; use setter methods
3. **Error Handling**: Always handle errors gracefully with try-catch
4. **Loading States**: Implement loading states for async operations
5. **Notify Listeners**: Call `notifyListeners()` only when state changes

---

## Dependency Injection

### GetIt Service Locator

The app uses GetIt for dependency injection, configured in `injection_container.dart`:

```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Managers
  sl.registerLazySingleton<IStorageManager>(() => LocalStorageManager());
  sl.registerLazySingleton<IDatabaseManager>(() => SQLiteDatabaseManager());
  
  // Services
  sl.registerLazySingleton<IAuthService>(() => SupabaseAuthService());
  
  // Data sources
  sl.registerLazySingleton<AssetLocalDataSource>(() => AssetLocalDataSourceImpl());
  
  // Repositories
  sl.registerLazySingleton<IAssetRepository>(() => AssetRepositoryImpl());
}
```

### Injection Patterns

1. **Lazy Singletons**: Use for services that should have one instance
2. **Factory Pattern**: Use for objects that need new instances
3. **Async Initialization**: Handle async dependencies properly
4. **Interface Segregation**: Depend on abstractions, not implementations

---

## Localization Standards

### JSON-Based Localization System

The app uses a custom JSON-based localization system:

#### Language File Structure (`assets/lang/en.json`)

```json
{
  "_metadata": {
    "language_code": "en",
    "language_name": "English",
    "language_native_name": "English",
    "text_direction": "ltr"
  },
  "dashboard": "Dashboard",
  "portfolio_overview": "Portfolio Overview",
  "assets": {
    "add_asset": "Add Asset",
    "edit_asset": "Edit Asset",
    "delete_asset": "Delete Asset"
  },
  "errors": {
    "network_error": "Network error occurred",
    "validation_error": "Please check your input"
  }
}
```

#### Localization Usage

```dart
// Simple translation
Text('dashboard'.tr)

// Nested key translation
Text('assets.add_asset'.tr)

// Parameterized translation
Text('welcome_user'.trParams({'name': 'John'}))
```

### Localization Best Practices

1. **Key Naming**: Use snake_case with dot notation for nesting
2. **Fallback Handling**: Always provide English fallback
3. **RTL Support**: Include text direction in metadata
4. **Parameterization**: Use `{{param}}` syntax for dynamic values
5. **Namespace Organization**: Group related translations under common keys

### Adding New Languages

1. Create new JSON file in `assets/lang/` (e.g., `fr.json`)
2. Copy structure from `en.json`
3. Add language code to `_supportedLanguageCodes` in `AppLocalization`
4. Update metadata with proper language information

---

## Theming System

### Material 3 Design System

The app uses Material 3 with custom theming:

#### Color System (`lib/core/utils/app_colors.dart`)

```dart
class AppColors {
  // Light Theme
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  // Dark Theme
  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}
```

#### Theme Configuration

```dart
ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.roboto,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      // ... other colors
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      // ... other text styles
    ),
    // ... component themes
  );
}
```

### Theming Best Practices

1. **Color Consistency**: Use defined color constants throughout the app
2. **Typography Hierarchy**: Follow Material 3 typography scale
3. **Component Theming**: Customize all major components consistently
4. **Dark Mode Support**: Ensure complete dark theme coverage
5. **Semantic Colors**: Use semantic colors for feedback states

---

## Feature Implementation Patterns

### Standard Feature Structure

Each feature should follow this consistent structure:

```
features/example/
├── presentation/
│   ├── providers/
│   │   └── example_provider.dart
│   ├── screens/
│   │   ├── example_screen.dart
│   │   └── example_detail_screen.dart
│   └── widgets/
│       └── example_widget.dart
├── data/
│   ├── models/
│   │   └── example_model.dart
│   └── repositories/
│       └── example_repository.dart
└── domain/
    ├── entities/
    │   └── example_entity.dart
    └── usecases/
        └── example_usecase.dart
```

### Provider Implementation Pattern

```dart
class ExampleProvider extends ChangeNotifier {
  final ExampleRepository _repository;
  
  // State
  List<Example> _items = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Example> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Constructor
  ExampleProvider(this._repository);
  
  // Methods
  Future<void> loadItems() async {
    _setLoading(true);
    try {
      _items = await _repository.getItems();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### Screen Implementation Pattern

```dart
class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExampleProvider(sl<ExampleRepository>())..loadItems(),
      child: Consumer<ExampleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const CircularProgressIndicator();
          }
          
          if (provider.error != null) {
            return ErrorWidget(provider.error!);
          }
          
          return Scaffold(
            appBar: AppBar(title: Text('example'.tr)),
            body: ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];
                return ExampleTile(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}
```

### Widget Implementation Pattern

```dart
class ExampleTile extends StatelessWidget {
  final Example item;
  
  const ExampleTile({super.key, required this.item});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(item.description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigation logic
        },
      ),
    );
  }
}
```

---

## Code Quality Standards

### Dart/Flutter Standards

1. **Linting**: Use `flutter_lints` package with custom rules
2. **Formatting**: Run `dart format .` before commits
3. **Naming**: Use `camelCase` for variables, `PascalCase` for classes
4. **File Naming**: Use `snake_case.dart` for files
5. **Import Organization**: Group imports by type (dart, flutter, packages, local)

### Code Documentation

```dart
/// A provider that manages the state for assets.
/// 
/// This provider handles loading, creating, updating, and deleting assets.
/// It communicates with the local data source and notifies listeners of state changes.
class AssetsProvider extends ChangeNotifier {
  /// The list of all assets.
  List<Asset> get assets => _assets;
  
  /// Loads all assets from the local data source.
  /// 
  /// Sets [isLoading] to true during the operation and updates the error state
  /// if an exception occurs.
  Future<void> loadAssets() async {
    // Implementation
  }
}
```

### Error Handling Standards

```dart
try {
  final result = await riskyOperation();
  return result;
} on NetworkException catch (e) {
  _setError('network_error'.tr);
} on ValidationException catch (e) {
  _setError('validation_error'.tr);
} catch (e) {
  _setError('unknown_error'.tr);
  debugPrint('Unexpected error: $e');
}
```

---

## Database Management

### SQLite Integration

The app uses SQLite with the sqflite package:

#### Database Manager Pattern

```dart
abstract class IDatabaseManager {
  Future<void> init();
  Future<int> insert(String table, Map<String, dynamic> values);
  Future<List<Map<String, dynamic>>> query(String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });
  Future<int> update(String table, Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  });
  Future<int> delete(String table, {
    String? where,
    List<dynamic>? whereArgs,
  });
}
```

#### Data Source Pattern

```dart
class AssetLocalDataSourceImpl implements AssetLocalDataSource {
  final IDatabaseManager _databaseManager;
  
  AssetLocalDataSourceImpl(this._databaseManager);
  
  @override
  Future<List<Asset>> getAssets() async {
    final data = await _databaseManager.query('assets');
    return data.map((json) => Asset.fromJson(json)).toList();
  }
  
  @override
  Future<void> insertAsset(Asset asset) async {
    await _databaseManager.insert('assets', asset.toJson());
  }
}
```

### Database Best Practices

1. **Schema Versioning**: Implement proper migration strategies
2. **Connection Management**: Use singleton pattern for database connections
3. **Error Handling**: Handle database errors gracefully
4. **Data Validation**: Validate data before database operations
5. **Performance**: Use transactions for multiple operations

---

## Authentication & Security

### Authentication Architecture

The app uses Supabase for authentication with local biometric support:

#### Auth Service Pattern

```dart
abstract class IAuthService {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Stream<User?> authStateChanges();
}
```

#### Biometric Integration

```dart
class BiometricAuthManager {
  final AuthTokenManager _tokenManager;
  final BiometricProvider _biometricProvider;
  final IAuthService _authService;
  
  Future<bool> authenticateWithBiometrics() async {
    final isAvailable = await _biometricProvider.isAvailable();
    if (!isAvailable) return false;
    
    final isAuthenticated = await _biometricProvider.authenticate();
    if (isAuthenticated) {
      await _tokenManager.refreshToken();
      return true;
    }
    return false;
  }
}
```

### Security Best Practices

1. **Token Management**: Secure storage of authentication tokens
2. **Biometric Authentication**: Local authentication fallback
3. **Data Encryption**: Encrypt sensitive data at rest
4. **Network Security**: Use HTTPS for all API calls
5. **Session Management**: Proper session timeout handling

---

## Testing Standards

### Testing Structure

```
test/
├── unit/                  # Unit tests
│   ├── providers/
│   ├── services/
│   └── utils/
├── widget/               # Widget tests
│   └── screens/
└── integration/          # Integration tests
    └── app_test.dart
```

### Unit Testing Pattern

```dart
void main() {
  group('AssetsProvider', () {
    late AssetsProvider provider;
    late MockAssetRepository mockRepository;
    
    setUp(() {
      mockRepository = MockAssetRepository();
      provider = AssetsProvider(mockRepository);
    });
    
    test('should load assets successfully', () async {
      // Arrange
      final mockAssets = [Asset(id: '1', name: 'Test Asset')];
      when(mockRepository.getAssets())
          .thenAnswer((_) async => mockAssets);
      
      // Act
      await provider.loadAssets();
      
      // Assert
      expect(provider.assets, mockAssets);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });
  });
}
```

### Widget Testing Pattern

```dart
void main() {
  testWidgets('AssetScreen displays assets correctly', (tester) async {
    // Arrange
    final mockProvider = MockAssetsProvider();
    when(mockProvider.assets).thenReturn([Asset(id: '1', name: 'Test')]);
    when(mockProvider.isLoading).thenReturn(false);
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AssetsProvider>.value(
          value: mockProvider,
          child: AssetScreen(),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Test'), findsOneWidget);
  });
}
```

---

## Performance Guidelines

### Performance Best Practices

1. **Lazy Loading**: Implement lazy loading for large lists
2. **Image Caching**: Use cached_network_image for remote images
3. **State Optimization**: Minimize unnecessary rebuilds
4. **Memory Management**: Dispose controllers and streams properly
5. **Database Optimization**: Use efficient queries and indexing

### Widget Performance

```dart
// Use const constructors where possible
const Card(
  child: ListTile(
    title: Text('Title'),
  ),
)

// Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
)

// Avoid unnecessary rebuilds with Consumer
Consumer<Provider>(
  builder: (context, provider, child) {
    return Column(
      children: [
        child, // This widget won't rebuild
        Text(provider.data),
      ],
    );
  },
  child: const SomeExpensiveWidget(),
)
```

### Memory Management

```dart
class _ExampleScreenState extends State<ExampleScreen> {
  late TextEditingController _controller;
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _subscription = someStream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }
}
```

---

## Development Workflow

### Setup Instructions

1. **Environment Setup**:
   ```bash
   flutter pub get
   flutter run
   ```

2. **Code Generation** (if using):
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Testing**:
   ```bash
   flutter test
   ```

4. **Build**:
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

### Git Workflow

1. **Branch Naming**: `feature/description`, `bugfix/description`
2. **Commit Messages**: Use conventional commits
3. **Code Review**: All PRs require review
4. **CI/CD**: Automated testing and building

### Release Process

1. **Version Update**: Update `pubspec.yaml` version
2. **Changelog**: Update CHANGELOG.md
3. **Testing**: Run full test suite
4. **Build**: Create release builds
5. **Deployment**: Deploy to app stores

---

## Conclusion

These standards provide a comprehensive foundation for developing high-quality Flutter applications following the Asset-It app patterns. Adherence to these standards ensures:

- **Consistency**: Uniform code structure and patterns
- **Maintainability**: Easy to understand and modify code
- **Scalability**: Architecture that grows with the application
- **Quality**: High code quality and testing coverage
- **Performance**: Optimized user experience

All developers should familiarize themselves with these standards and apply them consistently throughout the development process.
