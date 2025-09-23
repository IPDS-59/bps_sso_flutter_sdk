# Changelog

## [1.2.0] - 2025-09-23

### ✨ Features
- feat: implement intelligent token validation caching system (4604229)

### 🐛 Bug Fixes
- fix: resolve line length violations and add remaining constants (742ef66)

### 📱 Platform Updates


### 📚 Documentation
- docs(README): remove unnecessary changelog (63e6816)
- docs(README): update readme and workflow (38e0ccf)
- docs(CHANGELOG): update the changelog (58b7b2c)

### 🔧 Maintenance
- refactor(design): adjust status row text size (907d7bd)
- refactor: implement comprehensive SDK improvements and performance optimizations (5a815d4)
- chore: back-merge v1.1.0 release from main to develop (53a7042)
- chore: bump version to v1.2.0 for next development cycle (b416f65)

### 📦 Dependencies
- Flutter SDK: 3.35.3+
- Dart SDK: Compatible with Flutter 3.35.3

### 🎯 Key Highlights

### 📦 Dependencies
- Flutter SDK: 3.35.3+
- Dart SDK: Compatible with Flutter 3.35.3



## [1.1.0] - 2025-09-21

### ✨ Features
- feat(interceptor): add support for Dio HTTP interceptors for request/response modification (7f7e1b0)
- feat(di): initialize dependency injection with GetIt for better architecture (de3961a, 85e4f43)
- feat(di): configure dependencies and use router from dependency injection (3ca5d56)
- feat(sdk): add SDK info class to expose SDK version and metadata (e9e34bc, e4a55f0)
- feat(config): add custom realm names support with realmName parameter (ea84d7b)

### 🐛 Bug Fixes
- fix(service): add close tab functionality for iOS platform (a00079a)
- fix(url): fix realm URL typo in configuration (ebfe7ed)
- fix(android): enable desugaring for local notification support (1c24870)
- test(config): fix failing test configurations (0f057d5)

### 📱 Platform Updates
- refactor(package): update supported platforms configuration (64cb8ca)
- refactor(android): update app name configuration (a8f8299)
- refactor(ios): update iOS app name configuration (a93b5c0)
- chore(ios): run pod install for dependency updates (85e4f43)

### 📚 Documentation
- docs(README): comprehensive README updates with enhanced configuration documentation (db3e86e)
- docs(docs): update diagram images for better documentation (48fde72)

### 🔧 Maintenance
- refactor(config): enhance BPSRealmConfig with custom realm name support (ea84d7b, c436b1f)
- refactor(page): add realm input fields to configuration screen (a3cfd28)
- refactor(cubit): update configuration cubit for enhanced state management (c77240f)
- refactor(config-screen): add Alice HTTP inspector entry point (e4a55f0)
- refactor(config-cubit): integrate Alice Dio adapter for HTTP debugging (a38a383)
- refactor(page): enhance user info page design and widget extraction (fd43df4)
- style(page): improve home page design and layout (e3cffbf, ab4f254)
- style(code): run dart format for code consistency (432bd78)
- test(config): update SSO config tests for new features (735befc, 16fe4ba)
- ci(workflow): remove duplicate back merge job (3634808)
- chore: bump version to v1.1.0 for next development cycle (ebcf74c)

### 📦 Dependencies
- chore(pub): install Alice for HTTP request inspection and debugging (dd00cc3)
- Flutter SDK: 3.35.3+
- Dart SDK: Compatible with Flutter 3.35.3

### 🎯 Key Highlights
- **HTTP Interceptor Support**: Added comprehensive Dio interceptor support for request/response modification
- **Custom Realm Names**: Enhanced configuration to support custom realm names while maintaining backward compatibility
- **SDK Information Exposure**: Added SDK version and metadata access for client applications
- **Enhanced Configuration UI**: Improved configuration screen with realm name inputs and Alice integration
- **Better Architecture**: Implemented dependency injection for improved code organization
- **iOS Platform Improvements**: Enhanced iOS support with proper tab closing functionality



## [1.0.2] - 2025-09-21

### ✨ Features

### 🐛 Bug Fixes
- fix: resolve workflow issues for automatic publishing and back-merge conflicts (214ba9b)

### 📱 Platform Updates

### 📚 Documentation

### 🔧 Maintenance
- chore: prepare v1.0.2 hotfix (7f77713)

### 📦 Dependencies
- Flutter SDK: 3.35.3+
- Dart SDK: Compatible with Flutter 3.35.3

### 🎯 Key Highlights
- **Workflow Stability**: Fixed critical issues with GitHub Actions workflows for publishing and back-merge operations
- **CI/CD Improvements**: Enhanced workflow reliability for automated release processes



## [1.0.1] - 2025-09-21

### ✨ Features

### 🐛 Bug Fixes
- fix: resolve back-merge workflow fetch issue (a450929)

### 📱 Platform Updates

### 📚 Documentation

### 🔧 Maintenance
- refactor: eliminate duplicate analysis step in prepare-release workflow (8dd46b3)
- chore: prepare v1.0.1 hotfix (41ba38a)

### ⚡ Performance
- perf: optimize test coverage generation for faster CI runs (45cf20b)

### 📦 Dependencies
- Flutter SDK: 3.35.3+
- Dart SDK: Compatible with Flutter 3.35.3

### 🎯 Key Highlights
- **CI/CD Performance**: Optimized test coverage generation for faster continuous integration runs
- **Workflow Reliability**: Fixed critical back-merge workflow issues to ensure proper branch synchronization
- **Build Optimization**: Eliminated duplicate analysis steps to improve workflow efficiency



## [1.0.0] - 2025-09-21

### ✨ Features
- feat: add comprehensive GitHub issue templates (1ac16de)
- feat: add comprehensive PR template (c9763e9)
- feat: add comprehensive GitHub Actions workflow automation (847e3e1)
- feat: add smart GitHub Actions workflow with selective execution (553e159)
- feat: add comprehensive example application (e1087be)
- feat: enhance security and service layer (483e933)
- feat: add external user support and enhanced configuration (e3073d3)

### 🐛 Bug Fixes
- fix: update workflows to use PAT for PR creation (e42210f)
- fix: resolve all warnings in codebase (7fc3065)
- fix: add required permissions for CI workflow PR comments (f742d5b)
- fix: add missing iOS URL scheme configuration (0190d4b)

### 📱 Platform Updates

### 📚 Documentation
- docs: enhance documentation with Mermaid diagrams and references (7a95de8)
- docs: add comprehensive documentation and license (5fbb516)
- docs: update documentation with new features (faae1f0)

### 🔧 Maintenance
- chore: update Flutter version to 3.35.3 in all workflows (e08d254)
- test: add comprehensive unit tests for BPS SSO SDK (b5707ba)
- chore: add VS Code launch configuration (58399f8)
- chore: configure platform settings and cleanup (00a6f32)

### 🔄 Migration Guide
- This is a major version release
- Please review the breaking changes above
- Update your dependencies and test thoroughly

### 📦 Dependencies
- Flutter SDK: 3.35.3+
- Dart SDK: Compatible with Flutter 3.35.3



* TODO: Describe initial release.
