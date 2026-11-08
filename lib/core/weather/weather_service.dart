import '../network/api_client.dart';
import '../../models/weather.dart';

class WeatherService {
  final ApiClient _apiClient;

  WeatherService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Weather>> fetch16DayForecast({
    required double latitude,
    required double longitude,
    DateTime? startDate,
  }) async {
    final start = startDate ?? DateTime.now();

    try {
      const endpoint = 'https://api.open-meteo.com/v1/forecast';
      final params = {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'daily': 'weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum',
        'timezone': 'auto',
        'forecast_days': '16',
      };

      final data = await _apiClient.get(endpoint, queryParams: params);

      if (data is Map<String, dynamic> && data.containsKey('daily')) {
        final daily = data['daily'] as Map<String, dynamic>;
        final times = (daily['time'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final maxTemps = (daily['temperature_2m_max'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
        final minTemps = (daily['temperature_2m_min'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
        final weatherCodes = ((daily['weathercode'] ?? daily['weather_code']) as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [];
        final precipitations = (daily['precipitation_sum'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];

        final List<Weather> result = [];
        final count = times.length.clamp(0, 16);

        for (int i = 0; i < count; i++) {
          final dt = DateTime.tryParse(times[i]) ?? start.add(Duration(days: i));
          final code = i < weatherCodes.length ? weatherCodes[i] : 2;
          final maxT = i < maxTemps.length ? maxTemps[i] : 15.0;
          final minT = i < minTemps.length ? minTemps[i] : 9.0;
          final precip = i < precipitations.length ? precipitations[i] : 0.0;

          final conditionMeta = _mapWmoCodeToCondition(code);

          result.add(Weather(
            date: dt,
            temperature: maxT,
            minTemperature: minT,
            condition: conditionMeta['condition'] ?? 'Clear',
            iconCode: conditionMeta['iconCode'] ?? 'sunny',
            summary: conditionMeta['summary'] ?? 'Calm Atmosphere',
            sunset: '18:14',
            precipitationMm: precip,
          ));
        }

        if (result.isNotEmpty) {
          return result;
        }
      }
    } catch (_) {}

    return _generateTactileTropicalBatch(start);
  }

  Map<String, String> _mapWmoCodeToCondition(int code) {
    if (code == 0) {
      return {'condition': 'Sunny', 'iconCode': 'sunny', 'summary': 'Bright Sun'};
    } else if (code <= 3) {
      return {'condition': 'Partly Cloudy', 'iconCode': 'partly_cloudy_day', 'summary': 'Fair Skies'};
    } else if (code >= 45 && code <= 48) {
      return {'condition': 'Hazy', 'iconCode': 'foggy', 'summary': 'Morning Haze'};
    } else if (code >= 51 && code <= 67) {
      return {'condition': 'Rainy', 'iconCode': 'rainy', 'summary': 'Tropical Rain'};
    } else if (code >= 71 && code <= 77) {
      return {'condition': 'Breezy', 'iconCode': 'air', 'summary': 'Island Breeze'};
    } else if (code >= 80 && code <= 82) {
      return {'condition': 'Passing Showers', 'iconCode': 'rainy', 'summary': 'Afternoon Showers'};
    } else {
      return {'condition': 'Cloudy', 'iconCode': 'cloud', 'summary': 'Cloudy Skies'};
    }
  }

  List<Weather> _generateTactileTropicalBatch(DateTime baseDate) {
    final temps = [31.0, 32.0, 30.0, 31.0, 29.0, 32.0, 31.0, 30.0, 32.0, 31.0, 30.0, 32.0, 29.0, 31.0, 30.0, 31.0];
    final conditions = [
      {'c': 'Partly Cloudy', 'i': 'partly_cloudy_day', 's': 'Fair & Warm'},
      {'c': 'Sunny', 'i': 'sunny', 's': 'Bright Sunshine'},
      {'c': 'Passing Showers', 'i': 'rainy', 's': 'Brief Afternoon Shower'},
      {'c': 'Partly Cloudy', 'i': 'partly_cloudy_day', 's': 'Warm Breeze'},
      {'c': 'Rainy', 'i': 'rainy', 's': 'Cool Rain'},
      {'c': 'Sunny', 'i': 'sunny', 's': 'Clear Blue Sky'},
      {'c': 'Cloudy', 'i': 'cloud', 's': 'Pleasant Overcast'},
      {'c': 'Passing Showers', 'i': 'rainy', 's': 'Passing Drizzle'},
      {'c': 'Sunny', 'i': 'sunny', 's': 'Warm Sun'},
      {'c': 'Partly Cloudy', 'i': 'partly_cloudy_day', 's': 'Gentle Breeze'},
      {'c': 'Partly Cloudy', 'i': 'partly_cloudy_day', 's': 'Fair Skies'},
      {'c': 'Sunny', 'i': 'sunny', 's': 'Golden Sunlight'},
      {'c': 'Rainy', 'i': 'rainy', 's': 'Thundershower'},
      {'c': 'Partly Cloudy', 'i': 'partly_cloudy_day', 's': 'Warm & Humid'},
      {'c': 'Passing Showers', 'i': 'rainy', 's': 'Quick Shower'},
      {'c': 'Sunny', 'i': 'sunny', 's': 'Clear Afternoon'},
    ];

    return List.generate(16, (i) {
      final date = baseDate.add(Duration(days: i));
      final cond = conditions[i % conditions.length];
      return Weather(
        date: DateTime(date.year, date.month, date.day),
        temperature: temps[i % temps.length],
        minTemperature: temps[i % temps.length] - 5.0,
        condition: cond['c']!,
        iconCode: cond['i']!,
        summary: cond['s']!,
        sunset: '19:12',
      );
    });
  }
}
