import 'dart:io';

enum Urgency { low, medium, high }

extension UrgencyLabel on Urgency {
  String get label {
    switch (this) {
      case Urgency.low:
        return 'Not urgent';
      case Urgency.medium:
        return 'Somewhat urgent';
      case Urgency.high:
        return 'Very urgent / ongoing';
    }
  }
}

class BoatReport {
  DateTime sightedAt;
  String? zoneValue; // MaritimeZone.reportValue, or free text
  String? boatType;
  String boatColor;
  String peopleOnboard;
  String notes;
  Urgency urgency;
  List<File> photos;

  // Optional citizen contact — never required.
  String contactName;
  String contactPhone;
  String contactAddress;

  // Auto-detected location (no GPS prompt; IP / network based).
  String detectedArea;
  String detectedRegion;
  String detectedCountry;
  String detectedCoords;

  BoatReport({
    DateTime? sightedAt,
    this.zoneValue,
    this.boatType,
    this.boatColor = '',
    this.peopleOnboard = '1–2',
    this.notes = '',
    this.urgency = Urgency.medium,
    List<File>? photos,
    this.contactName = '',
    this.contactPhone = '',
    this.contactAddress = '',
    this.detectedArea = 'Detecting…',
    this.detectedRegion = '',
    this.detectedCountry = 'Tanzania',
    this.detectedCoords = '',
  })  : sightedAt = sightedAt ?? DateTime.now(),
        photos = photos ?? [];

  bool get hasContactDetails =>
      contactName.trim().isNotEmpty ||
      contactPhone.trim().isNotEmpty ||
      contactAddress.trim().isNotEmpty;

  String get referenceId =>
      'MW-${DateTime.now().year}-${(1000 + DateTime.now().millisecond).toString()}';
}
