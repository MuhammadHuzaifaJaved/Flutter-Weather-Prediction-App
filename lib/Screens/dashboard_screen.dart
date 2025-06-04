import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../theme/colors.dart';
import '../provider/weatherProvider.dart';
import '../helper/utils.dart';
import '../helper/extensions.dart';
import '../models/dailyWeather.dart';
import '../models/weather.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _weatherController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _weatherController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _isScrolled = _scrollController.offset > 0;
        });
      });

    // Request weather data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).getWeatherData(context, notify: true);
    });
  }

  @override
  void dispose() {
    _weatherController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getWeatherAnimation(String weatherCategory) {
    switch (weatherCategory.toLowerCase()) {
      case 'clear':
        return 'https://lottie.host/21d8b0a7-7e5c-4f95-b8c2-b1c8a1170b7b/Ql5u4lqXNa.json';
      case 'clouds':
        return 'https://lottie.host/f9c6d4d5-617b-4861-a6b9-38c6c6f684d8/h7kBtGF2Yx.json';
      case 'rain':
        return 'https://lottie.host/ec2c7d00-e27f-47b2-9e3a-cd9627b52e25/1HmW3FQELj.json';
      case 'snow':
        return 'https://lottie.host/95a2b1a1-2e39-4f87-9cd1-8e4c8d3c9bb4/lfVFpHPt3R.json';
      case 'thunderstorm':
        return 'https://lottie.host/cf2ed7bc-59c9-4447-b3c3-2d909c3f45a2/KOgNOXkgEe.json';
      default:
        return 'https://lottie.host/21d8b0a7-7e5c-4f95-b8c2-b1c8a1170b7b/Ql5u4lqXNa.json';
    }
  }

  Widget _buildHeader(WeatherProvider weatherProv) {
    if (weatherProv.isLoading) {
      return Container(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      height: 300,
      child: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: Lottie.network(
              _getWeatherAnimation(weatherProv.weather.weatherCategory),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Color(0xFF1A1A2F),
                );
              },
            ),
          ),
          // Glassmorphic overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weatherProv.isCelsius
                      ? '${weatherProv.weather.temp.toStringAsFixed(1)}°C'
                      : '${weatherProv.weather.temp.toFahrenheit().toStringAsFixed(1)}°F',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  weatherProv.weather.description.toTitleCase(),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '${weatherProv.weather.city}, ${weatherProv.weather.countryCode}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(DailyWeather data, bool isCelsius) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Lottie.network(
                    _getWeatherAnimation(data.weatherCategory),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        getWeatherImage(data.weatherCategory),
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  isCelsius
                      ? '${data.temp.toStringAsFixed(1)}°C'
                      : '${data.temp.toFahrenheit().toStringAsFixed(1)}°F',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  data.condition.toTitleCase(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('EEE').format(data.date),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(Map<String, dynamic> action) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: action['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            action['icon'] as IconData,
            color: action['color'],
            size: 24,
          ),
        ),
        title: Text(
          action['title'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.6),
          size: 16,
        ),
        onTap: action['onTap'] as Function(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProv, _) {
        final List<Map<String, dynamic>> quickActions = [
          {
            'title': 'Weather Maps',
            'icon': Icons.map,
            'color': Colors.blue,
            'onTap': () {
              Navigator.pushNamed(context, '/weather-maps');
            },
          },
          {
            'title': 'Weather Alerts',
            'icon': Icons.warning_rounded,
            'color': Colors.orange,
            'onTap': () {
              Navigator.pushNamed(context, '/weather-alerts');
            },
          },
          {
            'title': 'Weather Community',
            'icon': Icons.people_rounded,
            'color': Colors.green,
            'onTap': () {
              Navigator.pushNamed(context, '/weather-community');
            },
          },
          {
            'title': 'Weather Education',
            'icon': Icons.school_rounded,
            'color': Colors.purple,
            'onTap': () {
              Navigator.pushNamed(context, '/weather-education');
            },
          },
          {
            'title': 'Premium Features',
            'icon': Icons.star_rounded,
            'color': Colors.amber,
            'onTap': () {
              Navigator.pushNamed(context, '/premium-features');
            },
          },
          {
            'title': 'Settings',
            'icon': Icons.settings,
            'color': Colors.grey,
            'onTap': () {
              Navigator.pushNamed(context, '/settings');
            },
          },
        ];

        return Scaffold(
          backgroundColor: Color(0xFF1A1A2F),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: _isScrolled ? 4 : 0,
            backgroundColor: _isScrolled 
                ? Color(0xFF1A1A2F).withOpacity(0.9)
                : Colors.transparent,
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
                icon: Icon(Icons.menu, color: Colors.white),
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
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  weatherProv.getWeatherData(context, notify: true);
                },
              ),
              IconButton(
                icon: Icon(
                  weatherProv.isCelsius ? Icons.thermostat : Icons.thermostat_auto,
                  color: Colors.white,
                ),
                onPressed: () {
                  weatherProv.switchTempUnit();
                },
              ),
            ],
          ),
          body: weatherProv.isLoading
              ? Center(child: CircularProgressIndicator())
              : weatherProv.isRequestError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Error loading weather data',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              weatherProv.getWeatherData(context, notify: true);
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      physics: BouncingScrollPhysics(),
                      child: AnimationLimiter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: Duration(milliseconds: 600),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              _buildHeader(weatherProv),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next Days',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      height: 220,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics: BouncingScrollPhysics(),
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        itemCount: weatherProv.dailyWeather.length,
                                        itemBuilder: (context, index) {
                                          return _buildWeatherCard(
                                            weatherProv.dailyWeather[index],
                                            weatherProv.isCelsius,
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      'Quick Actions',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    ...quickActions.map((action) => _buildQuickAction(action)).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        );
      },
    );
  }
} 