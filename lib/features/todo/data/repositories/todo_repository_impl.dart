import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTodos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(remoteTodos);
        return Right(remoteTodos);
      } catch (e) {
        // Fallback to local
        final localTodos = await localDataSource.getCachedTodos();
        return Right(localTodos);
      }
    } else {
      final localTodos = await localDataSource.getCachedTodos();
      return Right(localTodos);
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodoStatus(Todo todo) async {
    final isOnline = await networkInfo.isConnected;
    
    // Optimistic Update Local
    final localModel = TodoModel(
      hiveId: todo.id,
      hiveTitle: todo.title,
      hiveDescription: todo.description,
      hiveIsCompleted: todo.isCompleted,
      hiveIsSyncPending: !isOnline,
      hiveCreatedAt: todo.createdAt,
    );
    await localDataSource.updateTodo(localModel);

    if (isOnline) {
      try {
        await remoteDataSource.updateTodoStatus(todo.id, todo.isCompleted);
        // Ensure sync pending is false
        final syncedModel = TodoModel(
          hiveId: todo.id,
          hiveTitle: todo.title,
          hiveDescription: todo.description,
          hiveIsCompleted: todo.isCompleted,
          hiveIsSyncPending: false,
          hiveCreatedAt: todo.createdAt,
        );
        await localDataSource.updateTodo(syncedModel);
        return Right(syncedModel);
      } catch (e) {
        // If API fails, it remains pending sync
        final failedModel = TodoModel(
          hiveId: todo.id,
          hiveTitle: todo.title,
          hiveDescription: todo.description,
          hiveIsCompleted: todo.isCompleted,
          hiveIsSyncPending: true,
          hiveCreatedAt: todo.createdAt,
        );
        await localDataSource.updateTodo(failedModel);
        return Right(failedModel);
      }
    }
    
    return Right(localModel);
  }

  @override
  Future<Either<Failure, void>> syncPendingTodos() async {
    if (!await networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }

    try {
      final pendingTodos = await localDataSource.getPendingSyncTodos();
      if (pendingTodos.isEmpty) return const Right(null);

      final updates = pendingTodos.map((t) => {
        'id': t.hiveId,
        'is_completed': t.hiveIsCompleted,
      }).toList();

      await remoteDataSource.syncTodos(updates);
      
      // Clear pending status
      await localDataSource.clearPendingSyncStatus(pendingTodos.map((t) => t.hiveId).toList());
      
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to sync'));
    }
  }
}
