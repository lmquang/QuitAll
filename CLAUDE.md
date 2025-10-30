# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuitAll is a macOS menu bar utility that allows users to quickly quit all running applications with whitelist support. Built with Swift using a hybrid AppKit/SwiftUI architecture, it runs as a menu bar-only app (LSUIElement = true) without a Dock icon.

**Key Constraints:**
- Cannot use Mac App Store (requires disabling App Sandbox to quit other apps)
- Must use Hardened Runtime and Developer ID signing for distribution
- Requires NSWorkspace API access to manage other applications
- Distribution: Direct download or third-party stores only

## Build & Development Commands

### Building the Application

```bash
# Quick build and install (recommended)
./scripts/build-app.sh

# Manual build (Release configuration)
xcodebuild \
    -project QuitAll.xcodeproj \
    -scheme QuitAll \
    -configuration Release \
    -derivedDataPath build \
    clean build

# For local testing (no code signing)
xcodebuild \
    -project QuitAll.xcodeproj \
    -scheme QuitAll \
    -configuration Release \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    clean build
```

### Running & Testing

```bash
# Open project in Xcode
open QuitAll.xcodeproj

# Run from Xcode: Product → Run (Cmd+R)
# Build scheme: QuitAll
# Target: Any Mac

# Run standalone app
open /Applications/QuitAll.app

# Remove Gatekeeper quarantine (if needed)
xattr -cr /Applications/QuitAll.app
```

### Testing

```bash
# Run unit tests
xcodebuild test \
    -project QuitAll.xcodeproj \
    -scheme QuitAll \
    -destination 'platform=macOS'

# Tests are located in:
# - QuitAllTests/ (unit tests)
# - QuitAllUITests/ (UI tests)
```

## Architecture Overview

### Three-Layer Hybrid Architecture

1. **Platform Layer (AppKit)**: Application lifecycle, menu bar integration
   - `QuitAllApp.swift`: @main entry point
   - `AppDelegate.swift`: NSStatusItem, NSPopover management, AppKit bridge

2. **Business Logic Layer (Framework-agnostic)**: State management and business rules
   - `Managers/AppManager.swift`: NSWorkspace wrapper, running apps list
   - `Managers/QuitManager.swift`: Quit logic, error handling, timeouts
   - `Managers/WhitelistManager.swift`: Persistent/temporary whitelist, UserDefaults
   - `Managers/PreferencesManager.swift`: User preferences persistence
   - `Managers/SystemProtection.swift`: Critical app safety checks

3. **Presentation Layer (SwiftUI)**: User interface
   - `Views/ContentView.swift`: Main popover content
   - `Views/AppListView.swift`: Running apps list with toggles
   - `Views/SettingsView.swift`: Preferences UI
   - `Views/QuitAllButton.swift`: Main action button
   - `Views/AppRowView.swift`: Individual app row

### Key Architectural Patterns

**State Management:**
- All managers inherit from `ObservableObject`
- Views observe managers via `@ObservedObject`
- State flows unidirectionally: Manager → View
- User actions flow: View → Manager methods

**Dependency Flow:**
```
AppDelegate (owns all managers)
  └─> Creates and injects into ContentView
      └─> ContentView passes to child views
```

**Critical System Protection:**
- `SystemProtection` maintains hardcoded list of critical apps:
  - Finder, Dock, SystemUIServer, WindowServer, LoginWindow
  - QuitAll itself (never quit self)
- Always validate with `SystemProtection.canQuit()` before quitting
- System apps are filtered out from the app list entirely

## Code Conventions & Patterns

### Manager Pattern
All managers follow this structure:
```swift
final class XxxManager: ObservableObject {
    // Published state
    @Published private(set) var state: Type = defaultValue

    // Public interface methods
    func doSomething() { }

    // Private implementation
    private func helperMethod() { }
}
```

### Error Handling
- Use `Result<Void, Error>` types for operations that can fail
- Define custom error enums (e.g., `QuitManager.QuitError`)
- Log errors with emoji prefixes for easy scanning: ✅❌⚠️🛡️
- Never crash on recoverable errors

