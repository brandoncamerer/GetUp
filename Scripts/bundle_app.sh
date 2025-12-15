#!/bin/bash

APP_NAME="GetUp"
BUILD_DIR=".build/debug"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

# Build the project
swift build

# Create directories
mkdir -p "$MACOS_DIR"

# Copy binary
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# Copy Info.plist
cp "Info.plist" "$CONTENTS_DIR/"

# Sign the app (ad-hoc)
codesign --force --deep --sign - "$APP_BUNDLE"

echo "App bundled at $APP_BUNDLE"
