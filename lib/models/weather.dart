// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Weather with ChangeNotifier {
  final double temp;
  final double tempMax;
  final double tempMin;
  final double lat;
  final double long;
  final double feelsLike;
  final int pressure;
  final String description;
  final String weatherCategory;
  final int humidity;
  final double windSpeed;
  String city;
  final String countryCode;

  Weather({
    required this.temp,
    required this.tempMax,
    required this.tempMin,
    required this.lat,
    required this.long,
    required this.feelsLike,
    required this.pressure,
    required this.description,
    required this.weatherCategory,
    required this.humidity,
    required this.windSpeed,
    required this.city,
    required this.countryCode,
  });

  // Getter for formatted date
  String get date => DateFormat('EEEE MMM dd, y  hh:mm a').format(DateTime.now());
  
  // Getter for country name (you can expand this with a proper country code to name mapping)
  String get countryName => countryCode;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temp: (json['main']['temp']).toDouble(),
      tempMax: (json['main']['temp_max']).toDouble(),
      tempMin: (json['main']['temp_min']).toDouble(),
      lat: json['coord']['lat'],
      long: json['coord']['lon'],
      feelsLike: (json['main']['feels_like']).toDouble(),
      pressure: json['main']['pressure'],
      weatherCategory: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed']).toDouble(),
      city: json['name'],
      countryCode: json['sys']['country'],
    );
  }
}