### Logging Conventions
```swift
print("🚀 App launched")     // Startup events
print("✅ Success")           // Successful operations
print("❌ Failed")            // Errors
print("⚠️ Warning")           // Warnings
print("🛡️ Protected")         // Security/protection
print("🚪 Quitting")          // Quit operations
print("▶️ Starting")          // Start operations
print("⏸️ Stopping")          // Stop operations
```

### Documentation
- All manager classes reference specs: `// See SPEC-002: Manager Layer`
- Complex methods include inline comments explaining the "why"
- ADRs (Architecture Decision Records) document major decisions
- Comprehensive documentation exists in `docs/sessions/202510301345-quit-all-apps/`

## Important Implementation Details

### Menu Bar App Lifecycle
1. App starts → AppDelegate creates NSStatusItem
2. User clicks icon → Create NSPopover (lazy initialization)
3. Popover shown → ContentView.onAppear() → AppManager.startRefreshing()
4. Popover hidden → AppManager.stopRefreshing() (saves CPU/memory)
5. Option-click or right-click → Show context menu

### Quit Flow with Safety
```swift
// Always check protection first
guard SystemProtection.canQuit(app) else { return }

// Try graceful quit
guard app.terminate() else {
    // Handle permission denied
    return
}

// Wait with timeout (5 seconds)
// Poll every 0.5s to check app.isTerminated
// After timeout, offer force quit option
```

### Whitelist System
- **Persistent whitelist**: Saved to UserDefaults, survives app restart
- **Temporary whitelist**: In-memory only, cleared on app restart
- Default system apps are always whitelisted and cannot be removed
- Whitelist checked before quitting: `whitelistManager.isWhitelisted(bundleID:)`

### Real-time App Monitoring
AppManager uses dual approach:
1. **Timer-based**: Refresh every 1 second when popover is visible
2. **Notification-based**: NSWorkspace notifications for launches/quits
   - `didLaunchApplicationNotification`
   - `didTerminateApplicationNotification`
   - `didActivateApplicationNotification`

### Performance Targets
- Memory (idle): <20MB (popover not created)
- Memory (active): <50MB (popover shown, refreshing)
- CPU (idle): <0.5% (no timers)
- CPU (active): <3% (1s refresh timer)

## Info.plist Critical Settings

**Required:**
```xml
<key>LSUIElement</key>
<true/>  <!-- Menu bar only, no Dock icon -->

<key>CFBundleIdentifier</key>
<string>dwr.QuitAll</string>  <!-- Update SystemProtection if changed -->

<key>LSMinimumSystemVersion</key>
<string>12.0</string>  <!-- macOS Monterey+ -->
```

## Security & Distribution

### Xcode Project Settings
- **App Sandbox**: DISABLED (requirement - cannot quit other apps with sandbox)
- **Hardened Runtime**: ENABLED (required for notarization)
- **Code Signing**: Developer ID Application certificate

### Distribution Checklist
```bash
# 1. Build Release version
xcodebuild -project QuitAll.xcodeproj -scheme QuitAll -configuration Release clean build

# 2. Sign with Developer ID
codesign --force --deep \
    --sign "Developer ID Application: Your Name (TEAM_ID)" \
    --options runtime \
    --timestamp \
    QuitAll.app

# 3. Verify signature
codesign --verify --deep --strict --verbose=2 QuitAll.app

# 4. Create archive
ditto -c -k --keepParent QuitAll.app QuitAll.zip

# 5. Notarize (requires Apple Developer account)
xcrun notarytool submit QuitAll.zip \
    --apple-id your@email.com \
    --password "app-specific-password" \
    --team-id TEAM_ID \
    --wait

# 6. Staple ticket
xcrun stapler staple QuitAll.app

# 7. Verify
spctl -a -vv QuitAll.app
```

## File Organization

