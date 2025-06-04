import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_weather/models/additionalWeatherData.dart';
import 'package:flutter_weather/models/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/dailyWeather.dart';
import '../models/hourlyWeather.dart';
import '../models/weather.dart';

class WeatherProvider with ChangeNotifier {
  String apiKey = 'c027b1fa9c29b36b549016be428fd6df';
  Weather? _weather;
  late AdditionalWeatherData additionalWeatherData;
  LatLng? currentLocation;
  List<HourlyWeather> hourlyWeather = [];
  List<DailyWeather> dailyWeather = [];
  List<DailyWeather> _sevenDayWeather = [];
  bool isLoading = false;
  bool isRequestError = false;
  bool isSearchError = false;
  bool isLocationserviceEnabled = false;
  LocationPermission? locationPermission;
  bool isCelsius = true;

  String get measurementUnit => isCelsius ? '°C' : '°F';

  Weather get weather => _weather!;
  List<DailyWeather> get sevenDayWeather => _sevenDayWeather;

  Future<Position?> requestLocation(BuildContext context) async {
    isLocationserviceEnabled = await Geolocator.isLocationServiceEnabled();
    notifyListeners();

    if (!isLocationserviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location service disabled')),
      );
      return Future.error('Location services are disabled.');
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      isLoading = false;
      notifyListeners();
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Permission denied'),
        ));
        return Future.error('Location permissions are denied');
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Location permissions are permanently denied, Please enable manually from app settings',
        ),
      ));
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getWeatherData(
    BuildContext context, {
    bool notify = false,
  }) async {
    isLoading = true;
    isRequestError = false;
    isSearchError = false;
    if (notify) notifyListeners();

    Position? locData = await requestLocation(context);

    if (locData == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      currentLocation = LatLng(locData.latitude, locData.longitude);
      await getCurrentWeather(currentLocation!);
      await getDailyWeather(currentLocation!);
    } catch (e) {
      print(e);
      isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentWeather(LatLng location) async {
    Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
    );
    try {
      print('Attempting to fetch current weather from: $url');
      final response = await http.get(url);
      print('Current Weather API Response Status: ${response.statusCode}');
      print('Current Weather API Response Body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch current weather. Status code: ${response.statusCode}, Body: ${response.body}');
      }
      
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      _weather = Weather.fromJson(extractedData);
      print('Successfully fetched weather for: ${_weather!.city}/${_weather!.countryCode}');
    } catch (error, stackTrace) {
      print('Current Weather Error: $error');
      print('Stack trace: $stackTrace');
      isLoading = false;
      this.isRequestError = true;
    }
  }

  Future<void> getDailyWeather(LatLng location) async {
    isLoading = true;
    notifyListeners();

    try {
      // Use the 5 day/3 hour forecast API which is available in the free tier
      Uri forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
      );
      print('Fetching forecast data from: $forecastUrl');
      final response = await http.get(forecastUrl);
      print('Forecast API Response Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch forecast. Status code: ${response.statusCode}, Body: ${response.body}');
      }
      
      final forecastData = json.decode(response.body) as Map<String, dynamic>;
      List<dynamic> list = forecastData['list'] ?? [];
      
      // Get hourly forecast for next 24 hours
      hourlyWeather = list
          .take(8) // 8 entries = 24 hours (3-hour intervals)
          .map((item) => HourlyWeather.fromJson(item))
          .toList();
      
      // Group forecast data by day
      Map<String, List<dynamic>> dailyGroups = {};
      for (var item in list) {
        String date = item['dt_txt'].toString().split(' ')[0];
        dailyGroups[date] = dailyGroups[date] ?? [];
        dailyGroups[date]!.add(item);
      }
      
      // Create daily forecast from grouped data
      dailyWeather = dailyGroups.entries
          .take(5) // 5 days forecast
          .map((entry) {
            // Use the noon forecast (or closest to it) for each day
            var dayItems = entry.value;
            var noonForecast = dayItems.firstWhere(
              (item) => item['dt_txt'].toString().contains('12:00'),
              orElse: () => dayItems.first,
            );
            return DailyWeather.fromForecastJson(noonForecast);
          })
          .toList();
      
      // Get additional weather data from current weather API
      Uri currentUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
      );
      final currentResponse = await http.get(currentUrl);
      if (currentResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        additionalWeatherData = AdditionalWeatherData.fromCurrentJson(currentData);
      }
      
      print('Successfully fetched weather forecast data');
    } catch (error, stackTrace) {
      print('Weather Forecast Error: $error');
      print('Stack trace: $stackTrace');
      isLoading = false;
      this.isRequestError = true;
    }
  }

  Future<GeocodeData?> locationToLatLng(String location) async {
    try {
      Uri url = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$location&limit=5&appid=$apiKey',
      );
      print('Attempting to fetch geocoding data from: $url');
      final http.Response response = await http.get(url);
      print('Geocoding API Response Status: ${response.statusCode}');
      print('Geocoding API Response Body: ${response.body}');
      
      if (response.statusCode != 200) {
        print('Geocoding API Error: Status code ${response.statusCode}, Body: ${response.body}');
        return null;
      }
      
      final responseData = jsonDecode(response.body);
      if (responseData is List && responseData.isEmpty) {
        print('Geocoding API Error: No results found for location $location');
        return null;
      }
      
      return GeocodeData.fromJson(
        responseData[0] as Map<String, dynamic>,
      );
    } catch (error, stackTrace) {
      print('Geocoding Error: $error');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> searchWeather(String location) async {
    isLoading = true;
    notifyListeners();
    isRequestError = false;
    print('search');
    try {
      GeocodeData? geocodeData;
      geocodeData = await locationToLatLng(location);
      if (geocodeData == null) throw Exception('Unable to Find Location');
      await getCurrentWeather(geocodeData.latLng);
      await getDailyWeather(geocodeData.latLng);
      // replace location name with data from geocode
      // because data from certain lat long might return local area name
      if (_weather != null) {
        _weather!.city = geocodeData.name;
      }
    } catch (e) {
      print(e);
      isSearchError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void switchTempUnit() {
    isCelsius = !isCelsius;
    notifyListeners();
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather for $city');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<void> fetchWeatherData(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        _weather = Weather.fromJson(jsonDecode(response.body));
        await fetchSevenDayForecast(lat, lon);
        notifyListeners();
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<void> fetchSevenDayForecast(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast/daily?lat=$lat&lon=$lon&units=metric&cnt=7&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sevenDayWeather = List<DailyWeather>.from(
          data['list'].map((day) => DailyWeather.fromDailyJson(day)),
        );
        notifyListeners();
      } else {
        throw Exception('Failed to load forecast');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }
}
