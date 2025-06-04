import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/weatherProvider.dart';
import '../models/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherComparisonScreen extends StatefulWidget {
  const WeatherComparisonScreen({Key? key}) : super(key: key);

  @override
  _WeatherComparisonScreenState createState() => _WeatherComparisonScreenState();
}

class _WeatherComparisonScreenState extends State<WeatherComparisonScreen> {
  String? selectedLocation1;
  String? selectedLocation2;
  List<String> searchResults1 = [];
  List<String> searchResults2 = [];
  bool isLoading = false;
  Weather? weather1;
  Weather? weather2;
  final TextEditingController _searchController1 = TextEditingController();
  final TextEditingController _searchController2 = TextEditingController();

  Future<List<String>> searchLocations(String query) async {
    if (query.isEmpty) return [];

    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final apiKey = weatherProvider.apiKey;
    
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) {
          final name = item['name'] ?? '';
          final state = item['state'] ?? '';
          final country = item['country'] ?? '';
          return [name, state, country].where((e) => e.isNotEmpty).join(', ');
        }).toList();
      }
    } catch (e) {
      print('Error searching locations: $e');
    }
    return [];
  }

  Future<void> compareWeather() async {
    if (selectedLocation1 == null || selectedLocation2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both locations')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      weather1 = await weatherProvider.fetchWeatherByCity(selectedLocation1!);
      weather2 = await weatherProvider.fetchWeatherByCity(selectedLocation2!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching weather data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildSearchField(
    TextEditingController controller,
    List<String> results,
    Function(String) onSelected,
    String label,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.search),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      setState(() => results.clear());
                    },
                  )
                : null,
          ),
          onChanged: (query) async {
            if (query.isNotEmpty) {
              final locations = await searchLocations(query);
              setState(() {
                if (label == 'Location 1') {
                  searchResults1 = locations;
                } else {
                  searchResults2 = locations;
                }
              });
            } else {
              setState(() {
                if (label == 'Location 1') {
                  searchResults1 = [];
                } else {
                  searchResults2 = [];
                }
              });
            }
          },
        ),
        if (results.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: results.map((result) {
                return ListTile(
                  title: Text(result),
                  onTap: () {
                    controller.text = result;
                    onSelected(result);
                    setState(() {
                      if (label == 'Location 1') {
                        searchResults1 = [];
                        selectedLocation1 = result;
                      } else {
                        searchResults2 = [];
                        selectedLocation2 = result;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildWeatherComparison() {
    if (weather1 == null || weather2 == null) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildWeatherColumn(weather1!, selectedLocation1!),
                ),
                Container(
                  width: 2,
                  height: 200,
                  color: Colors.grey.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildWeatherColumn(weather2!, selectedLocation2!),
                ),
              ],
            ),
            Divider(height: 32),
            _buildComparisonMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherColumn(Weather weather, String location) {
    return Column(
      children: [
        Text(
          location.split(',')[0],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Icon(
          _getWeatherIcon(weather.description),
          size: 48,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: 8),
        Text(
          '${weather.temp.toStringAsFixed(1)}°C',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          weather.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonMetrics() {
    if (weather1 == null || weather2 == null) return SizedBox.shrink();

    return Column(
      children: [
        _buildMetricComparison(
          'Temperature',
          '${weather1!.temp.toStringAsFixed(1)}°C',
          '${weather2!.temp.toStringAsFixed(1)}°C',
          weather1!.temp - weather2!.temp,
        ),
        _buildMetricComparison(
          'Feels Like',
          '${weather1!.feelsLike.toStringAsFixed(1)}°C',
          '${weather2!.feelsLike.toStringAsFixed(1)}°C',
          weather1!.feelsLike - weather2!.feelsLike,
        ),
        _buildMetricComparison(
          'Humidity',
          '${weather1!.humidity}%',
          '${weather2!.humidity}%',
          weather1!.humidity.toDouble() - weather2!.humidity.toDouble(),
        ),
        _buildMetricComparison(
          'Wind Speed',
          '${weather1!.windSpeed} km/h',
          '${weather2!.windSpeed} km/h',
          weather1!.windSpeed - weather2!.windSpeed,
        ),
        _buildMetricComparison(
          'Pressure',
          '${weather1!.pressure} hPa',
          '${weather2!.pressure} hPa',
          weather1!.pressure.toDouble() - weather2!.pressure.toDouble(),
        ),
      ],
    );
  }

  Widget _buildMetricComparison(
    String label,
    String value1,
    String value2,
    double difference,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value1, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text(value2, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  difference > 0
                      ? Icons.arrow_upward
                      : difference < 0
                          ? Icons.arrow_downward
                          : Icons.remove,
                  color: difference > 0
                      ? Colors.red
                      : difference < 0
                          ? Colors.blue
                          : Colors.grey,
                  size: 16,
                ),
                Text(
                  difference.abs().toStringAsFixed(1),
                  style: TextStyle(
                    color: difference > 0
                        ? Colors.red
                        : difference < 0
                            ? Colors.blue
                            : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compare Weather'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField(
              _searchController1,
              searchResults1,
              (value) => setState(() => selectedLocation1 = value),
              'Location 1',
            ),
            SizedBox(height: 16),
            _buildSearchField(
              _searchController2,
              searchResults2,
              (value) => setState(() => selectedLocation2 = value),
              'Location 2',
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : compareWeather,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Compare Weather'),
            ),
            SizedBox(height: 24),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              _buildWeatherComparison(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController1.dispose();
    _searchController2.dispose();
    super.dispose();
  }
} 