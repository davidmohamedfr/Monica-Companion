### Clean Architecture principles for Flutter applications enforcing strict layer separation, dependency inversion, and feature-based modularization to ensure testable, maintainable, and scalable code with clear boundaries between business logic, data management, and UI presentation

#### Layer Separation

- Domain layer contains only business logic
- Data layer handles all external communications
- Presentation layer manages UI and state
- Dependencies flow inward only
- No framework dependencies in domain

```dart
// domain/entities/contact.dart
class Contact extends Equatable {
  final String id;
  final String name;
}
```

#### Domain Layer Rules

- Entities are pure Dart classes
- Use cases contain business rules
- Repository interfaces define contracts
- No Flutter imports in domain
- Immutable entities with Equatable

#### Data Layer Rules

- Implement repository interfaces from domain
- DTOs for external data mapping
- Data sources handle API/database calls
- Mappers convert DTOs to entities
- Error handling with custom exceptions

```dart
// data/repositories/contact_repository_impl.dart
class ContactRepositoryImpl implements ContactRepository {
  final ApiService apiService;
  final ContactMapper mapper;
}
```

#### Presentation Layer Rules

- Features organized by screens/pages
- State management per feature
- Widgets separated from logic
- Controllers/BLoCs handle presentation logic
- UI components in shared widgets

#### Feature Organization

- Each feature is self-contained module
- Feature contains all three layers
- Shared components in @lib/features/shared
- Cross-feature communication via use cases
- Feature exports only public API

```dart
lib/features/contacts/
├── domain/
├── data/
└── presentation/
```

#### Dependency Rules

- Domain has zero dependencies
- Data depends only on domain
- Presentation depends on domain
- Service locator for dependency injection
- Interfaces over concrete implementations

#### Use Case Rules

- Single responsibility per use case
- Execute method with clear parameters
- Return Either<Failure, Success>
- No UI or framework logic
- Testable with mocks

```dart
class GetContactsUseCase {
  Future<Either<Failure, List<Contact>>> execute() {}
}
```

#### Repository Pattern

- Abstract repositories in domain
- Concrete implementations in data
- Repository interfaces at @lib/db/interfaces
- Generic CRUD operations in base
- Feature-specific repositories extend base

#### Error Handling

- Custom exceptions in @lib/core/errors/exceptions
- Failures in @lib/core/errors/failures
- Transform exceptions to failures
- Propagate failures through layers
- Handle failures in presentation

#### State Management

- State classes in @lib/features/shared/models
- Loading, error, success states
- Immutable state objects
- State transitions in controllers
- Reactive UI updates

#### Testing Structure

- Unit tests per layer
- Mock dependencies with interfaces
- Test use cases independently
- Integration tests for features
- Widget tests for UI components

### Ports and Adapters (Hexagonal Architecture) pattern implementation for Flutter ensuring core business logic isolation through well-defined interfaces (ports) and their concrete implementations (adapters), enabling technology independence and improved testability

#### Core Domain Isolation

- Business logic in application core
- Zero external dependencies in core
- Core defines its own interfaces
- External world adapts to core
- Technology decisions are deferred

```dart
// core/ports/contact_port.dart
abstract class ContactPort {
  Future<Contact> findById(String id);
}
```

#### Port Definition Rules

- Ports are abstract interfaces
- Define contracts for external services
- Located in @lib/services/interfaces
- Repository ports in @lib/db/interfaces
- One port per external boundary

#### Primary Ports (Driving)

- UI adapters implement presentation ports
- Controllers adapt user actions
- REST API controllers as adapters
- CLI adapters for commands
- Event listeners as adapters

```dart
// presentation/adapters/contact_controller.dart
class ContactController implements ContactPresenter {
  final ContactUseCase useCase;
}
```

#### Secondary Ports (Driven)

- Database adapters implement persistence
- API adapters for external services
- Storage adapters at @lib/services/interfaces/storage_service
- Notification adapters for messaging
- File system adapters for I/O

#### Adapter Implementation

- Adapters in @lib/services/implementations
- Implement port interfaces exactly
- Handle technology-specific details
- Convert between domain and external
- Error translation in adapters

```dart
// adapters/api/monica_api_adapter.dart
class MonicaApiAdapter implements ApiService {
  final HttpClient httpClient;
}
```

#### Dependency Injection

- Service locator at @lib/services/service_locator
- Register ports with implementations
- Inject ports, not adapters
- Configure adapters at startup
- Swap implementations easily

#### Interface Segregation

- Small, focused interfaces
- Single responsibility per port
- Client-specific interfaces
- No unused method dependencies
- Compose interfaces when needed

