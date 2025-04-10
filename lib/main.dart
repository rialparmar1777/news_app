import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'providers/news_provider.dart';
import 'providers/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  final userPreferences = UserPreferences();
  await userPreferences.init(); // Initialize UserPreferences

  runApp(MyApp(userPreferences: userPreferences));
}

class MyApp extends StatelessWidget {
  final UserPreferences userPreferences;
  
  const MyApp({
    Key? key,
    required this.userPreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider.value(value: userPreferences),
      ],
      child: Consumer<UserPreferences>(
        builder: (context, userPrefs, child) {
          return MaterialApp(
            title: 'News App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: userPrefs.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
