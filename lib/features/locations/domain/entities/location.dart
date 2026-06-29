import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  const Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude, radiusM, isActive];
}
