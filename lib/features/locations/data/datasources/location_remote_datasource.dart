import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<LocationModel>> getLocations();
  Future<LocationModel> addLocation(LocationModel location);
  Future<LocationModel> updateLocation(LocationModel location);
  Future<void> deleteLocation(String id);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final DioClient dioClient;

  LocationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<LocationModel>> getLocations() async {
    final response = await dioClient.dio.get(ApiConstants.locations);
    return (response.data['data'] as List)
        .map((json) => LocationModel.fromJson(json))
        .toList();
  }

  @override
  Future<LocationModel> addLocation(LocationModel location) async {
    final response = await dioClient.dio.post(
      ApiConstants.locations,
      data: location.toJson(),
    );
    
    if (response.data != null && response.data is Map<String, dynamic>) {
      if (response.data['data'] != null) {
        return LocationModel.fromJson(response.data['data']);
      } else if (response.data['id'] != null || response.data['_id'] != null) {
        return LocationModel.fromJson(response.data);
      }
    }
    
   
    return location;
  }

  @override
  Future<LocationModel> updateLocation(LocationModel location) async {
    final response = await dioClient.dio.put(
      '${ApiConstants.locations}/${location.id}',
      data: location.toJson(),
    );
    return LocationModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteLocation(String id) async {
    await dioClient.dio.delete('${ApiConstants.locations}/$id');
  }
}
