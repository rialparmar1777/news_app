#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
flutter precache
flutter doctor
flutter config --enable-web

# Get dependencies and build
flutter pub get
flutter build web --release 