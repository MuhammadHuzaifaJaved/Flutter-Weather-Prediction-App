import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../provider/weatherProvider.dart';
import '../models/weather.dart';

class WeatherSharingScreen extends StatefulWidget {
  const WeatherSharingScreen({Key? key}) : super(key: key);

  @override
  _WeatherSharingScreenState createState() => _WeatherSharingScreenState();
}

class _WeatherSharingScreenState extends State<WeatherSharingScreen> {
  bool includeLocation = true;
  bool includeDateTime = true;
  bool includeForecast = true;
  bool includeWeatherMap = false;
  Weather? currentWeather;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final weather = weatherProvider.weather;
      setState(() {
        currentWeather = weather;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading weather data: ${e.toString()}')),
      );
    }
  }

  String _generateShareText() {
    if (currentWeather == null) return 'Weather data not available';

    final StringBuffer shareText = StringBuffer();
    
    if (includeLocation) {
      shareText.writeln('📍 Location: ${currentWeather!.city}, ${currentWeather!.countryCode}');
    }
    
    if (includeDateTime) {
      shareText.writeln('🕒 ${DateTime.now().toString().split('.')[0]}');
    }
    
    shareText.writeln('\n🌡️ Temperature: ${currentWeather!.temp.toStringAsFixed(1)}°C');
    shareText.writeln('🌤️ Condition: ${currentWeather!.description}');
    shareText.writeln('💨 Wind: ${currentWeather!.windSpeed} km/h');
    shareText.writeln('💧 Humidity: ${currentWeather!.humidity}%');
    
    if (includeForecast) {
      shareText.writeln('\n🔮 Feels like: ${currentWeather!.feelsLike.toStringAsFixed(1)}°C');
      shareText.writeln('📊 Pressure: ${currentWeather!.pressure} hPa');
    }
    
    shareText.writeln('\nShared via Weather App 📱');
    
    return shareText.toString();
  }

  void _shareWeather(String platform) async {
    final String weatherInfo = _generateShareText();
    
    switch (platform) {
      case 'whatsapp':
        await Share.share(weatherInfo, subject: 'Current Weather Update');
        break;
      case 'twitter':
        final String twitterText = weatherInfo.length > 280 
          ? '${weatherInfo.substring(0, 277)}...' 
          : weatherInfo;
        await Share.share(twitterText, subject: 'Current Weather Update');
        break;
      case 'facebook':
        await Share.share(weatherInfo, subject: 'Current Weather Update');
        break;
      case 'more':
        await Share.share(weatherInfo, subject: 'Current Weather Update');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Weather'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherCard(),
            const SizedBox(height: 24),
            _buildSharingOptions(),
            const SizedBox(height: 24),
            _buildCustomization(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (currentWeather == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[400]!, Colors.blue[700]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentWeather!.city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateTime.now().toString().split('.')[0],
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _getWeatherIcon(currentWeather!.description),
                  color: Colors.white,
                  size: 48,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentWeather!.temp.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currentWeather!.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Feels like ${currentWeather!.feelsLike.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('clear') || condition.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (condition.contains('rain')) {
      return Icons.water_drop;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else {
      return Icons.wb_sunny;
    }
  }

  Widget _buildSharingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share via',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildShareButton(
              'WhatsApp',
              Icons.message_rounded,
              Colors.green,
              () => _shareWeather('whatsapp'),
            ),
            _buildShareButton(
              'Twitter',
              Icons.flutter_dash,
              Colors.blue,
              () => _shareWeather('twitter'),
            ),
            _buildShareButton(
              'Facebook',
              Icons.facebook,
              Colors.indigo,
              () => _shareWeather('facebook'),
            ),
            _buildShareButton(
              'More',
              Icons.more_horiz,
              Colors.grey,
              () => _shareWeather('more'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customize Share',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCustomizationOption(
          'Include Location',
          includeLocation,
          (value) => setState(() => includeLocation = value),
        ),
        _buildCustomizationOption(
          'Include Date & Time',
          includeDateTime,
          (value) => setState(() => includeDateTime = value),
        ),
        _buildCustomizationOption(
          'Include Forecast',
          includeForecast,
          (value) => setState(() => includeForecast = value),
        ),
        _buildCustomizationOption(
          'Include Weather Map',
          includeWeatherMap,
          (value) => setState(() => includeWeatherMap = value),
        ),
      ],
    );
  }

  Widget _buildCustomizationOption(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