```
QuitAll/
├── QuitAll/                    # Main app code
│   ├── QuitAllApp.swift        # Entry point
│   ├── AppDelegate.swift       # AppKit bridge
│   ├── Managers/               # Business logic (5 managers)
│   ├── Models/                 # Data models (AppInfo, Preferences, etc.)
│   ├── Views/                  # SwiftUI views (5 views)
│   ├── Assets.xcassets         # Icons and images
│   ├── Info.plist              # App configuration
│   └── QuitAll.entitlements    # Security entitlements
├── QuitAllTests/               # Unit tests
├── QuitAllUITests/             # UI tests
├── docs/                       # Comprehensive documentation
│   └── sessions/202510301345-quit-all-apps/
│       ├── planning/           # Specs, ADRs
│       ├── research/           # API research, quick reference
│       └── test-cases/         # Test plans
├── scripts/
│   └── build-app.sh            # Automated build script
└── QuitAll.xcodeproj/          # Xcode project

# Important: xcshareddata/ should be committed (shared schemes)
# xcuserdata/ is in .gitignore (user-specific settings)
```

## Testing Guidelines

### Unit Testing Focus
- Test all manager methods independently
- Mock NSWorkspace and UserDefaults for isolation
- Focus on business logic, not UI
- Test error conditions and edge cases

### Key Test Scenarios
1. **SystemProtection**: Verify critical apps are protected
2. **WhitelistManager**: Persistence, add/remove, defaults
3. **QuitManager**: Graceful quit, timeout, force quit
4. **AppManager**: Filtering, sorting, monitoring

### Manual Testing Checklist
- [ ] Menu bar icon appears and is clickable
- [ ] Popover shows/hides on click
- [ ] Running apps list updates in real-time
- [ ] Whitelist toggles persist across restarts
- [ ] System apps cannot be quit (Finder, Dock)
- [ ] App never quits itself
- [ ] Force quit works after timeout
- [ ] Works in light and dark mode
- [ ] Clean Mac test (no Xcode installed)

## Common Development Tasks

### Adding a New Manager
1. Create `Managers/NewManager.swift`
2. Inherit from `ObservableObject`
3. Add `@Published` properties for state
4. Create instance in `AppDelegate`
5. Inject into `ContentView` initializer
6. Create unit tests in `QuitAllTests/`

### Adding System Protection for New App
Update `SystemProtection.criticalBundleIdentifiers`:
```swift
private static let criticalBundleIdentifiers: Set<String> = [
    "com.apple.finder",
    "com.apple.dock",
    // Add new protected app
    "com.example.critical.app",
]
```

### Changing Bundle Identifier
1. Update in Xcode project settings
2. Update `Info.plist` CFBundleIdentifier
3. Update `SystemProtection.criticalBundleIdentifiers` (add new ID)
4. Test that app protects itself

## Debugging Tips

### Common Issues

**"App is damaged" error:**
```bash
xattr -cr /Applications/QuitAll.app
```

**App doesn't quit other apps:**
- Check App Sandbox is DISABLED
- Verify Info.plist has correct settings
- Check console logs for permission errors

**Menu bar icon doesn't appear:**
- Verify LSUIElement = true in Info.plist
- Check AppDelegate.setupStatusItem() is called
- Look for NSStatusItem creation logs

**Popover doesn't show:**
- Check popover initialization in AppDelegate
- Verify NSHostingController is created
- Check button action is wired correctly

### Debug Logging
```swift
// Enable detailed logging (already in code)
#if DEBUG
appManager.printStatus()
quitManager.printStatus()
#endif
```

## Related Documentation

Extensive documentation exists in `docs/sessions/202510301345-quit-all-apps/`:
- **research/**: NSWorkspace API, quit strategies, menu bar architecture
- **planning/specifications/**: SPEC-001 through SPEC-007 (detailed component specs)
- **planning/ADRs/**: ADR-001 through ADR-006 (architecture decisions)
- **test-cases/**: Unit, integration, and manual test plans
- **research/QUICK-REFERENCE.md**: Code snippets and quick lookup

## API References

- [NSWorkspace](https://developer.apple.com/documentation/appkit/nsworkspace) - Running app enumeration
- [NSRunningApplication](https://developer.apple.com/documentation/appkit/nsrunningapplication) - App control
- [NSStatusItem](https://developer.apple.com/documentation/appkit/nsstatusitem) - Menu bar integration
- [NSPopover](https://developer.apple.com/documentation/appkit/nspopover) - Popover UI
- [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) - Persistence
