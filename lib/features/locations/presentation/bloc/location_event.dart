import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadLocations extends LocationEvent {
  const LoadLocations();
}

class CreateLocation extends LocationEvent {
  final String name;
  final double latitude;
  final double longitude;
  final double radiusM;
  
  const CreateLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
  });
  
  @override
  List<Object?> get props => [name, latitude, longitude, radiusM];
}

class UpdateLocation extends LocationEvent {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;
  
  const UpdateLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    required this.isActive,
  });
  
  @override
  List<Object?> get props => [id, name, latitude, longitude, radiusM, isActive];
}

class DeleteLocation extends LocationEvent {
  final String id;
  
  const DeleteLocation({required this.id});
  
  @override
  List<Object?> get props => [id];
}

class RefreshLocations extends LocationEvent {
  const RefreshLocations();
}
