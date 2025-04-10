# News App

A modern Flutter news application that provides real-time news updates across various categories with a beautiful and intuitive user interface.

[![Flutter](https://img.shields.io/badge/Flutter-3.0.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev)

## About

News App is a feature-rich mobile application built with Flutter that brings the latest news from around the world right to your fingertips. With its sleek iOS-inspired design and smooth animations, it offers an engaging news reading experience.

### Key Highlights:
- **Real-time Updates**: Stay informed with the latest news across multiple categories
- **Beautiful UI**: Modern design with glass morphism effects and smooth animations
- **Smart Search**: Find articles quickly with intelligent search suggestions
- **Dark Mode**: Comfortable reading experience in any lighting condition
- **Offline Support**: Read your saved articles even without internet connection
- **Share & Save**: Easily share articles or save them for later reading

### Tech Stack:
- **Framework**: Flutter 3.0.0
- **State Management**: Provider
- **API Integration**: News API
- **UI Components**: Custom widgets with glass morphism effects
- **Animations**: Hero transitions and page turn effects
- **Storage**: Local storage for offline reading

## Features

- 📱 Modern iOS-style design with glass morphism effects
- 🌐 Real-time news updates from multiple categories
- 🔍 Advanced search functionality with suggestions
- 🌙 Dark mode support
- 📱 Responsive layout for all screen sizes
- ⚡ Smooth animations and transitions
- 🔄 Pull-to-refresh functionality
- 📰 Detailed article view with sharing options

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Xcode (for iOS development)
- Android Studio (for Android development)
- News API key from [https://newsapi.org](https://newsapi.org)

### Installation

1. Clone the repository
2. Create a `.env` file in the root directory with your News API key:
   ```
   NEWS_API_KEY=your_api_key_here
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the app:
   ```
   flutter run
   ```

## Deployment

### iOS Deployment

1. Update the version in `pubspec.yaml`
2. Update the bundle identifier in Xcode
3. Create an App Store Connect account
4. Create a new app in App Store Connect
5. Generate an archive:
   ```
   flutter build ios --release
   ```
6. Open Xcode and upload the archive to App Store Connect

### Android Deployment

1. Update the version in `pubspec.yaml`
2. Update the application ID in `android/app/build.gradle`
3. Create a keystore for signing:
   ```
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
4. Create a `key.properties` file in `android/` with:
   ```
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path to keystore>
   ```
5. Build the release APK:
   ```
   flutter build appbundle
   ```
6. Upload the bundle to the Google Play Console

## Project Structure

```
lib/
├── api/
│   └── news_api.dart         # API service for fetching news
├── models/
│   └── article.dart          # Article data model
├── providers/
│   └── news_provider.dart    # State management
├── screens/
│   ├── home_screen.dart      # Main screen with category navigation
│   ├── news_detail.dart      # Article detail screen
│   ├── news_list.dart        # News list with search functionality
│   └── splash_screen.dart    # App splash screen
├── theme/
│   └── app_theme.dart        # App theme configuration
├── utils/
│   └── constants.dart        # App constants
├── widgets/
│   ├── glass_bottom_nav_bar.dart  # Custom bottom navigation
│   ├── news_card.dart        # Article card widget
│   ├── news_card_skeleton.dart    # Loading skeleton
│   ├── page_turn_animation.dart   # Page transition animation
│   └── shimmer_loading.dart  # Shimmer effect widget
└── main.dart                 # App entry point
```

## Features in Detail

### News Categories
- General
- Business
- Technology
- Sports
- Entertainment

### Search Functionality
- Real-time search suggestions
- Search history
- Category-specific search
- Advanced filtering options

### UI Components
- Glass morphism bottom navigation
- Shimmer loading effects
- Page turn animations
- Hero transitions
- Pull-to-refresh
- Infinite scroll

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- News API for providing the news data
- Flutter team for the amazing framework
- Material Design for the design guidelines

## Support

For support, email support@example.com or open an issue in the repository.

## Tags

#flutter #dart #news-app #mobile-app #ios #android #glass-morphism #dark-mode #real-time #api-integration #provider #state-management #hero-animation #pull-to-refresh #infinite-scroll #search #offline-support #shimmer-effect #page-turn-animation #responsive-design

---

Made with ❤️ by Rial
