import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> updateTodoStatus(String id, bool isCompleted);
  Future<void> syncTodos(List<Map<String, dynamic>> pendingUpdates);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final DioClient dioClient;

  TodoRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<TodoModel>> getTodos() async {
    final response = await dioClient.dio.get(ApiConstants.todos);
    return (response.data['data'] as List)
        .map((json) => TodoModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> updateTodoStatus(String id, bool isCompleted) async {
    await dioClient.dio.patch(
      '${ApiConstants.todos}/$id',
      data: {'is_completed': isCompleted},
    );
  }

  @override
  Future<void> syncTodos(List<Map<String, dynamic>> pendingUpdates) async {
    await dioClient.dio.post(
      ApiConstants.syncTodos,
      data: {'updates': pendingUpdates},
    );
  }
}
