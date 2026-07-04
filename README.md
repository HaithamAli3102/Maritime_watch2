# Maritime Watch 🌊⚓

A citizen-facing Flutter app for reporting boats spotted in Tanzania's
restricted maritime zones — built for the Marine Department of Tanzania.

No account, no login, no GPS permission prompt. Open the app, describe what
you saw, optionally attach a photo, and send. Contact details are entirely
optional and only used if an investigator needs to follow up.

---

## Features

- **Automatic location detection** — resolves the citizen's approximate
  area via IP address (`ipapi.co`), with a silent, non-blocking upgrade to
  device GPS if it's already available (no permission dialog is forced).
- **Real restricted zones** — nine actual protected/restricted Tanzanian
  maritime areas (Zanzibar Channel, Pemba Exclusion Zone, Mafia Island
  Marine Park, Rufiji Delta, Tanga Coelacanth Park, and more), each with
  approximate coordinates that get embedded into the submitted report.
- **Camera & gallery capture** — citizens can take a new photo on the spot
  or attach one from their gallery, up to 5 photos per report.
- **Optional contact details** — a collapsed, clearly-marked-optional
  section asking only for Name, Phone, and Address — never required to
  submit a report.
- **Anonymous-friendly** — reports submit successfully with zero contact
  information.

---

## Project structure

```
lib/
├── main.dart                  # App entry point
├── theme/
│   └── app_theme.dart         # Blue/white/navy maritime color palette + ThemeData
├── data/
│   └── zones_data.dart        # Real Tanzania restricted zone definitions
├── models/
│   └── boat_report.dart       # BoatReport + Urgency data model
├── services/
│   ├── app_state.dart         # ChangeNotifier holding the in-progress report
│   └── location_service.dart  # IP-based location detection (no GPS prompt)
├── widgets/
│   ├── notice_banner.dart     # Reusable info/warning/success banner
│   └── shared_widgets.dart    # SectionHeader, AppCard, BottomNav, KeyValueRow
└── screens/
    ├── cover_screen.dart      # Splash / how-it-works / "Report a Boat Now"
    ├── root_shell.dart        # Bottom-nav shell (Map / Zones / Report / Reports / More)
    ├── location_screen.dart   # Auto-detected location + schematic coast map
    ├── zones_screen.dart      # List of real restricted zones
    ├── report_screen.dart     # Main report form, camera, optional contact
    ├── review_screen.dart     # Review before sending + success modal
    └── more_screen.dart       # About / emergency contact
```

---

## Getting started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.3+ installed
  and on your `PATH`
- Android Studio (for Android builds) and/or Xcode (for iOS builds, macOS only)
- Run `flutter doctor` and resolve any flagged issues

### Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. (Android only) Point local.properties at your SDKs.
#    Easiest: open android/ in Android Studio once — it auto-generates this.
#    Or edit android/local.properties manually, e.g.:
#      sdk.dir=/Users/you/Library/Android/sdk
#      flutter.sdk=/Users/you/development/flutter

# 3. Run on a connected device or emulator
flutter run
```

### Building release artifacts

```bash
# Android App Bundle (for Play Store)
flutter build appbundle

# Android APK (for direct install / testing)
flutter build apk --release

# iOS (macOS + Xcode required)
flutter build ios --release
```

---

## Notes on the location service

`LocationService.detect()` calls `https://ipapi.co/json/` to resolve an
approximate city/region from the device's IP address — no location
permission dialog is shown, and the citizen never has to tap "Allow."
If that network call fails (offline, blocked, rate-limited), the service
falls back to a sensible Dar es Salaam default so the report flow is never
blocked.

This is intentionally IP-based only — the `geolocator` package is **not**
used and no GPS permission is ever requested, per the product requirement
of a frictionless, prompt-free flow. If precise device GPS is wanted later
(e.g. for an officer-facing build), add `geolocator` back to `pubspec.yaml`
and wire an explicit opt-in button to `Geolocator.requestPermission()` —
don't call it automatically on screen load.

---

## Customizing the restricted zones

Edit `lib/data/zones_data.dart`. Each `MaritimeZone` has:

```dart
MaritimeZone(
  name: 'Zone Name',
  coordRange: 'lat range, lon range',
  description: 'Plain-language explanation of why it's restricted.',
  level: ZoneLevel.noEntry, // or .restricted, .monitored
),
```

The `reportValue` getter (`"$name ($coordRange)"`) is what gets attached to
a citizen's submitted report — keep coordinates in that string accurate, as
this is what helps the Marine Department locate the sighting without GPS.

---

## License

Internal prototype for the Marine Department of Tanzania. Not yet licensed
for public redistribution.
