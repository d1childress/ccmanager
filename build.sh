#!/bin/bash

# Claude Manager Build Script
# Builds the macOS app for distribution

set -e

echo "🚀 Building Claude Manager for macOS..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf ClaudeManager.app

# Build in release mode
echo "🔨 Building release version..."
swift build -c release --arch arm64 --arch x86_64

# Create app bundle structure
echo "📦 Creating app bundle..."
mkdir -p ClaudeManager.app/Contents/MacOS
mkdir -p ClaudeManager.app/Contents/Resources

# Copy executable
cp .build/apple/Products/Release/ClaudeManager ClaudeManager.app/Contents/MacOS/

# Create Info.plist
cat > ClaudeManager.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ClaudeManager</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourcompany.claudemanager</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Claude Manager</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Build complete!"
echo "📍 App location: ./ClaudeManager.app"
echo ""
echo "To run the app:"
echo "  open ClaudeManager.app"
echo ""
echo "To create a DMG for distribution:"
echo "  hdiutil create -volname ClaudeManager -srcfolder ClaudeManager.app -ov -format UDZO ClaudeManager.dmg"