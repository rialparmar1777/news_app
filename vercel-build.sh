#!/bin/bash

# Exit on error
set -e

echo "Setting up Flutter web assets..."

# Create public directory if it doesn't exist
mkdir -p public

# Check if Flutter is installed
if command -v flutter &> /dev/null; then
    echo "Flutter is installed. Building Flutter web assets..."
    flutter build web --release
    cp -r build/web/* public/
else
    echo "Flutter is not installed in the build environment."
    echo "Using pre-built Flutter web assets from the repository..."
    
    # Check if the pre-built assets exist in the repository
    if [ -d "build/web" ]; then
        echo "Found pre-built assets in build/web directory."
        cp -r build/web/* public/
    else
        echo "Error: No pre-built Flutter web assets found."
        echo "Please build the Flutter web app locally and commit the build/web directory to your repository."
        exit 1
    fi
fi

echo "Flutter web assets setup completed successfully!" 