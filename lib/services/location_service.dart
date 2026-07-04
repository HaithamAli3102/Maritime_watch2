import 'dart:convert';
import 'package:http/http.dart' as http;

class DetectedLocation {
  final String area;
  final String region;
  final String country;
  final String coords;
  final String nearestZoneHint;

  const DetectedLocation({
    required this.area,
    required this.region,
    required this.country,
    required this.coords,
    required this.nearestZoneHint,
  });

  static const fallback = DetectedLocation(
    area: 'Dar es Salaam',
    region: 'Dar es Salaam Region',
    country: 'Tanzania',
    coords: '6.7924°S, 39.2083°E (approx.)',
    nearestZoneHint: 'Dar es Salaam Port Zone (~8 km)',
  );
}

/// Resolves the citizen's approximate location automatically — purely from
/// their network/IP address, with no GPS permission dialog. This keeps the
/// reporting flow frictionless: the app "just knows" roughly where you are
/// the moment it opens, the same way a website can guess your city.
class LocationService {
  static Future<DetectedLocation> detect() async {
    try {
      final res = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final lat = data['latitude'];
        final lon = data['longitude'];
        final area = (data['city'] ?? data['region'] ?? 'Unknown').toString();

        return DetectedLocation(
          area: area,
          region: (data['region'] ?? 'Unknown').toString(),
          country: (data['country_name'] ?? 'Tanzania').toString(),
          coords: (lat != null && lon != null)
              ? '${_fmt(lat)}°${lat < 0 ? 'S' : 'N'}, ${_fmt(lon)}°${lon >= 0 ? 'E' : 'W'}'
              : 'Approximate',
          nearestZoneHint: _nearestZoneFor(area),
        );
      }
    } catch (_) {
      // Network unavailable, blocked, or timed out — fall back gracefully.
    }
    return DetectedLocation.fallback;
  }

  static String _fmt(dynamic v) {
    final d = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0;
    return d.abs().toStringAsFixed(4);
  }

  static String _nearestZoneFor(String area) {
    final a = area.toLowerCase();
    if (a.contains('zanzibar') || a.contains('unguja')) {
      return 'Zanzibar Channel (~5 km)';
    }
    if (a.contains('pemba')) return 'Pemba Northern Zone (~3 km)';
    if (a.contains('tanga')) return 'Tanga Coelacanth Park (~12 km)';
    if (a.contains('mafia')) return 'Mafia Island Marine Park (~2 km)';
    if (a.contains('mtwara') || a.contains('lindi')) {
      return 'Mnazi Bay–Ruvuma (~18 km)';
    }
    if (a.contains('kilwa') || a.contains('rufiji')) {
      return 'Rufiji Delta (~10 km)';
    }
    return 'Dar es Salaam Port Zone (~8 km)';
  }
}
