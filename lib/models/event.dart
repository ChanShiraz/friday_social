import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String city;
  final DateTime date;
  final String time;
  final String? endTime;
  final String venue;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String category;
  final int accentColorValue;
  final String? weatherNote;
  final int attendeesCount;
  final int? capacity;
  final bool isSaved;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.city = 'Singapore',
    required this.date,
    required this.time,
    this.endTime,
    required this.venue,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceKm = 0.0,
    required this.category,
    this.accentColorValue = 0xFFA23E18,
    this.weatherNote,
    this.attendeesCount = 12,
    this.capacity = 100,
    this.isSaved = false,
  });

  Color get accentColor => Color(accentColorValue);
  bool get isFull => capacity != null && attendeesCount >= capacity!;
  int? get remainingSpots =>
      capacity != null ? (capacity! - attendeesCount).clamp(0, capacity!) : null;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? city,
    DateTime? date,
    String? time,
    String? endTime,
    String? venue,
    String? address,
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? category,
    int? accentColorValue,
    String? weatherNote,
    int? attendeesCount,
    int? capacity,
    bool? isSaved,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      category: category ?? this.category,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      weatherNote: weatherNote ?? this.weatherNote,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      capacity: capacity ?? this.capacity,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Event.fromMap(doc.data() ?? {}, doc.id);
  }

  factory Event.fromMap(Map<String, dynamic> data, String id) {
    DateTime parsedDate;
    final rawDate = data['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    final rawCap = data['capacity'];
    int? parsedCap;
    if (rawCap is num) {
      parsedCap = rawCap.toInt();
    } else if (rawCap is String) {
      parsedCap = int.tryParse(rawCap.trim());
    }

    return Event(
      id: id,
      title: data['title'] as String? ?? 'Atmospheric Event',
      description: data['description'] as String? ?? '',
      city: data['city'] as String? ?? 'Singapore',
      date: parsedDate,
      time: data['time'] as String? ?? '12:00',
      endTime: data['endTime'] as String?,
      venue: data['venue'] as String? ?? 'Marina Bay',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 1.2847,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 103.8610,
      distanceKm: 0.0,
      category: data['category'] as String? ?? 'General',
      accentColorValue: (data['accentColorValue'] as num?)?.toInt() ?? 0xFFA23E18,
      weatherNote: data['weatherNote'] as String?,
      attendeesCount: (data['attendeesCount'] as num?)?.toInt() ?? 8,
      capacity: data.containsKey('capacity') ? parsedCap : 100,
      isSaved: data['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'city': city,
      'date': Timestamp.fromDate(date),
      'time': time,
      'endTime': endTime,
      'venue': venue,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'accentColorValue': accentColorValue,
      'weatherNote': weatherNote,
      'attendeesCount': attendeesCount,
      'capacity': capacity,
    };
  }
}
