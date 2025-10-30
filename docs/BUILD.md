# Building QuitAll as a Standalone Application

This guide explains how to build QuitAll as a standalone macOS application that runs independently of Xcode.

## Quick Start (Recommended)

### Using the Build Script

The easiest way to build and install QuitAll is using the provided build script:

```bash
./scripts/build-app.sh
```

This script will:
1. Clean previous builds
2. Build the app in Release mode
3. Ask if you want to copy it to /Applications
4. Optionally clean up build artifacts

## Manual Build Methods

### Method 1: Command Line Build

```bash
# Build in Release mode
xcodebuild \
    -project QuitAll.xcodeproj \
    -scheme QuitAll \
    -configuration Release \
    -derivedDataPath build \
    clean build

# Find and copy the built app
find build -name "QuitAll.app" -type d | head -n 1 | xargs -I {} cp -R {} /Applications/
```

### Method 2: Xcode GUI

1. Open the project:
   ```bash
   open QuitAll.xcodeproj
   ```

2. In Xcode:
   - Select **Product → Scheme → QuitAll**
   - Choose **Any Mac** as destination
   - Select **Product → Archive**
   - Wait for archive to complete

3. In the Organizer window:
   - Click **Distribute App**
   - Select **Copy App**
   - Choose destination folder
   - Click **Export**

4. Move to Applications:
   ```bash
   mv ~/Desktop/QuitAll.app /Applications/
   ```

## Running the Standalone App

Once built and copied to /Applications, you can:

1. **Launch from Spotlight**: Press `Cmd+Space`, type "QuitAll", press Enter

2. **Launch from Finder**:
   - Open Applications folder
   - Double-click QuitAll.app

3. **Launch from Terminal**:
   ```bash
   open /Applications/QuitAll.app
   ```

## Build Configurations

### Debug vs Release

- **Debug**: Includes debugging symbols, slower performance
- **Release**: Optimized for performance, smaller binary size

For distribution, always use **Release** configuration.

## Troubleshooting

### "App is damaged and can't be opened"

If you see this error, it's due to Gatekeeper. Fix it with:

```bash
xattr -cr /Applications/QuitAll.app
```

### App doesn't appear in Applications

1. Check if the build was successful
2. Verify the app exists in the build directory
3. Manually copy the app:
   ```bash
   cp -R build/Build/Products/Release/QuitAll.app /Applications/
   ```

### Code Signing Issues

If you encounter code signing errors, you can disable signing for local builds:

```bash
xcodebuild \
    -project QuitAll.xcodeproj \
    -scheme QuitAll \
    -configuration Release \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    clean build
```

## Distribution

### For Personal Use

The methods above create an unsigned app suitable for personal use on your Mac.

### For Public Distribution

For distributing to other users, you need:

1. **Apple Developer Account** (paid)
2. **Code Signing Certificate**
3. **Notarization** (for macOS 10.15+)

Steps:
1. Archive the app in Xcode
2. Distribute with Developer ID
3. Notarize with Apple
4. Staple the notarization ticket

## Continuous Integration

For automated builds, see the build script at `scripts/build-app.sh` which can be integrated into CI/CD pipelines.

## Additional Resources

- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Distributing Your App](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
