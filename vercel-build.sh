#!/bin/bash

# Exit on error
set -e

echo "Building Flutter web assets..."

# Build Flutter web
flutter build web --release

# Create public directory if it doesn't exist
mkdir -p public

# Copy Flutter web assets to public directory
cp -r build/web/* public/

echo "Flutter web build completed successfully!" 