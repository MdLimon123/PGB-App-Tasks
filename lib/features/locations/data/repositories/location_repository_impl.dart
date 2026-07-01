import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';
import '../models/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Location>>> getLocations() async {
    try {
      final locations = await remoteDataSource.getLocations();
      return Right(locations);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to get locations'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Location>> addLocation(Location location) async {
    try {
      final locationModel = LocationModel(
        id: '',
        name: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        radiusM: location.radiusM,
      );
      final result = await remoteDataSource.addLocation(locationModel);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to add location'));
    } catch (e) {
      return Left(ServerFailure('Failed to add location: $e'));
    }
  }

  @override
  Future<Either<Failure, Location>> updateLocation(Location location) async {
    try {
      final locationModel = LocationModel(
        id: location.id,
        name: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        radiusM: location.radiusM,
      );
      final result = await remoteDataSource.updateLocation(locationModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to update location'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String id) async {
    try {
      await remoteDataSource.deleteLocation(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete location'));
    }
  }
}
