#!/bin/bash

# Exit on any error
set -e

echo "Current directory: $(pwd)"
echo "Listing directory contents:"
ls -la

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:$(pwd)/flutter/bin"

echo "Flutter version:"
flutter --version

echo "Enabling Flutter web..."
flutter config --enable-web

echo "Running Flutter doctor..."
flutter doctor -v

echo "Getting dependencies..."
flutter pub get

echo "Building web app..."
flutter build web --release

echo "Build completed. Listing build/web contents:"
ls -la build/web 