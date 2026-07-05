import '../data/zones_data.dart';

class Zone {
  final String id;        // Make sure this exists
  final String name;
  final String reportValue;
  final ZoneLevel? level;
  final double latitude;
  final double longitude;
  // ... any other fields

  Zone({
    required this.id,
    required this.name,
    required this.reportValue,
    required this.level,
    required this.latitude,
    required this.longitude,
  });
}