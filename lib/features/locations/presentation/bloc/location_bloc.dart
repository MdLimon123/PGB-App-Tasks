import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;

  LocationBloc({required this.repository}) : super(LocationInitial()) {
    on<GetLocationsEvent>(_onGetLocations);
    on<AddLocationEvent>(_onAddLocation);
  }

  Future<void> _onGetLocations(GetLocationsEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    final result = await repository.getLocations();
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (locations) => emit(LocationsLoaded(locations)),
    );
  }

  Future<void> _onAddLocation(AddLocationEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    final result = await repository.addLocation(event.location);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (location) {
        add(GetLocationsEvent()); // Reload locations
      },
    );
  }
}
