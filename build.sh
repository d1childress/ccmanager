#!/bin/bash

# CC Manager Build Script
# Builds the macOS app for distribution

set -e

echo "🚀 Building CC Manager for macOS..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf ccmanager.app

# Build in release mode
echo "🔨 Building release version..."
swift build -c release --arch arm64 --arch x86_64

# Create app bundle structure
echo "📦 Creating app bundle..."
mkdir -p ccmanager.app/Contents/MacOS
mkdir -p ccmanager.app/Contents/Resources

# Copy executable
cp .build/apple/Products/Release/ccmanager ccmanager.app/Contents/MacOS/

# Create Info.plist
cat > ccmanager.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ccmanager</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourcompany.ccmanager</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>CC Manager</string>
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
echo "📍 App location: ./ccmanager.app"
echo ""
echo "To run the app:"
echo "  open ccmanager.app"
echo ""
echo "To create a DMG for distribution:"
echo "  hdiutil create -volname ccmanager -srcfolder ccmanager.app -ov -format UDZO ccmanager.dmg"