```dart
abstract class ReadOnlyRepository<T> {
  Future<T?> findById(String id);
  Future<List<T>> findAll();
}
```

#### External Service Integration

- API service at @lib/services/interfaces/api_service
- Base service at @lib/services/interfaces/base_service
- Wrap external libraries in adapters
- Isolate third-party dependencies
- Mock external services in tests

#### Database Abstraction

- Database interface at @lib/db/interfaces/database_interface
- Repository pattern for data access
- Base repository at @lib/db/repositories/base_repository
- Model mapping in adapters
- Database-agnostic domain

#### Configuration Management

- Environment config at @lib/core/config/environment
- App config at @lib/core/config/app_config
- Inject configuration through ports
- Environment-specific adapters
- Runtime configuration changes

#### Testing Strategy

- Test core logic without adapters
- Mock ports for unit tests
- Integration tests with real adapters
- Adapter tests verify contracts
- Test adapter substitution

```dart
class MockContactPort extends Mock implements ContactPort {}
```

#### Port Categories

- Persistence ports for data storage
- Messaging ports for communication
- UI ports for presentation
- Infrastructure ports for services
- External API ports for integration

#### Adapter Categories

- HTTP adapters for REST APIs
- GraphQL adapters for queries
- WebSocket adapters for real-time
- Database adapters for persistence
- Cache adapters for performance

#### Error Handling at Boundaries

- Catch external errors in adapters
- Transform to domain exceptions
- Domain defines error types
- Adapters handle retry logic
- Circuit breakers in adapters

#### Technology Migration

- Replace adapters, not core logic
- Gradual migration support
- Feature flags for adapter switching
- A/B testing with different adapters
- Zero-downtime adapter swaps

### Dart language best practices covering null safety, async patterns, code organization, naming conventions, error handling, and documentation standards for maintainable and idiomatic Dart code

#### Language Features

- Use sound null safety
- Avoid `!` unless guaranteed non-null
- Prefer `async`/`await` over callbacks
- Use `Future` for single async operations
- Use `Stream` for async sequences
- Apply pattern matching for simplification
- Use records for multiple returns
- Prefer exhaustive switch statements

#### Code Style

- Use `PascalCase` for classes
- Use `camelCase` for members/functions
- Use `snake_case` for files
- Keep functions under 20 lines
- Single purpose per function
- Use arrow syntax for one-liners
- Group related classes in library
- Organize libraries by feature

#### Naming Conventions

- Avoid abbreviations in names
- Use meaningful descriptive names
- Be consistent across codebase
- Follow @lib/core/constants/app_constants.dart patterns
- Match existing service naming @lib/services/interfaces/

#### Error Handling

- Use `try-catch` for exceptions
- Create custom exceptions when needed
- Never let code fail silently
- Throw exceptions early
- Handle errors at appropriate level
- Follow @lib/core/errors/exceptions.dart patterns

#### Documentation

- Use `///` for doc comments
- Start with single-sentence summary
- Document all public APIs
- Explain why, not what
- Avoid redundant documentation
- Include code examples when helpful

#### Best Practices

- Follow Effective Dart guidelines
- Prefer composition over inheritance
- Use immutable data structures
- Apply SOLID principles
- Write testable code
- Use `logging` package over `print`
- Define types explicitly
- Avoid dynamic typing

### Flutter navigation and routing patterns using go_router for declarative navigation, deep linking support, and authentication flows with proper route organization

#### Navigation Strategy

- Use `go_router` for routing
- Support deep linking
- Implement declarative navigation
- Handle authentication redirects
- Organize routes hierarchically
- Use typed route parameters
- Support web URLs properly

#### GoRouter Setup

```dart
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailScreen(id: id);
          },
        ),
      ],
    ),
  ],
);
```

#### Route Organization

- Define routes centrally
- Use nested routes
- Group related routes
- Keep routes immutable
- Use route constants
- Document route parameters
- Version API routes

#### Navigation Patterns

- Use `context.go()` for navigation
- Apply `context.push()` for stack
- Use `context.pop()` to return
- Pass typed parameters
- Handle query parameters
- Implement route guards
- Support back button properly

#### Authentication Flow

- Configure redirect property
- Check auth on navigation
- Redirect to login when needed
- Save intended destination
- Restore route after login
- Handle token expiration
- Clear stack on logout

#### Deep Linking

- Define URL patterns
- Handle app links
- Support universal links
- Parse path parameters
- Validate incoming links
- Handle malformed URLs
- Test on all platforms

#### Dialog Navigation

