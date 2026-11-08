import '../core/weather/weather_service.dart';
import '../models/weather.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  List<Weather> _cachedForecast = [];
  DateTime? _lastBatchTime;
  double? _cachedLat;
  double? _cachedLon;

  WeatherRepository({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService();

  bool get hasCache => _cachedForecast.isNotEmpty;
  DateTime? get lastBatchTime => _lastBatchTime;

  Future<List<Weather>> get16DayForecast({
    required double latitude,
    required double longitude,
    DateTime? startDate,
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    final isSameCoord = _cachedLat != null &&
        (_cachedLat! - latitude).abs() < 0.05 &&
        (_cachedLon! - longitude).abs() < 0.05;

    final isCacheFresh =
        _lastBatchTime != null && now.difference(_lastBatchTime!).inHours < 24;

    if (!forceRefresh && hasCache && isSameCoord && isCacheFresh) {
      return _cachedForecast;
    }

    try {
      final forecast = await _weatherService.fetch16DayForecast(
        latitude: latitude,
        longitude: longitude,
        startDate: startDate,
      );

      _cachedForecast = forecast;
      _lastBatchTime = DateTime.now();
      _cachedLat = latitude;
      _cachedLon = longitude;

      return _cachedForecast;
    } catch (_) {
      if (_cachedForecast.isNotEmpty) {
        return _cachedForecast;
      }
      rethrow;
    }
  }

  String getBatchSyncString() {
    if (_lastBatchTime == null) {
      return 'Batched 12m ago • Cached';
    }
    final diff = DateTime.now().difference(_lastBatchTime!);
    if (diff.inMinutes < 1) {
      return 'Batched just now • Cached';
    } else if (diff.inMinutes < 60) {
      return 'Batched ${diff.inMinutes}m ago • Cached';
    } else {
      return 'Batched ${diff.inHours}h ago • Cached';
    }
  }
}
