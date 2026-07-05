
import 'package:maritime_watch/models/zone_model.dart';

class ReportModel {
  num? reportId;
  String? date;
  String? latitude;
  String? longitude;
  String? address;
  String? zoneId;
  String? color;
  num? numberOfPeople;
  String? description;
  String? photo;
  String? name;
  String? phone;
  num? urgencyId;
  String? createdAt;
  String? updatedAt;
  ZoneModel? zone;
  dynamic urgency;

  ReportModel({
    this.reportId,
    this.date,
    this.latitude,
    this.longitude,
    this.address,
    this.zoneId,
    this.color,
    this.numberOfPeople,
    this.description,
    this.photo,
    this.name,
    this.phone,
    this.urgencyId,
    this.createdAt,
    this.updatedAt,
    this.zone,
    this.urgency,
  });

  ReportModel.fromJson(dynamic json) {
    reportId = json['report_id'];
    date = json['date'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    zoneId = json['zone_id'];
    color = json['color'];
    numberOfPeople = json['number_of_people'];
    description = json['description'];
    photo = json['photo'];
    name = json['name'];
    phone = json['phone'];
    urgencyId = json['urgency_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    zone = json['zone'] != null ? ZoneModel.fromJson(json['zone']) : null;
    urgency = json['urgency'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['report_id'] = reportId;
    map['date'] = date;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['address'] = address;
    map['zone_id'] = zoneId;
    map['color'] = color;
    map['number_of_people'] = numberOfPeople;
    map['description'] = description;
    map['photo'] = photo;
    map['name'] = name;
    map['phone'] = phone;
    map['urgency_id'] = urgencyId;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (zone != null) {
      map['zone'] = zone?.toJson();
    }
    map['urgency'] = urgency;
    return map;
  }
}