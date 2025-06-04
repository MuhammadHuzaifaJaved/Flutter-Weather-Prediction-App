import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import './config/firebase_config.dart';

import './provider/weatherProvider.dart';
import './provider/theme_provider.dart';
import './provider/temperature_provider.dart';
import './Screens/homeScreen.dart';
import './Screens/sevenDayForecastDetailScreen.dart';
import './Screens/auth/login_screen.dart';
import './Screens/auth/signup_screen.dart';
import './Screens/profile/profile_screen.dart';
import './Screens/settings_screen.dart';
import './Screens/notifications_screen.dart';
import './Screens/subscription_screen.dart';
import './Screens/dashboard_screen.dart';
import './Screens/about_screen.dart';
import './theme/app_theme.dart';
import './theme/colors.dart';
import './provider/user_provider.dart';
import './Screens/edit_profile_screen.dart';
import './Screens/saved_locations_screen.dart';
import './Screens/notification_settings_screen.dart';
import './Screens/privacy_security_screen.dart';
import './Screens/help_support_screen.dart';
import './Screens/weather_maps_screen.dart';
import './Screens/weather_alerts_screen.dart';
import './Screens/weather_community_screen.dart';
import './Screens/weather_education_screen.dart';
import './Screens/premium_features_screen.dart';
import './Screens/weather_comparison_screen.dart';
import './Screens/weather_sharing_screen.dart';
import './Screens/weather_news_screen.dart';
import './Screens/weather_statistics_screen.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;
  const AppInitializer({required this.child, Key? key}) : super(key: key);

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize user data
    Future.microtask(() async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoading && userProvider.currentUser == null) {
        await userProvider.initializeUser();
        // If still no user after initialization, create a test user
        if (userProvider.currentUser == null) {
          print('Creating test user...');
          await userProvider.login('Test User', 'test@example.com');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (!themeProvider.isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return widget.child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initializeFirebase();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final themeProvider = ThemeProvider();
  // Wait for theme to be loaded from preferences
  await Future.delayed(const Duration(milliseconds: 100));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (context) => TemperatureProvider()),
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
      ],
      child: AppInitializer(child: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return MaterialApp(
          title: 'Flutter Weather',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: context.watch<ThemeProvider>().isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/login',
          routes: {
            '/': (ctx) => const LoginScreen(),
            '/login': (ctx) => const LoginScreen(),
            '/signup': (ctx) => const SignupScreen(),
            '/home': (ctx) => const HomeScreen(),
            '/about': (ctx) => const AboutScreen(),
            LoginScreen.routeName: (ctx) => const LoginScreen(),
            SignupScreen.routeName: (ctx) => const SignupScreen(),
            HomeScreen.routeName: (ctx) => const HomeScreen(),
            ProfileScreen.routeName: (ctx) => const ProfileScreen(),
            SevenDayForecastDetail.routeName: (ctx) => const SevenDayForecastDetail(),
            SettingsScreen.routeName: (ctx) => const SettingsScreen(),
            NotificationsScreen.routeName: (ctx) => const NotificationsScreen(),
            SubscriptionScreen.routeName: (ctx) => const SubscriptionScreen(),
            DashboardScreen.routeName: (ctx) => const DashboardScreen(),
            EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
            SavedLocationsScreen.routeName: (ctx) => SavedLocationsScreen(),
            NotificationSettingsScreen.routeName: (ctx) => NotificationSettingsScreen(),
            PrivacySecurityScreen.routeName: (ctx) => PrivacySecurityScreen(),
            HelpSupportScreen.routeName: (ctx) => HelpSupportScreen(),
            '/weather-maps': (ctx) => const WeatherMapsScreen(),
            '/weather-alerts': (ctx) => const WeatherAlertsScreen(),
            '/weather-community': (ctx) => const WeatherCommunityScreen(),
            '/weather-education': (ctx) => const WeatherEducationScreen(),
            '/premium-features': (ctx) => const PremiumFeaturesScreen(),
            '/weather-comparison': (ctx) => const WeatherComparisonScreen(),
            '/weather-sharing': (ctx) => const WeatherSharingScreen(),
            '/weather-news': (ctx) => const WeatherNewsScreen(),
            '/weather-statistics': (ctx) => const WeatherStatisticsScreen(),
          },
        );
      },
    );
  }
}
