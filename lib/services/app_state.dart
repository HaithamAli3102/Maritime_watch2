import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/boat_report.dart';
import '../services/location_service.dart';

class PastReport {
  final String title;
  final String date;
  final String status;
  PastReport(this.title, this.date, this.status);
}

class AppState extends ChangeNotifier {
  BoatReport draft = BoatReport();
  DetectedLocation? location;
  bool locating = true;

  final List<PastReport> pastReports = [
    PastReport('Motorboat near Gamma Coast', '5 Nov 2024', 'Reviewed'),
    PastReport('Small dhow, Beta Bay area', '28 Oct 2024', 'Under review'),
  ];

  Future<void> detectLocation() async {
    locating = true;
    notifyListeners();
    final loc = await LocationService.detect();
    location = loc;
    draft.detectedArea = loc.area;
    draft.detectedRegion = loc.region;
    draft.detectedCountry = loc.country;
    draft.detectedCoords = loc.coords;
    locating = false;
    notifyListeners();
  }

  void updateZone(String? zoneValue) {
    draft.zoneValue = zoneValue;
    notifyListeners();
  }

  void updateBoatType(String? type) {
    draft.boatType = type;
    notifyListeners();
  }

  void updateUrgency(Urgency u) {
    draft.urgency = u;
    notifyListeners();
  }

  void addPhoto(File file) {
    if (draft.photos.length >= 5) return;
    draft.photos.add(file);
    notifyListeners();
  }

  void removePhoto(int index) {
    draft.photos.removeAt(index);
    notifyListeners();
  }

  void setContact({String? name, String? phone, String? address}) {
    if (name != null) draft.contactName = name;
    if (phone != null) draft.contactPhone = phone;
    if (address != null) draft.contactAddress = address;
  }

  String submitAndGetReference() {
    final ref = draft.referenceId;
    pastReports.insert(
      0,
      PastReport(
        draft.boatType ?? 'Unspecified vessel',
        '${draft.sightedAt.day}/${draft.sightedAt.month}/${draft.sightedAt.year}',
        'Submitted',
      ),
    );
    draft = BoatReport(
      detectedArea: location?.area ?? 'Unknown',
      detectedRegion: location?.region ?? '',
      detectedCountry: location?.country ?? 'Tanzania',
      detectedCoords: location?.coords ?? '',
    );
    notifyListeners();
    return ref;
  }
}