- Use `Navigator` for dialogs
- Keep dialogs stateless
- Return dialog results
- Handle dialog dismissal
- Avoid deep-linked dialogs
- Use bottom sheets appropriately
- Implement modal barriers

### Flutter state management patterns using built-in solutions, proper separation of concerns, and data flow architecture for predictable and maintainable application state

#### State Management Principles

- Separate ephemeral from app state
- Use built-in solutions first
- Avoid unnecessary third-party packages
- Keep state close to usage
- Minimize state mutations
- Make state predictable
- Follow @lib/features/shared/models/feature_state.dart patterns

#### Built-in Solutions

- Use `setState` for simple local state
- Apply `ValueNotifier` for single values
- Use `ChangeNotifier` for complex state
- Implement `InheritedWidget` for deep sharing
- Use `FutureBuilder` for async operations
- Apply `StreamBuilder` for streams
- Prefer `ListenableBuilder` over rebuilds

#### ValueNotifier Pattern

```dart
final ValueNotifier<int> counter = ValueNotifier<int>(0);

ValueListenableBuilder<int>(
  valueListenable: counter,
  builder: (context, value, child) {
    return Text('Count: $value');
  },
);
```

#### State Organization

- Group state by feature
- Create state models
- Use immutable state objects
- Implement state factories
- Define clear state transitions
- Document state dependencies
- Follow MVVM when complex

#### Data Flow Architecture

- Implement repository pattern @lib/db/repositories/
- Use service interfaces @lib/services/interfaces/
- Abstract data sources
- Handle errors at service level
- Transform data in repositories
- Keep UI layer thin
- Apply dependency injection

#### State Best Practices

- Initialize state in `initState()`
- Dispose resources in `dispose()`
- Avoid state in build methods
- Prevent unnecessary rebuilds
- Use `const` constructors
- Profile state performance
- Test state transitions

### Flutter theming, visual design, and accessibility best practices for creating beautiful, responsive, and inclusive user interfaces with Material 3 design system

#### Material 3 Theming

- Use `ColorScheme.fromSeed()` for palettes
- Define light and dark themes
- Apply `ThemeData` consistently
- Customize component themes
- Use `Theme.of(context)` for colors
- Implement theme extensions
- Support system theme mode

#### Color Scheme

- Follow 60-30-10 color rule
- Maintain WCAG contrast ratios
- Use semantic color names
- Define color tokens
- Test in light/dark modes
- Apply consistent color hierarchy
- Avoid hardcoded colors

```dart
ColorScheme.fromSeed(
  seedColor: Colors.deepPurple,
  brightness: Brightness.light,
)
```

#### Typography

- Define complete `TextTheme`
- Use platform-appropriate fonts
- Maintain readable line height (1.4-1.6x)
- Keep line length 45-75 characters
- Apply consistent font weights
- Use `GoogleFonts` for custom fonts
- Follow hierarchy patterns

#### Responsive Design

- Use `LayoutBuilder` for responsive UI
- Apply `MediaQuery` for screen info
- Design mobile-first approach
- Support multiple breakpoints
- Use `Flexible` and `Expanded`
- Implement adaptive layouts
- Test on various devices

#### Layout Best Practices

- Avoid overflow with `Flexible`
- Use `SingleChildScrollView` when needed
- Apply `ListView.builder` for lists
- Use `Wrap` for flowing content
- Implement `Stack` for overlays
- Apply `FittedBox` for scaling
- Use `ConstrainedBox` for limits

#### Accessibility (A11Y)

- Ensure 4.5:1 contrast ratio
- Support dynamic text scaling
- Add semantic labels
- Test with screen readers
- Provide focus indicators
- Support keyboard navigation
- Include meaningful tooltips

#### Asset Management

- Declare assets in `pubspec.yaml`
- Use `Image.asset` for local images
- Implement error handling for images
- Provide loading indicators
- Cache network images appropriately
- Optimize image sizes
- Support multiple resolutions

### Flutter widget architecture patterns emphasizing composition, immutability, performance optimization, and proper widget tree structure for scalable and maintainable UI development

#### Widget Architecture

- Prefer composition over inheritance
- Keep widgets immutable
- Use `StatelessWidget` when possible
- Create small reusable widgets
- Avoid deep widget nesting
- Extract widgets to private classes
- Never return widgets from methods
- Follow @lib/features/shared/widgets/ patterns

#### Build Method Practices

- Keep `build()` methods small
- Avoid expensive operations in `build()`
- No network calls in `build()`
- Extract complex UI to widgets
- Use `const` constructors everywhere
- Cache expensive computations
- Minimize widget rebuilds

#### Performance Optimization

