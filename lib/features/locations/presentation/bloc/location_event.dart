import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

class GetLocationsEvent extends LocationEvent {}

class AddLocationEvent extends LocationEvent {
  final Location location;
  const AddLocationEvent(this.location);
  @override
  List<Object?> get props => [location];
}
