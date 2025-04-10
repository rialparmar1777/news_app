# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }

# Keep your model classes
-keep class com.example.news_app.models.** { *; }

# Keep the NewsAPI class
-keep class com.example.news_app.api.NewsAPI { *; }

# Keep the NewsProvider class
-keep class com.example.news_app.providers.NewsProvider { *; }

# Keep the Article class
-keep class com.example.news_app.models.Article { *; }

# Keep the NewsCard class
-keep class com.example.news_app.widgets.NewsCard { *; }

# Keep the NewsList class
-keep class com.example.news_app.screens.NewsList { *; }

# Keep the NewsDetail class
-keep class com.example.news_app.screens.NewsDetail { *; }

# Keep the NewsHeader class
-keep class com.example.news_app.widgets.NewsHeader { *; }

# Keep the NewsCardSkeleton class
-keep class com.example.news_app.widgets.NewsCardSkeleton { *; }

# Keep the NewsSearchDelegate class
-keep class com.example.news_app.screens.NewsSearchDelegate { *; }

# Keep the SplashScreen class
-keep class com.example.news_app.screens.SplashScreen { *; }

# Keep the HomeScreen class
-keep class com.example.news_app.screens.HomeScreen { *; }

# Keep the GlassBottomNavBar class
-keep class com.example.news_app.widgets.GlassBottomNavBar { *; }

# Keep the PageTurnAnimation class
-keep class com.example.news_app.widgets.PageTurnAnimation { *; }

# Keep the ShimmerLoading class
-keep class com.example.news_app.widgets.ShimmerLoading { *; }

# Keep the RefreshIndicator class
-keep class com.example.news_app.widgets.RefreshIndicator { *; }

# Keep the MyApp class
-keep class com.example.news_app.MyApp { *; }

# Keep the main function
-keep class com.example.news_app.Main { *; } 