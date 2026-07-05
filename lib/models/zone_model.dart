// models/zone_model.dart

/// Zone Model from API
class ZoneModel {
  String? id;
  String? name;
  String? description;
  String? type;
  String? status;
  String? color;
  String? xPercent;
  String? yPercent;
  String? widthPercent;
  String? heightPercent;
  String? createdAt;
  String? updatedAt;
  num? sensorsCount;
  num? reportsCount;

  ZoneModel({
    this.id,
    this.name,
    this.description,
    this.type,
    this.status,
    this.color,
    this.xPercent,
    this.yPercent,
    this.widthPercent,
    this.heightPercent,
    this.createdAt,
    this.updatedAt,
    this.sensorsCount,
    this.reportsCount,
  });

  ZoneModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    type = json['type'];
    status = json['status'];
    color = json['color'];
    xPercent = json['x_percent'];
    yPercent = json['y_percent'];
    widthPercent = json['width_percent'];
    heightPercent = json['height_percent'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sensorsCount = json['sensors_count'];
    reportsCount = json['reports_count'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['description'] = description;
    map['type'] = type;
    map['status'] = status;
    map['color'] = color;
    map['x_percent'] = xPercent;
    map['y_percent'] = yPercent;
    map['width_percent'] = widthPercent;
    map['height_percent'] = heightPercent;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['sensors_count'] = sensorsCount;
    map['reports_count'] = reportsCount;
    return map;
  }

  // Helper to get latitude from x_percent (if actual coordinates are needed)
  double? get latitude {
    if (xPercent == null) return null;
    return double.tryParse(xPercent!);
  }

  // Helper to get longitude from y_percent (if actual coordinates are needed)
  double? get longitude {
    if (yPercent == null) return null;
    return double.tryParse(yPercent!);
  }

  @override
  String toString() {
    return 'ZoneModel(id: $id, name: $name, type: $type, status: $status)';
  }
}

// models/report_model.dart
