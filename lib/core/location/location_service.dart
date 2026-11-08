import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../network/api_client.dart';

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class LocationResult {
  final CityLocation location;
  final LocationPermissionState state;
  final bool isUsingFallback;
  final String statusMessage;

  const LocationResult({
    required this.location,
    required this.state,
    required this.isUsingFallback,
    required this.statusMessage,
  });
}

class CityLocation {
  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  final String atmosphericVibe;
  final bool isLiveGps;
  final bool isFallback;

  const CityLocation({
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.atmosphericVibe,
    this.isLiveGps = false,
    this.isFallback = false,
  });

  String get displayName => region.isNotEmpty ? '$name, $region' : name;
  String get fullTitle => country.isNotEmpty ? '$name, $country' : name;

  CityLocation copyWith({
    String? name,
    String? region,
    String? country,
    double? latitude,
    double? longitude,
    String? atmosphericVibe,
    bool? isLiveGps,
    bool? isFallback,
  }) {
    return CityLocation(
      name: name ?? this.name,
      region: region ?? this.region,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      atmosphericVibe: atmosphericVibe ?? this.atmosphericVibe,
      isLiveGps: isLiveGps ?? this.isLiveGps,
      isFallback: isFallback ?? this.isFallback,
    );
  }
}

class LocationService {
  final ApiClient _apiClient;

  LocationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  static const CityLocation defaultLocation = CityLocation(
    name: 'Marina Bay',
    region: 'Central',
    country: 'Singapore',
    latitude: 1.2847,
    longitude: 103.8610,
    atmosphericVibe: 'Waterfront boardwalks, gardens and evening skyline',
    isFallback: true,
  );

  final List<CityLocation> _curatedLocations = const [
    defaultLocation,
    CityLocation(
      name: 'Chinatown',
      region: 'Central',
      country: 'Singapore',
      latitude: 1.2840,
      longitude: 103.8440,
      atmosphericVibe: 'Heritage shophouses, street food stalls and tea houses',
    ),
    CityLocation(
      name: 'Tiong Bahru',
      region: 'Central',
      country: 'Singapore',
      latitude: 1.2865,
      longitude: 103.8270,
      atmosphericVibe: 'Quiet art-deco streets, local bakeries and bookshops',
    ),
    CityLocation(
      name: 'Orchard',
      region: 'Central',
      country: 'Singapore',
      latitude: 1.3048,
      longitude: 103.8318,
      atmosphericVibe: 'Shopping boulevards, lively cafes and city lights',
    ),
    CityLocation(
      name: 'Kampong Glam',
      region: 'Central',
      country: 'Singapore',
      latitude: 1.3020,
      longitude: 103.8590,
      atmosphericVibe: 'Colorful street art, fabric shops and vibrant cafes',
    ),
    CityLocation(
      name: 'Katong & Joo Chiat',
      region: 'East',
      country: 'Singapore',
      latitude: 1.3050,
      longitude: 103.9030,
      atmosphericVibe: 'Pastel heritage shophouses, coastal breeze and local food',
    ),
    CityLocation(
      name: 'Sentosa',
      region: 'South',
      country: 'Singapore',
      latitude: 1.2500,
      longitude: 103.8300,
      atmosphericVibe: 'Sandy beaches, island trails and sea breezes',
    ),
    CityLocation(
      name: 'Jurong East',
      region: 'West',
      country: 'Singapore',
      latitude: 1.3331,
      longitude: 103.7423,
      atmosphericVibe: 'Lakeside gardens, science park and neighborhood hub',
    ),
    CityLocation(
      name: 'Tampines',
      region: 'East',
      country: 'Singapore',
      latitude: 1.3530,
      longitude: 103.9450,
      atmosphericVibe: 'Green eco-parks, community hub and lively markets',
    ),
    CityLocation(
      name: 'Woodlands',
      region: 'North',
      country: 'Singapore',
      latitude: 1.4382,
      longitude: 103.7890,
      atmosphericVibe: 'Waterfront promenade, coastal pier and nature trails',
    ),
  ];

  CityLocation _chosenFallbackCity = defaultLocation;
  CityLocation _current = defaultLocation;

  CityLocation get currentLocation => _current;
  CityLocation get chosenFallbackCity => _chosenFallbackCity;

  void setChosenFallbackCity(CityLocation city) {
    _chosenFallbackCity = city.copyWith(isFallback: true);
    if (_current.isFallback || !_current.isLiveGps) {
      _current = _chosenFallbackCity;
    }
  }

  void setLocation(CityLocation location) {
    _current = location;
  }

