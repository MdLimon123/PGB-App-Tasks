import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos();
  Future<Either<Failure, Todo>> updateTodoStatus(Todo todo);
  Future<Either<Failure, void>> syncPendingTodos();
}
