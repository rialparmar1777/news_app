#!/bin/bash

# Clean previous build
rm -rf build/web

# Build the Flutter web app
flutter build web --release --base-href /

# Ensure proper permissions
chmod -R 755 build/web

echo "Build completed successfully!" 