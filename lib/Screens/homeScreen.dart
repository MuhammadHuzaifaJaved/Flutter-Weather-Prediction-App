// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_weather/screens/locationError.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../provider/weatherProvider.dart';
import '../theme/colors.dart';
import '../theme/textStyle.dart';
import '../widgets/WeatherInfoHeader.dart';
import '../widgets/mainWeatherDetail.dart';
import '../widgets/mainWeatherInfo.dart';
import '../widgets/sevenDayForecast.dart';
import '../widgets/twentyFourHourForecast.dart';
import './profile/profile_screen.dart';
import './notifications_screen.dart';
import './settings_screen.dart';
import 'requestError.dart';
import './dashboard_screen.dart';
import './subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _lastSearchQuery = '';
  List<Map<String, String>> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingSuggestions = false;
  String _apiKey = 'c027b1fa9c29b36b549016be428fd6df'; // OpenWeatherMap API key

  late final AnimationController _backgroundController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    requestWeather();
    _searchController.addListener(_onSearchChanged);
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _backgroundController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getLottieAsset(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'clear':
        return 'https://lottie.host/21d8b0a7-7e5c-4f95-b8c2-b1c8a1170b7b/Ql5u4lqXNa.json'; // Sunny
      case 'clouds':
        return 'https://lottie.host/f9c6d4d5-617b-4861-a6b9-38c6c6f684d8/h7kBtGF2Yx.json'; // Cloudy
      case 'rain':
        return 'https://lottie.host/ec2c7d00-e27f-47b2-9e3a-cd9627b52e25/1HmW3FQELj.json'; // Rainy
      case 'snow':
        return 'https://lottie.host/95a2b1a1-2e39-4f87-9cd1-8e4c8d3c9bb4/lfVFpHPt3R.json'; // Snowy
      case 'thunderstorm':
        return 'https://lottie.host/cf2ed7bc-59c9-4447-b3c3-2d909c3f45a2/KOgNOXkgEe.json'; // Thunder
      default:
        return 'https://lottie.host/21d8b0a7-7e5c-4f95-b8c2-b1c8a1170b7b/Ql5u4lqXNa.json'; // Default sunny
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    setState(() {
      _isLoadingSuggestions = true;
    });
    final url = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _suggestions = data.map<Map<String, String>>((item) {
            final name = item['name'] ?? '';
            final state = item['state'] ?? '';
            final country = item['country'] ?? '';
            return {
              'display':
                  [name, state, country].where((e) => e.isNotEmpty).join(', '),
              'name': name,
              'state': state,
              'country': country,
            };
          }).toList();
          _showSuggestions = _suggestions.isNotEmpty;
        });
      } else {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
    } catch (e) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    } finally {
      setState(() {
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> requestWeather() async {
    await Provider.of<WeatherProvider>(context, listen: false)
        .getWeatherData(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.appBarTheme.backgroundColor?.withOpacity(0.7) ??
                    theme.primaryColor.withOpacity(0.7),
              ),
            ),
          ),
        ),
        leading: Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.menu,
                color: theme.appBarTheme.foregroundColor ??
                    (isDark ? Colors.white : Colors.black)),
            offset: Offset(0, 50),
            onSelected: (value) {
              Navigator.pushNamed(context, value);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: '/weather-maps',
                child: Row(
                  children: [
                    Icon(Icons.map, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Weather Maps'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/weather-alerts',
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Weather Alerts'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/weather-community',
                child: Row(
                  children: [
                    Icon(Icons.people_rounded, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Weather Community'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/weather-education',
                child: Row(
                  children: [
                    Icon(Icons.school_rounded, color: Colors.purple),
                    SizedBox(width: 12),
                    Text('Weather Education'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/weather-news',
                child: Row(
                  children: [
                    Icon(Icons.article_rounded, color: Colors.teal),
                    SizedBox(width: 12),
                    Text('Weather News'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/weather-statistics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, color: Colors.indigo),
                    SizedBox(width: 12),
                    Text('Weather Statistics'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/weather-sharing',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, color: Colors.pink),
                    SizedBox(width: 12),
                    Text('Share Weather'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/weather-comparison',
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows_rounded, color: Colors.amber),
                    SizedBox(width: 12),
                    Text('Compare Weather'),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: Text(
          'Weather App',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ??
                (isDark ? Colors.white : Colors.black),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard_outlined, color: theme.iconTheme.color),
            onPressed: () {
              Navigator.of(context).pushNamed(DashboardScreen.routeName);
            },
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 100.ms)
              .slideX(begin: 0.2, end: 0),
          IconButton(
            icon: Icon(Icons.star_outline, color: theme.iconTheme.color),
            onPressed: () {
              Navigator.of(context).pushNamed(SubscriptionScreen.routeName);
            },
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: 0.2, end: 0),
          IconButton(
            icon: Icon(Icons.info_outline, color: theme.iconTheme.color),
            onPressed: () {
              Navigator.of(context).pushNamed('/about');
            },
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideX(begin: 0.2, end: 0),
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: theme.iconTheme.color),
            onPressed: () {
              Navigator.of(context).pushNamed(NotificationsScreen.routeName);
            },
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideX(begin: 0.2, end: 0),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.iconTheme.color),
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 500.ms)
              .slideX(begin: 0.2, end: 0),
          IconButton(
            icon: Icon(Icons.person_outline, color: theme.iconTheme.color),
            onPressed: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideX(begin: 0.2, end: 0),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProv, _) {
          if (!weatherProv.isLoading && !weatherProv.isLocationserviceEnabled)
            return LocationServiceErrorDisplay();

          if (!weatherProv.isLoading &&
              weatherProv.locationPermission != LocationPermission.always &&
              weatherProv.locationPermission != LocationPermission.whileInUse) {
            return LocationPermissionErrorDisplay();
          }

          if (weatherProv.isRequestError) return RequestErrorDisplay();

          if (weatherProv.isSearchError)
            return SearchErrorDisplay(query: _lastSearchQuery);

          final weatherCondition =
              weatherProv.weather.weatherCategory ?? 'Clear';

          return Stack(
            children: [
              // Animated Weather Background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Gradient Background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDark
                                  ? [
                                      Color(0xFF1a1a2e),
                                      Color(0xFF16213e),
                                    ]
                                  : [
                                      Color(0xFF4a90e2),
                                      Color(0xFF87ceeb),
                                    ],
                            ),
                          ),
                        ),
                        // Weather Animation
                        Opacity(
                          opacity: 0.6,
                          child: Lottie.network(
                            _getLottieAsset(weatherCondition),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(),
                          ),
                        ),
                        // Glass Overlay
                        ClipRect(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: Container(
                              color: isDark
                                  ? Colors.black.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Main Content
              Column(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: BackdropFilter(
                              filter:
                                  ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.search,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        _lastSearchQuery =
                                            _searchController.text;
                                        _showSuggestions = false;
                                      });
                                      await Provider.of<WeatherProvider>(
                                        context,
                                        listen: false,
                                      ).searchWeather(_searchController.text);
                                    },
                                  ),
                                ),
                                onSubmitted: (query) async {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    _lastSearchQuery = query;
                                    _showSuggestions = false;
                                  });
                                  await Provider.of<WeatherProvider>(
                                    context,
                                    listen: false,
                                  ).searchWeather(query);
                                },
                                onTap: () {
                                  if (_suggestions.isNotEmpty) {
                                    setState(() {
                                      _showSuggestions = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.2, end: 0),
                        if (_showSuggestions)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200,
                              minHeight: 0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(
                                      sigmaX: 10, sigmaY: 10),
                                  child: _isLoadingSuggestions
                                      ? Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          itemCount: _suggestions.length,
                                          separatorBuilder: (context, index) =>
                                              Divider(
                                            height: 1,
                                            color: isDark
                                                ? Colors.white24
                                                : Colors.black12,
                                          ),
                                          itemBuilder: (context, index) {
                                            final suggestion =
                                                _suggestions[index];
                                            return ListTile(
                                              title: Text(
                                                suggestion['display'] ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              onTap: () async {
                                                _searchController.text =
                                                    suggestion['display'] ?? '';
                                                setState(() {
                                                  _lastSearchQuery =
                                                      suggestion['display'] ??
                                                          '';
                                                  _showSuggestions = false;
                                                });
                                                FocusScope.of(context)
                                                    .unfocus();
                                                await Provider.of<
                                                    WeatherProvider>(
                                                  context,
                                                  listen: false,
                                                ).searchWeather(
                                                    suggestion['display'] ??
                                                        '');
                                              },
                                            )
                                                .animate()
                                                .fadeIn(
                                                  duration: 400.ms,
                                                  delay: (50 * index).ms,
                                                )
                                                .slideX(begin: 0.2, end: 0);
                                          },
                                        ),
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(begin: Offset(1, 0.95)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      physics: BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        WeatherInfoHeader()
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 24.0),
                        MainWeatherInfo()
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 400.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 24.0),
                        MainWeatherDetail()
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 32.0),
                        TwentyFourHourForecast()
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 800.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 32.0),
                        SevenDayForecast()
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1000.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
