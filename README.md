# Friday Social

A Flutter location-aware event calendar that displays local events alongside daily weather forecasts. Events are created and published to Firebase Cloud Firestore from an admin app (`fs_admin`), and this client app fetches and syncs them in real-time.

## Features

- **Month calendar with weather & counts**: Every day in the calendar shows how many events are happening and a quick weather icon with the day's temperature.
- **Day view & event list**: Tapping any day opens up its schedule and shows that day's weather forecast for your current location. You can also open the full day sheet to browse all events for that date.
- **Event details**: Tapping an event shows its venue, address, start/end time, how far away it is from you, current RSVP count vs. total capacity, and a weather note for the event's start time.
- **Radius filter & location fallback**: Filter events within 5 km, 10 km, or 25 km of your position. If GPS is turned off or permission is denied, it falls back to a default city (Marina Bay, Singapore) or any city you choose from the location picker.
- **Optimistic RSVP with 409 rollback**: Tapping "Join Event" immediately updates the button to "You're Going", bumps the attendee count, and saves your status in local storage. In the background, a Firestore transaction checks server capacity. If the event is full (HTTP 409), the UI immediately rolls back to the previous count, flips the button back, and shows an error message ("This event is full. You couldn't join."). Calendar day counts update in place without reloading the entire month.

## How Weather & Location Work

### Why 16 days of weather?
Open-Meteo provides daily forecast data up to 16 days ahead. Because forecasts further out than 16 days become unreliable, the calendar shows weather icons and temperatures for the first 16 days, while later days in the month cleanly display just the event count.

### Batching & Caching
- **Single batch request**: When you open the app or change location, a single API request fetches all 16 days of weather at once for your coordinates.
- **Never one call per event**: Weather is never fetched per-event. Doing so would cause dozens of redundant network requests and slow down the UI.
- **Never blocks events**: Weather requests run independently in the background. If the weather API is slow or offline, events still load immediately.
- **Cached for 24 hours**: Weather responses are kept in memory for up to 24 hours so switching between dates or radii feels instant.

## Tech Stack

- **Flutter & Dart**
- **GetX** for state management and navigation
- **Cloud Firestore** for real-time events and atomic RSVP transactions
- **SharedPreferences** for saving user attendance locally
- **Geolocator & Geocoding** for GPS location and distance calculation
- **Open-Meteo API** for daily forecasts

## Getting Started

1. Fetch dependencies:
   ```bash
   flutter pub get
   ```

2. Run on a connected device or emulator:
   ```bash
   flutter run
   ```
