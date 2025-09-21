# Contributing to BPS SSO SDK

Thank you for your interest in contributing to the BPS SSO SDK! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Release Process](#release-process)

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect differing opinions and approaches
- Report unacceptable behavior to project maintainers

## Getting Started

### Prerequisites

- Flutter SDK 3.35.3+
- Dart SDK 3.5.0+
- Git
- IDE with Flutter support (VS Code, Android Studio, IntelliJ)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/bps_sso_flutter_sdk.git
   cd bps_sso_flutter_sdk
   ```

3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/IPDS-59/bps_sso_flutter_sdk.git
   ```

### Environment Setup

1. Install dependencies:
   ```bash
   flutter pub get
   cd example && flutter pub get && cd ..
   ```

2. Run tests to ensure everything works:
   ```bash
   flutter test
   ```

3. Run the example app:
   ```bash
   cd example && flutter run
   ```

## Development Workflow

We follow **Git Flow** branching model:

### Branch Types

- `main` - Production-ready code, tagged releases
- `develop` - Integration branch for features
- `feature/*` - New features and enhancements
- `release/*` - Release preparation
- `hotfix/*` - Critical fixes for production

### Workflow Steps

1. **Start from develop:**
   ```bash
   git checkout develop
   git pull upstream develop
   ```

2. **Create feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes and commit:**
   ```bash
   git add .
   git commit -m "feat: add new authentication method"
   ```

4. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request** to `develop` branch

### Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes

**Examples:**
```bash
feat: add support for external user authentication
fix: resolve token refresh issue on iOS
docs: update installation instructions
test: add unit tests for security manager
```

## Coding Standards

### Dart/Flutter Guidelines

1. **Follow official Dart style guide**
2. **Use `dart format` for consistent formatting**
3. **Run `flutter analyze` and fix all warnings**
4. **Use meaningful variable and function names**
5. **Add documentation comments for public APIs**

### Code Structure

```
lib/
├── src/
│   ├── config/          # Configuration classes
│   ├── models/          # Data models
│   ├── security/        # Security utilities
│   ├── services/        # Core services
│   └── exceptions/      # Custom exceptions
└── bps_sso_sdk.dart    # Main export file
```

### Documentation

- Add dartdoc comments for all public APIs
- Include usage examples in documentation
- Update README.md for significant changes

### Example:

```dart
/// Manages BPS SSO authentication flows.
///
/// This service handles both internal (BPS employee) and external user
/// authentication using OAuth2/OpenID Connect protocols.
///
/// Example usage:
/// ```dart
/// final service = BPSSsoService(config);
/// final user = await service.authenticate(BPSRealmType.internal);
/// ```
class BPSSsoService {
  // Implementation
}
```

## Testing Guidelines

### Test Structure

- **Unit tests** for individual components
- **Integration tests** for service interactions
- **Widget tests** for UI components (example app)

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/bps_sso_service_test.dart
```

### Test Requirements

- **Minimum 80% code coverage**
- **Test all public APIs**
- **Include edge cases and error scenarios**
- **Use descriptive test names**

### Test Example

```dart
group('BPSSsoService', () {
  late BPSSsoService service;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    service = BPSSsoService(mockConfig, httpClient: mockClient);
  });

  group('authenticate', () {
    test('should return user when authentication succeeds', () async {
      // Arrange
      when(mockClient.post(any, body: any, headers: any))
          .thenAnswer((_) async => http.Response(mockUserJson, 200));

      // Act
      final result = await service.authenticate(BPSRealmType.internal);

      // Assert
      expect(result, isA<BPSUser>());
      expect(result.isInternal, isTrue);
    });
  });
});
```

## Pull Request Process

### Before Creating PR

1. **Sync with upstream:**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout your-feature-branch
   git rebase develop
   ```

2. **Run quality checks:**
   ```bash
   flutter analyze
   flutter test
   dart format lib/ test/ example/lib/
   ```

3. **Update documentation if needed**

### PR Requirements

- [ ] **Descriptive title and description**
- [ ] **Links to related issues**
- [ ] **All CI checks passing**
- [ ] **Code review by at least one maintainer**
- [ ] **Tests included for new functionality**
- [ ] **Documentation updated**

### PR Template

Our repository includes a PR template that covers:

- Summary of changes
- Type of change (feature, fix, docs, etc.)
- Testing performed
- Checklist of requirements

## Issue Reporting

### Bug Reports

Include the following information:

- **Flutter/Dart version**
- **Platform (iOS/Android)**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Error logs/stack traces**
- **Minimal code example**

### Feature Requests

- **Clear description of the feature**
- **Use case and benefits**
- **Proposed API design (if applicable)**
- **Willingness to implement**

### Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to docs
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `question` - Further information requested

## Release Process

### Automated Release Workflow

Our CI/CD handles releases automatically:

1. **Create release branch:** `release/v1.2.0`
2. **Version bump** occurs automatically
3. **Merge to main** creates tag and triggers publish
4. **Back-merge** to develop synchronizes changes

### Manual Release Steps

1. **Create release branch:**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout -b release/v1.2.0
   ```

2. **Update version in pubspec.yaml**

3. **Update CHANGELOG.md**

4. **Create PR to main branch**

5. **After merge, tag is created automatically**

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- `MAJOR.MINOR.PATCH`
- `MAJOR` - Breaking changes
- `MINOR` - New features (backward compatible)
- `PATCH` - Bug fixes (backward compatible)

## Development Tools

### Recommended VS Code Extensions

- Dart
- Flutter
- GitLens
- Bracket Pair Colorizer
- Auto Rename Tag

### Useful Commands

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests with coverage
flutter test --coverage

# Generate documentation
dart doc

# Clean build
flutter clean && flutter pub get

# Check outdated dependencies
flutter pub outdated
```

## Getting Help

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Questions and community support
- **Code Review** - Ask maintainers for guidance
- **Documentation** - Check existing docs and examples

## Recognition

Contributors will be recognized in:

- **CHANGELOG.md** for significant contributions
- **README.md** contributors section
- **GitHub releases** notes
- **pub.dev** package page

Thank you for contributing to the BPS SSO SDK! 🚀
