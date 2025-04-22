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

# Create necessary directories and files if they don't exist
mkdir -p assets/images
if [ ! -f ".env" ]; then
  echo "Creating .env file..."
  cat > .env << 'EOL'
# API Configuration
API_KEY=your_api_key_here
API_BASE_URL=https://newsapi.org/v2

# App Configuration
APP_NAME=News App
APP_VERSION=1.0.0
EOL
fi

echo "Building web app..."
flutter build web --release

echo "Creating public directory..."
mkdir -p public

echo "Copying Flutter web assets to public directory..."
cp -r build/web/* public/

echo "Build completed. Listing public directory contents:"
ls -la public/

# Ensure all files are readable
chmod -R 755 public

# Create a simple index.html if it doesn't exist
if [ ! -f "build/web/index.html" ]; then
  echo "Creating index.html..."
  cat > build/web/index.html << 'EOL'
<!DOCTYPE html>
<html>
<head>
  <base href="/">
  <meta charset="UTF-8">
  <title>News App</title>
</head>
<body>
  <div id="flutter_app"></div>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
EOL
fi 