  List<CityLocation> getCuratedLocations() => _curatedLocations;

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  Future<LocationResult> getUserLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      _current = _chosenFallbackCity;
      return LocationResult(
        location: _chosenFallbackCity,
        state: LocationPermissionState.serviceDisabled,
        isUsingFallback: true,
        statusMessage: 'Location service is disabled on device',
      );
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        _current = _chosenFallbackCity;
        return LocationResult(
          location: _chosenFallbackCity,
          state: LocationPermissionState.denied,
          isUsingFallback: true,
          statusMessage: 'Location permission denied by user',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _current = _chosenFallbackCity;
      return LocationResult(
        location: _chosenFallbackCity,
        state: LocationPermissionState.deniedForever,
        isUsingFallback: true,
        statusMessage: 'Location permission permanently denied',
      );
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );

      final liveCity = await _resolveCityFromCoordinates(pos.latitude, pos.longitude);
      _current = liveCity;

      return LocationResult(
        location: liveCity,
        state: LocationPermissionState.granted,
        isUsingFallback: false,
        statusMessage: 'Live GPS active',
      );
    } catch (_) {
      _current = _chosenFallbackCity;
      return LocationResult(
        location: _chosenFallbackCity,
        state: LocationPermissionState.error,
        isUsingFallback: true,
        statusMessage: 'Could not obtain GPS fix',
      );
    }
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final meters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    final km = meters / 1000.0;
    return double.parse(km.toStringAsFixed(1));
  }

  Future<CityLocation> _resolveCityFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String cityName = p.locality ?? '';
        if (cityName.isEmpty) {
          cityName = p.subAdministrativeArea ?? '';
        }
        if (cityName.isEmpty) {
          cityName = p.name ?? '';
        }

        final district = p.subLocality ?? '';
        final region = p.administrativeArea ?? p.country ?? '';
        final country = p.country ?? '';

        final displayName = (district.isNotEmpty && district != cityName && cityName.isNotEmpty)
            ? '$district, $cityName'
            : (cityName.isNotEmpty ? cityName : 'Local City');

        return CityLocation(
          name: displayName,
          region: region.isNotEmpty ? region : country,
          country: country,
          latitude: latitude,
          longitude: longitude,
          atmosphericVibe: 'Live GPS location in $displayName',
          isLiveGps: true,
          isFallback: false,
        );
      }
    } catch (_) {}

    try {
      const endpoint = 'https://api.bigdatacloud.net/data/reverse-geocode-client';
      final data = await _apiClient.get(endpoint, queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'localityLanguage': 'en',
      });

      if (data is Map<String, dynamic>) {
        final city = (data['city'] as String?) ?? (data['locality'] as String?) ?? '';
        final region = (data['principalSubdivision'] as String?) ?? '';
        final country = (data['countryName'] as String?) ?? '';
        final locality = (data['locality'] as String?) ?? '';

        final name = (locality.isNotEmpty && locality != city && city.isNotEmpty)
            ? '$locality, $city'
            : (city.isNotEmpty ? city : locality);

        if (name.isNotEmpty) {
          return CityLocation(
            name: name,
            region: region.isNotEmpty ? region : country,
            country: country,
            latitude: latitude,
            longitude: longitude,
            atmosphericVibe: 'Live GPS location in $name',
            isLiveGps: true,
            isFallback: false,
          );
        }
      }
    } catch (_) {}

    final nearestHub = _findNearestCurated(latitude, longitude);
    final dist = calculateDistance(latitude, longitude, nearestHub.latitude, nearestHub.longitude);

    if (dist <= 25.0) {
      return CityLocation(
        name: nearestHub.name,
        region: nearestHub.region,
        country: nearestHub.country,
        latitude: latitude,
        longitude: longitude,
        atmosphericVibe: 'Live GPS anchor near ${nearestHub.name}',
        isLiveGps: true,
        isFallback: false,
      );
    }

    return CityLocation(
      name: 'Current City',
      region: 'GPS Anchor',
      country: '',
      latitude: latitude,
      longitude: longitude,
      atmosphericVibe: 'Live GPS anchor',
      isLiveGps: true,
      isFallback: false,
    );
  }

  CityLocation _findNearestCurated(double lat, double lon) {
    CityLocation nearest = _curatedLocations.first;
    double minDistance = double.infinity;

    for (final loc in _curatedLocations) {
      final d = calculateDistance(lat, lon, loc.latitude, loc.longitude);
      if (d < minDistance) {
        minDistance = d;
        nearest = loc;
      }
    }
    return nearest;
  }
}
