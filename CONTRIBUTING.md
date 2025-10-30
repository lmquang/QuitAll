# Contributing to QuitAll

First off, thank you for considering contributing to QuitAll! It's people like you that make QuitAll such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by common sense and mutual respect. By participating, you are expected to uphold this principle.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [existing issues](https://github.com/lmquang/QuitAll/issues) to avoid duplicates.

When creating a bug report, please include:
- A clear, descriptive title
- Exact steps to reproduce the problem
- Expected behavior vs actual behavior
- macOS version, QuitAll version, and processor type
- Screenshots if applicable
- Console logs from Console.app (filter for "QuitAll")

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md) when filing bugs.

### Suggesting Enhancements

Enhancement suggestions are tracked as [GitHub issues](https://github.com/lmquang/QuitAll/issues).

When creating an enhancement suggestion, please include:
- A clear, descriptive title
- A detailed description of the proposed feature
- The problem it solves
- Any alternative solutions you've considered
- Mockups or examples (if applicable)

Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md) when suggesting features.

### Pull Requests

#### Development Setup

1. **Fork and clone the repo:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/QuitAll.git
   cd QuitAll
   ```

2. **Open in Xcode:**
   ```bash
   open QuitAll.xcodeproj
   ```

3. **Read the architecture docs:**
   - [CLAUDE.md](CLAUDE.md) - Development guidelines and architecture
   - [docs/BUILD.md](docs/BUILD.md) - Build instructions
   - [docs/sessions/202510301345-quit-all-apps/planning/](docs/sessions/202510301345-quit-all-apps/planning/) - Detailed specs and ADRs

#### Coding Standards

**Architecture:**
- Follow the three-layer architecture (Platform/Business Logic/Presentation)
- All managers must inherit from `ObservableObject`
- Keep business logic framework-agnostic (no SwiftUI in managers)

**Code Style:**
```swift
// Manager pattern
final class NewManager: ObservableObject {
    @Published private(set) var state: Type = defaultValue

    func doSomething() {
        // Implementation
    }

    private func helperMethod() {
        // Private helpers
    }
}

// Logging with emojis
print("🚀 Starting...")   // Startup
print("✅ Success")       // Success
print("❌ Failed")        // Errors
print("⚠️ Warning")       // Warnings
print("🛡️ Protected")     // Security
```

**Documentation:**
```swift
// Reference specs and ADRs
// See SPEC-002: Manager Layer
// See ADR-001: Hybrid Architecture

/// Brief description
/// - Parameter param: Description
/// - Returns: Description
func method(param: Type) -> ReturnType {
    // Implementation
}
```

**Testing:**
- Write unit tests for all manager methods
- Test error conditions and edge cases
- Use dependency injection for mocking
- Place tests in `QuitAllTests/`

#### Pull Request Process

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make your changes:**
   - Follow the coding standards above
   - Write tests for new functionality
   - Update documentation if needed
   - Test on both Intel and Apple Silicon (if possible)

3. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Add amazing feature"
   ```

   Use clear commit messages:
   - `feat: Add keyboard shortcuts`
   - `fix: Resolve app list refresh issue`
   - `docs: Update installation instructions`
   - `test: Add whitelist manager tests`
   - `refactor: Improve quit logic`

4. **Push to your fork:**
   ```bash
   git push origin feature/amazing-feature
   ```

5. **Open a Pull Request:**
   - Provide a clear description of the changes
   - Reference any related issues
   - Include screenshots for UI changes
   - List any breaking changes

6. **Code Review:**
   - Address feedback from maintainers
   - Make requested changes in new commits
   - Keep discussion focused and professional

7. **Merge:**
   - Once approved, your PR will be merged
   - Your contribution will be credited in release notes

#### PR Checklist

- [ ] Code follows the project's style guidelines
- [ ] Self-review of code performed
- [ ] Comments added for complex logic
- [ ] Documentation updated (if applicable)
- [ ] No new warnings generated
- [ ] Tests added/updated and passing
- [ ] Tested on macOS 12+ (if possible)
- [ ] Screenshots included (for UI changes)

### First Time Contributors

Looking for a good first issue? Check out issues labeled [`good first issue`](https://github.com/lmquang/QuitAll/labels/good%20first%20issue) or [`help wanted`](https://github.com/lmquang/QuitAll/labels/help%20wanted).

**Easy Starter Tasks:**
- Improve documentation
- Add code comments
- Write unit tests
- Fix typos
- Update dependencies

## Development Workflow

### Project Structure
```
QuitAll/
├── QuitAll/              # Main app code
│   ├── QuitAllApp.swift  # Entry point
│   ├── AppDelegate.swift # AppKit bridge
│   ├── Managers/         # Business logic (5 managers)
│   ├── Models/           # Data models
│   └── Views/            # SwiftUI views
├── QuitAllTests/         # Unit tests
├── docs/                 # Documentation
└── scripts/              # Build scripts
```

### Key Files to Know

**Core App:**
- `AppDelegate.swift` - Menu bar setup, popover management
- `Managers/AppManager.swift` - Running apps list
- `Managers/QuitManager.swift` - Quit logic
- `Managers/WhitelistManager.swift` - Persistence
- `Managers/SystemProtection.swift` - Safety checks

**Documentation:**
- `CLAUDE.md` - Architecture and conventions
- `docs/BUILD.md` - Build instructions
- `docs/sessions/.../planning/specifications/` - Component specs
- `docs/sessions/.../planning/ADRs/` - Architecture decisions

### Building & Testing

```bash
# Build release version
./scripts/build-app.sh

# Run tests
xcodebuild test \
    -project QuitAll.xcodeproj \
    -scheme QuitAll \
    -destination 'platform=macOS'

# Run in Xcode
open QuitAll.xcodeproj
# Press Cmd+R
```

### Debugging

```bash
# View logs
log stream --predicate 'subsystem contains "QuitAll"' --level debug

# Check Console.app
# Filter: "QuitAll"
```

## Common Development Tasks

### Adding a New Manager

1. Create `Managers/NewManager.swift`
2. Inherit from `ObservableObject`
3. Add `@Published` properties
4. Create instance in `AppDelegate`
5. Inject into `ContentView`
6. Write tests in `QuitAllTests/`

### Adding System Protection

Update `SystemProtection.criticalBundleIdentifiers`:
```swift
private static let criticalBundleIdentifiers: Set<String> = [
    "com.apple.finder",
    "com.apple.dock",
    "com.example.critical.app",  // Add here
]
```

### Modifying the UI

1. Locate view in `Views/`
2. Make changes following SwiftUI best practices
3. Update related managers if needed
4. Test in light and dark mode
5. Take screenshots for PR

## Questions?

- Open an issue with the `question` label
- Email: [your-email@example.com](mailto:your-email@example.com)
- Check existing documentation in [docs/](docs/)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be:
- Listed in release notes
- Credited in the project (if desired)
- Acknowledged in the community

Thank you for contributing to QuitAll! 🎉
