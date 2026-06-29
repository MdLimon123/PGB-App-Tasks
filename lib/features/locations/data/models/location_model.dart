import '../../domain/entities/location.dart';

class LocationModel extends Location {
  const LocationModel({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required double radiusM,
    bool isActive = true,
  }) : super(
          id: id,
          name: name,
          latitude: latitude,
          longitude: longitude,
          radiusM: radiusM,
          isActive: isActive,
        );

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['location_name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      radiusM: (json['radius_m'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'location_name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius_m': radiusM,
      'is_active': isActive,
    };
  }
}
