import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/weather.dart';
import '../../models/event.dart';
import '../../repositories/weather_repository.dart';
import '../../repositories/event_repository.dart';
import '../../core/location/location_service.dart';

class CalendarController extends GetxController with WidgetsBindingObserver {
  final WeatherRepository weatherRepository;
  final EventRepository eventRepository;
  final LocationService locationService;

  CalendarController({
    WeatherRepository? weatherRepo,
    EventRepository? eventRepo,
    LocationService? locService,
  })  : weatherRepository = weatherRepo ?? WeatherRepository(),
        eventRepository = eventRepo ?? EventRepository(),
        locationService = locService ?? LocationService() {
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day).obs;
    currentMonth = DateTime(now.year, now.month, 1).obs;
    chosenFallbackCity = locationService.chosenFallbackCity.obs;
    currentLocation = locationService.currentLocation.obs;
  }

  late final Rx<DateTime> selectedDate;
  late final Rx<DateTime> currentMonth;

  final RxDouble selectedRadiusKm = 10.0.obs;
  final RxList<Weather> days16Forecast = <Weather>[].obs;
  final RxList<Event> selectedDayEvents = <Event>[].obs;
  final RxList<Event> allUpcomingEvents = <Event>[].obs;
  final RxMap<String, int> eventCountsMap = <String, int>{}.obs;

  final RxBool isLoading = false.obs;
  final RxString batchStatus = 'Batched 12m ago • Cached'.obs;

  late final Rx<CityLocation> currentLocation;
  final RxBool isLiveGps = false.obs;
  final RxBool isUsingFallback = false.obs;
  final RxBool isLocationServiceDisabled = false.obs;
  final RxBool isPermissionDenied = false.obs;
  final RxString locationStatusMessage = ''.obs;
  late final Rx<CityLocation> chosenFallbackCity;

  StreamSubscription<List<Event>>? _eventsSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initLocationAndLoad();
    _subscribeToLiveEvents();
  }

  @override
  void onClose() {
    _eventsSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationOnResume();
    }
  }

  void _subscribeToLiveEvents() {
    if (!eventRepository.isFirebaseAvailable) return;
    _eventsSubscription = eventRepository.streamAllRawEvents().listen((events) {
      if (events.isNotEmpty) {
        _applyRawEventsToState(events);
      }
    });
  }

  void _applyRawEventsToState(List<Event> rawEvents) {
    final loc = currentLocation.value;
    final maxRadiusKm = selectedRadiusKm.value;
    final date = selectedDate.value;

    final List<Event> allFiltered = [];
    final List<Event> dayFiltered = [];

    for (final e in rawEvents) {
      final dist = locationService.calculateDistance(
        loc.latitude,
        loc.longitude,
        e.latitude,
        e.longitude,
      );

      if (dist <= maxRadiusKm) {
        final withDist = e.copyWith(distanceKm: dist);
        allFiltered.add(withDist);

        if (e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day) {
          dayFiltered.add(withDist);
        }
      }
    }

    allFiltered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    dayFiltered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    allUpcomingEvents.assignAll(allFiltered);
    _updateEventCountsFromList(allFiltered);
    selectedDayEvents.assignAll(dayFiltered);
  }

  Future<void> _checkLocationOnResume() async {
    final enabled = await locationService.isLocationServiceEnabled();
    if (enabled && (isLocationServiceDisabled.value || isUsingFallback.value)) {
      await retryGpsLocation();
    }
  }

  Future<void> initLocationAndLoad() async {
    isLoading.value = true;
    try {
      final locResult = await locationService.getUserLocation();
      currentLocation.value = locResult.location;
      isLiveGps.value = !locResult.isUsingFallback;
      isUsingFallback.value = locResult.isUsingFallback;
      locationStatusMessage.value = locResult.statusMessage;

      isLocationServiceDisabled.value =
          locResult.state == LocationPermissionState.serviceDisabled;
      isPermissionDenied.value =
          locResult.state == LocationPermissionState.denied ||
          locResult.state == LocationPermissionState.deniedForever;
    } catch (_) {
    } finally {
      await loadData();
    }
  }

  Future<void> openLocationSettingsAndRetry() async {
    await locationService.openLocationSettings();

    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      final enabled = await locationService.isLocationServiceEnabled();
      if (enabled) {
        await retryGpsLocation();
        break;
      }
    }
  }

  String get locationDisplayString {
    final name = currentLocation.value.name;
    final radius = selectedRadiusKm.value.toInt();
    final gpsTag = isLiveGps.value ? ' (GPS)' : '';
    return '$name$gpsTag, $radius km';
  }

  String get locationSubTitle {
    if (isLiveGps.value) {
      return 'Live GPS • Within ${selectedRadiusKm.value.toInt()} km';
    }
    return 'Near ${currentLocation.value.name}, ${currentLocation.value.region}';
  }

  Weather? get selectedDayWeather {
    try {
      final sel = selectedDate.value;
      return days16Forecast.firstWhere(
        (w) => w.date.year == sel.year && w.date.month == sel.month && w.date.day == sel.day,
      );
    } catch (_) {
      return days16Forecast.isNotEmpty ? days16Forecast.first : null;
    }
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    isLoading.value = true;
    try {
      final loc = currentLocation.value;

      final forecast = await weatherRepository.get16DayForecast(
        latitude: loc.latitude,
        longitude: loc.longitude,
        startDate: selectedDate.value,
        forceRefresh: forceRefresh,
      );

      days16Forecast.assignAll(forecast);
      batchStatus.value = weatherRepository.getBatchSyncString();

      final allEvts = await eventRepository.getAllEvents(
        userLat: loc.latitude,
        userLon: loc.longitude,
        maxRadiusKm: selectedRadiusKm.value,
        forceRefresh: forceRefresh,
      );
      allUpcomingEvents.assignAll(allEvts);
      _updateEventCountsFromList(allEvts);

      await _refreshEventsForDay(selectedDate.value, forceRefresh: forceRefresh);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshEventsForDay(DateTime date, {bool forceRefresh = false}) async {
    final loc = currentLocation.value;
    final events = await eventRepository.getEventsForDate(
      date,
      userLat: loc.latitude,
      userLon: loc.longitude,
      maxRadiusKm: selectedRadiusKm.value,
      forceRefresh: forceRefresh,
    );
    selectedDayEvents.assignAll(events);
  }

  List<DateTime> getCalendarDaysForMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final leadingDays = firstDayOfMonth.weekday - 1;
    final startDate = firstDayOfMonth.subtract(Duration(days: leadingDays));

    final totalDaysInMonth = lastDayOfMonth.day;
    final totalCellsNeeded = leadingDays + totalDaysInMonth;
    final totalCells = totalCellsNeeded > 35 ? 42 : 35;

    return List.generate(totalCells, (index) {
      final day = startDate.add(Duration(days: index));
      return DateTime(day.year, day.month, day.day);
    });
  }

  void _updateEventCountsFromList(List<Event> events) {
    final Map<String, int> counts = {};
    for (final e in events) {
      final key = _dayKey(e.date);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    eventCountsMap.assignAll(counts);
  }

  String _dayKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  int getEventCountForDate(DateTime date) {
    return eventCountsMap[_dayKey(date)] ?? 0;
  }

  Weather? getWeatherForDate(DateTime date) {
    try {
      return days16Forecast.firstWhere(
        (w) => w.date.year == date.year && w.date.month == date.month && w.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    if (currentMonth.value.year != date.year || currentMonth.value.month != date.month) {
      currentMonth.value = DateTime(date.year, date.month, 1);
    }
    _refreshEventsForDay(selectedDate.value);
  }

  int _radiusRequestId = 0;

  void setRadius(double radius) async {
    if (selectedRadiusKm.value == radius) return;

    selectedRadiusKm.value = radius;
    final currentRequestId = ++_radiusRequestId;

    final loc = currentLocation.value;
    final allEvts = await eventRepository.getAllEvents(
      userLat: loc.latitude,
      userLon: loc.longitude,
      maxRadiusKm: radius,
    );

    if (currentRequestId != _radiusRequestId) return;

    allUpcomingEvents.assignAll(allEvts);
    _updateEventCountsFromList(allEvts);
    await _refreshEventsForDay(selectedDate.value);
  }

  Future<void> refreshEvents() async {
    final loc = currentLocation.value;
    final allEvts = await eventRepository.getAllEvents(
      userLat: loc.latitude,
      userLon: loc.longitude,
      maxRadiusKm: selectedRadiusKm.value,
      forceRefresh: true,
    );
    allUpcomingEvents.assignAll(allEvts);
    _updateEventCountsFromList(allEvts);
    await _refreshEventsForDay(selectedDate.value);
  }

  void setChosenFallbackCity(CityLocation city) {
    chosenFallbackCity.value = city;
    locationService.setChosenFallbackCity(city);

    if (isUsingFallback.value || !isLiveGps.value) {
      setLocation(city);
    }
  }

  void setLocation(CityLocation location) {
    currentLocation.value = location;
    isLiveGps.value = location.isLiveGps;
    isUsingFallback.value = location.isFallback;
    locationService.setLocation(location);
    loadData(forceRefresh: true);
  }

  Future<void> retryGpsLocation() async {
    isLoading.value = true;
    try {
      final result = await locationService.getUserLocation();
      currentLocation.value = result.location;
      isLiveGps.value = !result.isUsingFallback;
      isUsingFallback.value = result.isUsingFallback;
      isLocationServiceDisabled.value =
          result.state == LocationPermissionState.serviceDisabled;
      locationStatusMessage.value = result.statusMessage;

      await loadData(forceRefresh: true);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void goToToday() {
    final now = DateTime.now();
    currentMonth.value = DateTime(now.year, now.month, 1);
    selectDate(DateTime(now.year, now.month, now.day));
  }

  void previousMonth() {
    final prev = DateTime(currentMonth.value.year, currentMonth.value.month - 1, 1);
    currentMonth.value = prev;
    selectedDate.value = DateTime(prev.year, prev.month, 1);
    _refreshEventsForDay(selectedDate.value);
  }

  void nextMonth() {
    final next = DateTime(currentMonth.value.year, currentMonth.value.month + 1, 1);
    currentMonth.value = next;
    selectedDate.value = DateTime(next.year, next.month, 1);
    _refreshEventsForDay(selectedDate.value);
  }

  void previousDay() {
    selectDate(selectedDate.value.subtract(const Duration(days: 1)));
  }

  void nextDay() {
    selectDate(selectedDate.value.add(const Duration(days: 1)));
  }
}
