import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSourceImpl({required this.dioClient, required this.secureStorage});

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await dioClient.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    
    // Assume response contains token and user data
    final token = response.data['token'];
    await secureStorage.write(key: 'access_token', value: token);
    
    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final response = await dioClient.dio.post(
      ApiConstants.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    
    final token = response.data['token'];
    await secureStorage.write(key: 'access_token', value: token);
    
    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.dio.get(ApiConstants.me);
    return UserModel.fromJson(response.data['user'] ?? response.data);
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignore logout error on server if network is down
    }
    await secureStorage.delete(key: 'access_token');
  }
}