- Use `const` for static widgets
- Apply `ListView.builder` for long lists
- Implement `SliverList` for custom scrolling
- Use `RepaintBoundary` for expensive widgets
- Apply `AutomaticKeepAliveClientMixin` carefully
- Run expensive ops with `compute()`
- Profile with Flutter DevTools

#### Widget Organization

- One widget per file
- Group widgets by feature
- Create widget libraries
- Use barrel exports
- Keep widgets focused
- Separate logic from UI
- Follow @lib/features/shared/widgets/ structure

#### Widget Composition

```dart
// Prefer small composed widgets
class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [
          _UserAvatar(),
          _UserInfo(),
        ],
      ),
    );
  }
}
```

#### Common Widget Patterns

- Use `Builder` for context access
- Apply `LayoutBuilder` for responsive UI
- Use `FutureBuilder` for async data
- Apply `StreamBuilder` for streams
- Use `ValueListenableBuilder` for simple state
- Implement error boundaries
- Add loading states @lib/features/shared/widgets/loading_widget.dart
- Handle empty states @lib/features/shared/widgets/empty_state_widget.dart

### CI/CD pipeline best practices for Flutter applications including automated testing, code quality checks, build optimization, and deployment strategies across multiple platforms

#### Pipeline Structure

- Run on push/PR to main branches
- Use workflow dispatch for manual
- Set appropriate timeouts
- Cache dependencies properly
- Use matrix builds for platforms
- Fail fast on errors
- Keep jobs focused

#### Code Quality Gates

- Format check with `dart format`
- Static analysis with `flutter analyze`
- Check dependency updates
- Run lint rules @.github/workflows/lint.yml
- Verify code coverage thresholds
- Check for security vulnerabilities
- Validate commit messages

#### Testing Strategy

- Run tests in parallel
- Generate coverage reports
- Upload coverage to service
- Test on multiple Flutter versions
- Run integration tests separately
- Cache test results
- Report test failures clearly

#### Build Optimization

- Cache Flutter SDK
- Cache pub dependencies
- Use incremental builds
- Optimize build flags
- Separate debug/release builds
- Sign release builds properly
- Generate build artifacts

#### Environment Management

- Use environment variables
- Secure secrets properly
- Version Flutter SDK consistently
- Pin dependency versions
- Use build flavors
- Configure per environment
- Document env requirements

#### Deployment Process

- Build for target platforms
- Sign Android APK/AAB
- Sign iOS IPA properly
- Upload to stores automatically
- Create GitHub releases
- Tag versions correctly
- Generate changelogs

#### Workflow Best Practices

- Keep workflows DRY
- Use reusable workflows
- Monitor workflow performance
- Set up notifications
- Document workflow triggers
- Version control configs
- Review workflow changes

### Comprehensive testing strategies for Flutter applications including unit tests, widget tests, and integration tests following AAA pattern with high coverage targets

#### Testing Strategy

- Write tests before fixing bugs
- Follow Arrange-Act-Assert pattern
- Aim for 80%+ coverage
- Test edge cases thoroughly
- Keep tests independent
- Use descriptive test names
- Group related tests together

#### Unit Testing

- Test business logic isolation
- Mock external dependencies
- Test error scenarios
- Verify state transitions
- Test validators @lib/core/utils/validators.dart
- Test data transformations
- Use `package:test` for assertions

```dart
test('should validate email correctly', () {
  // Arrange
  const email = 'test@example.com';

  // Act
  final result = validateEmail(email);

  // Assert
  expect(result, isTrue);
});
```

#### Widget Testing

- Test UI components isolation
- Verify widget interactions
- Test widget state changes
- Mock dependencies with fakes
- Use `pumpWidget` for rendering
- Apply `pump` for animations
- Test golden files for UI

#### Integration Testing

- Test complete user flows
- Verify end-to-end scenarios
- Use `integration_test` package
- Test on real devices
- Cover critical paths first
- Test navigation flows
- Verify data persistence

#### Mocking Best Practices

- Prefer fakes over mocks
- Use `mocktail` when needed
- Avoid over-mocking
- Create test doubles
- Mock at boundaries only
- Keep mocks simple
- Document mock behavior

#### Test Organization

- Mirror source structure
- One test file per source
- Group by functionality
- Use clear test descriptions
- Separate unit/widget/integration
- Share test utilities
- Follow naming conventions

#### Testing Commands

- Run all: `flutter test`
- Coverage: `flutter test --coverage`
- Single file: `flutter test path/to/test.dart`
- Integration: `flutter test integration_test`
- Watch mode for TDD
- Use `checks` for assertions
- Profile test performance