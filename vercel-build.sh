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

# Create necessary directories and files
echo "Setting up project structure..."
mkdir -p assets/images
mkdir -p web/assets/images
touch assets/images/.gitkeep
touch web/assets/images/.gitkeep

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
  echo "Creating .env file..."
  cat > .env << 'EOL'
# API Configuration
API_KEY=7911212b47fd4131aeb437134c3f9c36
API_BASE_URL=https://newsapi.org/v2

# App Configuration
APP_NAME=News App
APP_VERSION=1.0.0
EOL
fi

# Copy .env to web directory
cp .env web/.env

# Ensure .env file is readable
chmod 644 .env
chmod 644 web/.env

echo "Getting dependencies..."
flutter pub get

echo "Building web app..."
flutter build web --release

echo "Creating public directory..."
mkdir -p public

echo "Copying Flutter web assets to public directory..."
cp -r build/web/* public/

# Copy assets directory to public
echo "Copying assets to public directory..."
cp -r assets public/
cp -r web/assets public/

# Copy .env file to public
echo "Copying .env file to public directory..."
cp .env public/

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