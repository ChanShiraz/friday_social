import 'package:flutter/material.dart';

class Weather {
  final DateTime date;
  final double temperature;
  final double minTemperature;
  final String condition;
  final String iconCode;
  final String summary;
  final String sunset;
  final double precipitationMm;

  Weather({
    required this.date,
    required this.temperature,
    this.minTemperature = 10.0,
    required this.condition,
    required this.iconCode,
    this.summary = 'Calm Atmosphere',
    this.sunset = '18:14',
    this.precipitationMm = 0.0,
  });

  String get formattedTemp => '${temperature.round()}°';

  IconData get iconData {
    switch (iconCode) {
      case 'sunny':
      case 'wb_sunny':
        return Icons.wb_sunny_outlined;
      case 'partly_cloudy_day':
      case 'partly_cloudy':
        return Icons.wb_cloudy_outlined;
      case 'rainy':
      case 'rain':
        return Icons.water_drop_outlined;
      case 'cloud':
        return Icons.cloud_outlined;
      case 'foggy':
        return Icons.blur_on;
      case 'air':
      case 'wind':
        return Icons.air;
      default:
        return Icons.wb_sunny_outlined;
    }
  }
}
