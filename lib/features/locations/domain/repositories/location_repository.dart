import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/location.dart';

abstract class LocationRepository {
  Future<Either<Failure, List<Location>>> getLocations();
  Future<Either<Failure, Location>> addLocation(Location location);
  Future<Either<Failure, Location>> updateLocation(Location location);
  Future<Either<Failure, void>> deleteLocation(String id);
}
