# KeyboardShortcuts Package Setup Instructions

## Step-by-Step Guide to Add KeyboardShortcuts Package

### Option 1: Via Xcode (Recommended)

1. **Open Project in Xcode**
   ```bash
   open QuitAll.xcodeproj
   ```

2. **Add Package Dependency**
   - In Xcode, go to: `File` → `Add Package Dependencies...`
   - Or: Select project in navigator → Select "QuitAll" target → "Package Dependencies" tab → Click "+"

3. **Enter Package URL**
   ```
   https://github.com/sindresorhus/KeyboardShortcuts
   ```

4. **Select Version**
   - Dependency Rule: "Up to Next Major Version"
   - Version: `2.4.0` (or latest)

5. **Add to Target**
   - Ensure "QuitAll" target is selected
   - Click "Add Package"

6. **Verify Installation**
   - Package should appear in project navigator under "Package Dependencies"
   - `Package.resolved` file created in project
   - Build project to verify: `Cmd+B`

### Option 2: Via Command Line

If you want to add the package without opening Xcode:

1. **Create Package.swift (if using SPM directly)**
   Not applicable for Xcode projects - use Option 1

2. **Manual project.pbxproj editing (NOT RECOMMENDED)**
   Too error-prone, use Xcode GUI instead

### Verification Steps

After adding package:

```bash
# 1. Check package resolved
cat QuitAll.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# 2. Build project
xcodebuild -project QuitAll.xcodeproj -scheme QuitAll -configuration Release clean build

# 3. Verify import works
# Create test file or check existing file can import KeyboardShortcuts
```

### Expected Package.resolved Content

```json
{
  "pins" : [
    {
      "identity" : "keyboardshortcuts",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/sindresorhus/KeyboardShortcuts",
      "state" : {
        "revision" : "...",
        "version" : "2.4.0"
      }
    }
  ],
  "version" : 2
}
```

### Troubleshooting

**Problem: Package won't resolve**
- Solution: Xcode → File → Packages → Reset Package Caches
- Then: File → Packages → Resolve Package Versions

**Problem: Build errors after adding package**
- Solution: Clean build folder (`Cmd+Shift+K`)
- Then: Build again (`Cmd+B`)

**Problem: "No such module 'KeyboardShortcuts'"**
- Solution: Ensure package is added to correct target
- Check: Project → Target → General → "Frameworks, Libraries, and Embedded Content"

### Next Steps After Package Installation

1. Verify package import works:
   ```swift
   import KeyboardShortcuts
   ```

2. Proceed to implement HotkeyManager (see tasks.md Task 2.1)

3. Update Info.plist with permission description (see tasks.md Task 1.2)
