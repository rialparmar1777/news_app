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
flutter build web --release --base-href /

echo "Build completed. Listing build/web contents:"
ls -la build/web

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

# Ensure all files are readable
chmod -R 755 build/web 