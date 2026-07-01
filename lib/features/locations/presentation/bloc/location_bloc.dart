import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;

  LocationBloc({required this.repository}) : super(LocationInitial()) {
    on<LoadLocations>(_onLoadLocations);
    on<CreateLocation>(_onCreateLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<DeleteLocation>(_onDeleteLocation);
    on<RefreshLocations>(_onRefreshLocations);
  }

  Future<void> _onLoadLocations(LoadLocations event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    final result = await repository.getLocations();
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (locations) => emit(LocationsLoaded(locations)),
    );
  }

  Future<void> _onCreateLocation(
    CreateLocation event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    try {
      emit(LocationLoading());
      
      // Create location model
      final locationModel = Location(
        id: '', // Server will assign ID
        name: event.name,
        latitude: event.latitude,
        longitude: event.longitude,
        radiusM: event.radiusM,
        isActive: true,
      );
      
      final result = await repository.addLocation(locationModel);
      result.fold(
        (failure) => emit(LocationError(failure.message)),
        (_) => add(LoadLocations()), // Reload after creating
      );
    } catch (e) {
      emit(LocationError('Failed to create location'));
      if (currentState is LocationsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    try {
      emit(LocationLoading());
      
      final locationModel = Location(
        id: event.id,
        name: event.name,
        latitude: event.latitude,
        longitude: event.longitude,
        radiusM: event.radiusM,
        isActive: event.isActive,
      );
      
      final result = await repository.updateLocation(locationModel);
      result.fold(
        (failure) => emit(LocationError(failure.message)),
        (_) => add(LoadLocations()), // Reload after updating
      );
    } catch (e) {
      emit(LocationError('Failed to update location'));
      if (currentState is LocationsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    try {
      emit(LocationLoading());
      
      final result = await repository.deleteLocation(event.id);
      result.fold(
        (failure) => emit(LocationError(failure.message)),
        (_) => add(LoadLocations()), // Reload after deleting
      );
    } catch (e) {
      emit(LocationError('Failed to delete location'));
      if (currentState is LocationsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onRefreshLocations(
    RefreshLocations event,
    Emitter<LocationState> emit,
  ) async {
    final result = await repository.getLocations();
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (locations) => emit(LocationsLoaded(locations)),
    );
  }
}
