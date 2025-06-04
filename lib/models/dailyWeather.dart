// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';

class DailyWeather with ChangeNotifier {
  final double temp;
  final double tempMin;
  final double tempMax;
  final double tempMorning;
  final double tempDay;
  final double tempEvening;
  final double tempNight;
  final String weatherCategory;
  final String condition;
  final DateTime date;
  final String precipitation;
  final double uvi;
  final int clouds;
  final int humidity;
  final double windSpeed;

  DailyWeather({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.tempMorning,
    required this.tempDay,
    required this.tempEvening,
    required this.tempNight,
    required this.weatherCategory,
    required this.condition,
    required this.date,
    required this.precipitation,
    required this.uvi,
    required this.clouds,
    required this.humidity,
    required this.windSpeed,
  });

  static DailyWeather fromDailyJson(dynamic json) {
    return DailyWeather(
      temp: (json['temp']['day']).toDouble(),
      tempMin: (json['temp']['min']).toDouble(),
      tempMax: (json['temp']['max']).toDouble(),
      tempMorning: (json['feels_like']['morn']).toDouble(),
      tempDay: (json['feels_like']['day']).toDouble(),
      tempEvening: (json['feels_like']['eve']).toDouble(),
      tempNight: (json['feels_like']['night']).toDouble(),
      weatherCategory: json['weather'][0]['main'],
      condition: json['weather'][0]['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
      precipitation: ((json['pop']).toDouble() * 100).toStringAsFixed(0),
      clouds: json['clouds'],
      humidity: json['humidity'],
      uvi: (json['uvi']).toDouble(),
      windSpeed: (json['wind_speed']).toDouble(),
    );
  }

  static DailyWeather fromForecastJson(dynamic json) {
    return DailyWeather(
      temp: (json['main']['temp']).toDouble(),
      tempMin: (json['main']['temp_min']).toDouble(),
      tempMax: (json['main']['temp_max']).toDouble(),
      tempMorning: (json['main']['feels_like']).toDouble(),
      tempDay: (json['main']['feels_like']).toDouble(),
      tempEvening: (json['main']['feels_like']).toDouble(),
      tempNight: (json['main']['feels_like']).toDouble(),
      weatherCategory: json['weather'][0]['main'],
      condition: json['weather'][0]['description'],
      date: DateTime.parse(json['dt_txt']),
      precipitation: ((json['pop'] ?? 0.0) * 100).toStringAsFixed(0),
      clouds: json['clouds']['all'],
      humidity: json['main']['humidity'],
      uvi: 0.0, // UV index not available in 5-day forecast API
      windSpeed: (json['wind']['speed']).toDouble(),
    );
  }
}
