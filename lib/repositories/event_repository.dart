import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/event.dart';
import '../core/location/location_service.dart';

class RsvpConflictException implements Exception {
  final int statusCode;
  final String message;

  const RsvpConflictException([
    this.message = "This event is full. You couldn't join.",
    this.statusCode = 409,
  ]);

  @override
  String toString() => 'RsvpConflictException($statusCode): $message';
}

class EventRepository {
  final LocationService _locationService;
  final FirebaseFirestore? _customFirestore;
  final List<Event> _localFallbackEvents = [];

  List<Event>? _cachedRawEvents;

  EventRepository({
    LocationService? locationService,
    FirebaseFirestore? firestore,
  })  : _locationService = locationService ?? LocationService(),
        _customFirestore = firestore {
    _initCuratedEvents();
  }

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  bool get isFirebaseAvailable => _firestore != null;

  void invalidateCache() {
    _cachedRawEvents = null;
  }

  void _initCuratedEvents() {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);

    _localFallbackEvents.addAll([
      Event(
        id: 'evt-1',
        title: 'Morning Coffee Tasting & Brewing',
        description:
            'Try different fresh coffee beans and learn easy brewing tips from friendly local baristas. Great for anyone who enjoys good coffee.',
        date: base,
        time: '08:30',
        endTime: '10:00',
        venue: 'Nylon Coffee Roasters',
        address: '4 Everton Park, #01-40, Singapore 080004',
        latitude: 1.2778,
        longitude: 103.8398,
        category: 'Food & Drinks',
        accentColorValue: 0xFFA23E18,
        weatherNote: 'Air-conditioned indoor café • Free cold water',
        attendeesCount: 14,
        capacity: 30,
      ),
      Event(
        id: 'evt-2',
        title: 'Art Gallery Night & Painting Exhibition',
        description:
            'Walk through a new painting exhibition and chat with local artists. Free snacks, wine, and fruit juice are provided.',
        date: base,
        time: '17:00',
        endTime: '19:30',
        venue: 'National Gallery Singapore',
        address: '1 St Andrew\'s Road, Singapore 178957',
        latitude: 1.2903,
        longitude: 103.8519,
        category: 'Art & Design',
        accentColorValue: 0xFF73859F,
        weatherNote: 'Cool indoor gallery halls • Sheltered walk from MRT',
        attendeesCount: 38,
        capacity: 60,
        isSaved: true,
      ),
      Event(
        id: 'evt-3',
        title: 'Live Acoustic Music & Vinyl Night',
        description:
            'A relaxing evening of live acoustic songs and vintage vinyl records in a cozy lounge with comfortable seats and good drinks.',
        date: base,
        time: '20:15',
        endTime: '22:30',
        venue: 'The Projector Lounge, Golden Mile',
        address: '6001 Beach Road, Singapore 199589',
        latitude: 1.3025,
        longitude: 103.8635,
        category: 'Music',
        accentColorValue: 0xFFFE8357,
        weatherNote: 'Cozy indoor lounge • Air-conditioned and relaxing',
        attendeesCount: 45,
        capacity: 100,
      ),
      Event(
        id: 'evt-4',
        title: 'Sourdough Bread Baking Class',
        description:
            'Learn how to mix, shape, and bake crusty sourdough bread at home with simple steps. You will take home your own fresh warm loaf.',
        date: base.add(const Duration(days: 1)),
        time: '10:00',
        endTime: '12:30',
        venue: 'Micro Bakery & Kitchen, Tiong Bahru',
        address: 'Eng Hoon Street, Singapore 160078',
        latitude: 1.2852,
        longitude: 103.8335,
        category: 'Workshop',
        accentColorValue: 0xFFA23E18,
        weatherNote: 'Warm bakery kitchen • Refreshing iced tea provided',
        attendeesCount: 10,
        capacity: 15,
      ),
      Event(
        id: 'evt-5',
        title: 'Community Dinner & Food Meetup',
        description:
            'Sit together at long tables to eat famous local street dishes like chicken rice and satay skewers, and meet friendly new people.',
        date: base.add(const Duration(days: 2)),
        time: '18:00',
        endTime: '21:00',
        venue: 'Lau Pa Sat Satay Street',
        address: '18 Raffles Quay, Singapore 048582',
        latitude: 1.2806,
        longitude: 103.8504,
        category: 'Social',
        accentColorValue: 0xFFA23E18,
        weatherNote: 'Open-air dining street with warm evening breeze',
        attendeesCount: 22,
        capacity: 50,
      ),
      Event(
        id: 'evt-6',
        title: 'Vintage Flea Market & Indie Crafts',
        description:
            'Browse clothes, handcrafted candles, retro film cameras, and handmade jewelry in a lively neighborhood lane.',
        date: base.add(const Duration(days: 2)),
        time: '14:00',
        endTime: '19:00',
        venue: 'Haji Lane Pedestrian Walk',
        address: 'Haji Lane, Singapore 189244',
        latitude: 1.3008,
        longitude: 103.8591,
        category: 'Shopping',
        accentColorValue: 0xFF73859F,
        weatherNote: 'Sunny and breezy • Cold iced coffee stands nearby',
        attendeesCount: 35,
        capacity: 80,
      ),
      Event(
        id: 'evt-7',
        title: 'Sunset Rooftop Yoga & Stretch',
        description:
            'Stretch and unwind after work with light yoga poses while the sky turns orange and pink over the skyline. Mats are provided free.',
        date: base.add(const Duration(days: 4)),
        time: '18:30',
        endTime: '19:45',
        venue: 'Marina Bay Sands SkyPark Observation Deck',
        address: '10 Bayfront Avenue, Singapore 018956',
        latitude: 1.2838,
        longitude: 103.8607,
        category: 'Wellness',
        accentColorValue: 0xFFFE8357,
        weatherNote: 'Gentle sea breeze • Sunset expected at 7:10 PM',
        attendeesCount: 18,
        capacity: 25,
      ),
      Event(
        id: 'evt-8',
        title: 'Morning Waterfront Jogging Club',
        description:
            'A casual, friendly 5-kilometer morning run along the calm water with scenic views. Run at your own comfortable pace.',
        date: base.add(const Duration(days: 6)),
        time: '07:00',
        endTime: '08:30',
        venue: 'Marina Barrage Green Roof',
        address: '8 Marina Gardens Drive, Singapore 018951',
        latitude: 1.2805,
        longitude: 103.8710,
        category: 'Fitness',
        accentColorValue: 0xFFA23E18,
        weatherNote: 'Cool morning breeze • Drinking water stations along track',
        attendeesCount: 20,
        capacity: 40,
      ),
      Event(
        id: 'evt-9',
        title: 'Botanical Sketching & Drawing Walk',
        description:
            'Draw orchids, tall tropical trees, and green lily ponds with guidance from a local artist. Pencils and sketchbooks are included.',
        date: base.add(const Duration(days: 7)),
        time: '15:30',
        endTime: '17:30',
        venue: 'Singapore Botanic Gardens, Tanglin Gate',
        address: '1 Cluny Road, Singapore 259569',
        latitude: 1.3138,
        longitude: 103.8159,
        category: 'Art & Design',
        accentColorValue: 0xFF73859F,
        weatherNote: 'Shaded park pavilions • Covered rain shelter available',
        attendeesCount: 12,
        capacity: 20,
      ),
      Event(
        id: 'evt-10',
        title: 'Evening City Skyline Photography Walk',
        description:
            'Learn how to take sharp, beautiful night photos of reflections, lit bridges, and glowing skyscrapers with your phone or camera.',
        date: base.add(const Duration(days: 9)),
        time: '19:15',
        endTime: '21:15',
        venue: 'Helix Bridge & Promontory',
        address: '10 Bayfront Avenue, Singapore 018956',
        latitude: 1.2830,
        longitude: 103.8590,
        category: 'Photography',
        accentColorValue: 0xFF73859F,
        weatherNote: 'Sunny with white clouds • Comfortable walking shoes',
        attendeesCount: 15,
        capacity: 25,
      ),
      Event(
        id: 'evt-11',
        title: 'Night Street Food Crawl',
        description:
            'Taste famous dishes like crispy spring rolls, fried noodles, and fresh sugarcane juice at one of the city\'s best food centres.',
        date: base.add(const Duration(days: 10)),
        time: '18:30',
        endTime: '21:00',
        venue: 'Old Airport Road Food Centre',
        address: '51 Old Airport Road, Singapore 390051',
        latitude: 1.3082,
        longitude: 103.8858,
        category: 'Food & Drinks',
        accentColorValue: 0xFFA23E18,
        weatherNote: 'Bustling open-air food market with high ceiling fans',
        attendeesCount: 25,
        capacity: 50,
      ),
      Event(
        id: 'evt-12',
        title: 'Lakeside Morning Walk & Bird Watching',
        description:
            'Take a calm morning walk along wooden boardwalks and grassy hills. Spot kingfishers, herons, and butterflies around the lake.',
        date: base.add(const Duration(days: 12)),
        time: '07:30',
        endTime: '09:30',
        venue: 'Jurong Lake Gardens Lakeside Boardwalk',
        address: '104 Yuan Ching Road, Singapore 618665',
        latitude: 1.3390,
        longitude: 103.7290,
        category: 'Outdoors & Nature',
        accentColorValue: 0xFF73859F,
        weatherNote: 'Cool morning air • Shaded trees along the path',
        attendeesCount: 16,
        capacity: 35,
      ),
      Event(
        id: 'evt-13',
        title: 'Northern Waterfront Pier & Sunset Walk',
        description:
            'Walk along Singapore\'s longest coastal wooden pier. Enjoy wide sea views, cool evening breezes, and a peaceful orange sunset.',
        date: base.add(const Duration(days: 14)),
        time: '17:30',
        endTime: '19:30',
        venue: 'Woodlands Waterfront Park Jetty',
        address: '6A Admiralty Road West, Singapore 759956',
        latitude: 1.4530,
        longitude: 103.7820,
        category: 'Outdoors & Nature',
        accentColorValue: 0xFFFE8357,
        weatherNote: 'Refreshing sea breeze • Sunset at 7:12 PM',
        attendeesCount: 24,
        capacity: 50,
      ),
      Event(
        id: 'evt-tampines-1',
        title: 'Tampines Eco Green Park Walk',
        description:
            'Walk through freshwater wetlands and forest trails surrounded by green trees, flowers, and birds in East Singapore.',
        date: base,
        time: '09:00',
        endTime: '11:00',
        venue: 'Tampines Eco Green',
        address: 'Tampines Avenue 9, Singapore 520491',
        latitude: 1.3580,
        longitude: 103.9380,
        category: 'Outdoors & Nature',
        accentColorValue: 0xFFA23E18,
        weatherNote: 'Gentle morning sunshine • Bring water bottle',
        attendeesCount: 15,
        capacity: 30,
      ),
      Event(
        id: 'evt-jurong-1',
        title: 'Stargazing & Telescope Night',
        description:
            'Look through large telescopes to see the moon craters, Jupiter, and bright stars with friendly astronomy hobbyists.',
        date: base,
        time: '19:30',
        endTime: '21:30',
        venue: 'Science Centre Singapore Observatory',
        address: '15 Science Centre Road, Singapore 609081',
        latitude: 1.3325,
        longitude: 103.7360,
        category: 'Science & Tech',
        accentColorValue: 0xFFFE8357,
        weatherNote: 'Clear night sky • Open observatory roof',
        attendeesCount: 30,
        capacity: 50,
      ),
      Event(
        id: 'evt-sentosa-1',
        title: 'Beach Volleyball & Seaside Picnic',
        description:
            'Play casual volleyball games on soft white sand, then sit together for cold drinks and snacks by the water.',
        date: base,
        time: '16:00',
        endTime: '19:00',
        venue: 'Siloso Beach, Sentosa',
        address: '10A Siloso Beach Walk, Singapore 099008',
        latitude: 1.2530,
        longitude: 103.8180,
        category: 'Social & Sports',
        accentColorValue: 0xFF73859F,
        weatherNote: 'Warm beach weather • Coconut water available',
        attendeesCount: 20,
        capacity: 40,
      ),
      Event(
        id: 'evt-full-demo',
        title: 'Exclusive Rooftop Jazz (At Capacity)',
        description:
            'An intimate rooftop gathering with strictly limited private seats. This event is at maximum capacity, allowing immediate demonstration and verification of HTTP 409 Conflict rollback.',
        date: base,
        time: '21:00',
        endTime: '23:30',
        venue: 'CÉ LA VI SkyBar, Marina Bay Sands',
        address: '1 Bayfront Avenue, Singapore 018971',
        latitude: 1.2840,
        longitude: 103.8600,
        category: 'Music',
        accentColorValue: 0xFFA23E18,
        weatherNote: 'Night breeze • Strictly capped attendance',
        attendeesCount: 30,
        capacity: 30,
      ),
    ]);
  }

  Future<List<Event>> _fetchRawEvents({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedRawEvents != null && _cachedRawEvents!.isNotEmpty) {
      return _cachedRawEvents!;
    }

    if (_firestore != null) {
      try {
        final querySnapshot = await _firestore!.collection('events').get();
        if (querySnapshot.docs.isNotEmpty) {
          _cachedRawEvents = querySnapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();
          return _cachedRawEvents!;
        }
      } catch (_) {}
    }

    _cachedRawEvents = List.from(_localFallbackEvents);
    return _cachedRawEvents!;
  }

  Future<List<Event>> getEventsForDate(
    DateTime date, {
    required double userLat,
    required double userLon,
    double maxRadiusKm = 10.0,
    bool forceRefresh = false,
  }) async {
    final rawEvents = await _fetchRawEvents(forceRefresh: forceRefresh);
    final List<Event> filtered = [];

    for (final e in rawEvents) {
      final isSameDay = e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;

      if (!isSameDay) continue;

      final dist = _locationService.calculateDistance(
        userLat,
        userLon,
        e.latitude,
        e.longitude,
      );

      if (dist <= maxRadiusKm) {
        filtered.add(e.copyWith(distanceKm: dist));
      }
    }

    filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return filtered;
  }

  Future<List<Event>> getAllEvents({
    required double userLat,
    required double userLon,
    double maxRadiusKm = 10.0,
    bool forceRefresh = false,
  }) async {
    final rawEvents = await _fetchRawEvents(forceRefresh: forceRefresh);
    final List<Event> filtered = [];

    for (final e in rawEvents) {
      final dist = _locationService.calculateDistance(
        userLat,
        userLon,
        e.latitude,
        e.longitude,
      );

      if (dist <= maxRadiusKm) {
        filtered.add(e.copyWith(distanceKm: dist));
      }
    }

    filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return filtered;
  }

  Future<bool> toggleSave(String eventId) async {
    final index = _localFallbackEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final current = _localFallbackEvents[index];
      _localFallbackEvents[index] = current.copyWith(isSaved: !current.isSaved);
      return _localFallbackEvents[index].isSaved;
    }
    return false;
  }

  Future<void> rsvpEvent({
    required String eventId,
    required bool isJoining,
  }) async {
    if (_firestore != null) {
      final docRef = _firestore!.collection('events').doc(eventId);
      bool handledInFirestore = false;

      try {
        await _firestore!.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) {
            return;
          }
          handledInFirestore = true;

          final data = snapshot.data() ?? {};
          final currentAttendees = (data['attendeesCount'] as num?)?.toInt() ?? 0;
          final rawCap = data['capacity'];
          final int? capacity = rawCap is num
              ? rawCap.toInt()
              : (rawCap is String ? int.tryParse(rawCap.trim()) : null);

          if (isJoining) {
            if (capacity != null && currentAttendees >= capacity) {
              throw const RsvpConflictException(
                "This event is full. You couldn't join.",
                409,
              );
            }
            transaction.update(docRef, {
              'attendeesCount': currentAttendees + 1,
            });
          } else {
            final newCount = capacity != null
                ? (currentAttendees - 1).clamp(0, capacity)
                : (currentAttendees - 1 < 0 ? 0 : currentAttendees - 1);
            transaction.update(docRef, {
              'attendeesCount': newCount,
            });
          }
        });
      } on RsvpConflictException {
        rethrow;
      } catch (e) {
        if (e is RsvpConflictException) rethrow;
        if (e.toString().contains('409') || e.toString().contains('full')) {
          throw const RsvpConflictException(
            "This event is full. You couldn't join.",
            409,
          );
        }
        if (handledInFirestore) {
          rethrow;
        }
      }

      if (handledInFirestore) {
        if (_cachedRawEvents != null) {
          final cacheIdx = _cachedRawEvents!.indexWhere((e) => e.id == eventId);
          if (cacheIdx != -1) {
            final old = _cachedRawEvents![cacheIdx];
            final maxCap = old.capacity ?? 999999;
            final newCount = isJoining
                ? old.attendeesCount + 1
                : (old.attendeesCount - 1).clamp(0, maxCap);
            _cachedRawEvents![cacheIdx] = old.copyWith(attendeesCount: newCount);
          }
        }
        return;
      }
    }

    final index = _localFallbackEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final current = _localFallbackEvents[index];
      if (isJoining && current.isFull) {
        throw const RsvpConflictException(
          "This event is full. You couldn't join.",
          409,
        );
      }
      final maxCap = current.capacity ?? 999999;
      final newCount = isJoining
          ? current.attendeesCount + 1
          : (current.attendeesCount - 1).clamp(0, maxCap);
      _localFallbackEvents[index] = current.copyWith(attendeesCount: newCount);
      return;
    }
  }

  Stream<Event?> streamEvent(String id) {
    if (_firestore != null) {
      return _firestore!
          .collection('events')
          .doc(id)
          .snapshots()
          .map((doc) => doc.exists ? Event.fromFirestore(doc) : null)
          .handleError((e) {
        return null;
      });
    }
    return const Stream.empty();
  }

  Stream<List<Event>> streamAllRawEvents() {
    if (_firestore != null) {
      return _firestore!
          .collection('events')
          .snapshots()
          .map((snapshot) {
        final events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        _cachedRawEvents = events;
        return events;
      }).handleError((e) {
        return _cachedRawEvents ?? _localFallbackEvents;
      });
    }
    return Stream.value(_localFallbackEvents);
  }

  Future<Event?> getEventById(String id) async {
    if (_firestore != null) {
      try {
        final doc = await _firestore!.collection('events').doc(id).get();
        if (doc.exists) {
          return Event.fromFirestore(doc);
        }
      } catch (_) {}
    }
    try {
      return _localFallbackEvents.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
