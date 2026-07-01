import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
  );
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSourceImpl({
    required this.dioClient,
    required this.secureStorage,
  });

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dioClient.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    final authResponse = AuthResponse.fromJson(response.data);
    
    // Store tokens
    await secureStorage.write(
      key: 'access_token',
      value: authResponse.accessToken,
    );
    await secureStorage.write(
      key: 'refresh_token',
      value: authResponse.refreshToken,
    );

    return {
      'access_token': authResponse.accessToken,
      'refresh_token': authResponse.refreshToken,
      'user': authResponse.user,
    };
  }

  @override
  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await dioClient.dio.post(
      ApiConstants.register,
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);
    
    // Store tokens
    await secureStorage.write(
      key: 'access_token',
      value: authResponse.accessToken,
    );
    await secureStorage.write(
      key: 'refresh_token',
      value: authResponse.refreshToken,
    );

    return {
      'access_token': authResponse.accessToken,
      'refresh_token': authResponse.refreshToken,
      'user': authResponse.user,
    };
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.dio.get(ApiConstants.me);
    final userResponse = UserResponse.fromJson(response.data);
    
    return UserModel(
      id: userResponse.id,
      name: userResponse.fullName,
      email: userResponse.email,
    );
  }

  @override
  @override
  Future<void> logout() async {
    try {
      await dioClient.dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignore logout error on server if network is down
    }
    
    // Clear stored tokens
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
  }
}
