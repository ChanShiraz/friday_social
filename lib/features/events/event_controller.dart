import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';

class EventController extends GetxController {
  final EventRepository eventRepository;
  final SharedPreferences? customPrefs;

  static const String _rsvpPrefix = 'rsvp_status_';

  late final Rx<Event> event;
  final RxBool isSaved = false.obs;
  final RxBool isAttending = false.obs;
  final RxBool isSubmittingRsvp = false.obs;

  StreamSubscription<Event?>? _eventSubscription;

  EventController({
    required Event initialEvent,
    EventRepository? repo,
    SharedPreferences? prefs,
  })  : eventRepository = repo ?? EventRepository(),
        customPrefs = prefs {
    event = initialEvent.obs;
    isSaved.value = initialEvent.isSaved;
    _loadRsvpFromPrefs();
    _subscribeToLiveEvent();
  }

  @override
  void onInit() {
    super.onInit();
    if (_eventSubscription == null) {
      _subscribeToLiveEvent();
    }
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    super.onClose();
  }

  void _subscribeToLiveEvent() {
    _eventSubscription = eventRepository.streamEvent(event.value.id).listen((liveEvent) {
      if (liveEvent != null) {
        event.value = liveEvent.copyWith(
          distanceKm: event.value.distanceKm,
          isSaved: isSaved.value,
        );
      }
    });
  }

  Future<void> fetchLiveEvent() async {
    try {
      final liveEvent = await eventRepository.getEventById(event.value.id);
      if (liveEvent != null) {
        event.value = liveEvent.copyWith(
          distanceKm: event.value.distanceKm,
          isSaved: isSaved.value,
        );
      }
    } catch (_) {}
  }

  Future<void> _loadRsvpFromPrefs() async {
    try {
      final prefs = customPrefs ?? await SharedPreferences.getInstance();
      final savedRsvp = prefs.getBool('$_rsvpPrefix${event.value.id}');
      if (savedRsvp != null) {
        isAttending.value = savedRsvp;
      }
    } catch (_) {}
  }

  Future<void> _saveRsvpToPrefs(bool isGoing) async {
    try {
      final prefs = customPrefs ?? await SharedPreferences.getInstance();
      await prefs.setBool('$_rsvpPrefix${event.value.id}', isGoing);
    } catch (_) {}
  }

  Future<void> toggleSave() async {
    final newSavedStatus = await eventRepository.toggleSave(event.value.id);
    isSaved.value = newSavedStatus;
    event.value = event.value.copyWith(isSaved: newSavedStatus);

    _safeSnackbar(
      title: newSavedStatus ? 'Saved to atmosphere list' : 'Removed from saved',
      message: event.value.title,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> toggleAttend() async {
    if (isSubmittingRsvp.value) return;

    final previousAttending = isAttending.value;
    final previousAttendeesCount = event.value.attendeesCount;
    final willJoin = !previousAttending;

    isAttending.value = willJoin;
    final maxCap = event.value.capacity ?? 999999;
    final optimisticCount = willJoin
        ? previousAttendeesCount + 1
        : (previousAttendeesCount - 1).clamp(0, maxCap);
    event.value = event.value.copyWith(attendeesCount: optimisticCount);

    _saveRsvpToPrefs(willJoin);
    isSubmittingRsvp.value = true;

    try {
      await eventRepository.rsvpEvent(
        eventId: event.value.id,
        isJoining: willJoin,
      );

      _safeSnackbar(
        title: willJoin ? "You're Going!" : 'Reservation Cancelled',
        message: willJoin
            ? 'Your spot has been reserved.'
            : 'Your spot was released.',
        duration: const Duration(seconds: 2),
      );
    } on RsvpConflictException catch (e) {
      isAttending.value = previousAttending;
      event.value = event.value.copyWith(attendeesCount: previousAttendeesCount);
      _saveRsvpToPrefs(previousAttending);

      _safeSnackbar(
        title: 'RSVP Conflict (409)',
        message: e.message,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: const Color(0xFFFFFFFF),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } catch (_) {
      isAttending.value = previousAttending;
      event.value = event.value.copyWith(attendeesCount: previousAttendeesCount);
      _saveRsvpToPrefs(previousAttending);

      _safeSnackbar(
        title: 'RSVP Failed',
        message: 'Could not update reservation. Reverted to previous state.',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSubmittingRsvp.value = false;
    }
  }

  void _safeSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    Widget? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor ?? const Color(0xFF2C241D),
        colorText: colorText ?? const Color(0xFFFBF6EE),
        icon: icon,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: duration,
        isDismissible: true,
      );
    } catch (_) {}
  }
}
