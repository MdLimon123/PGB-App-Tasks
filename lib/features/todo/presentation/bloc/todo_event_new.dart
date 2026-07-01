import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {
  const LoadTodos();
}

class UpdateTodoStatus extends TodoEvent {
  final String id;
  final bool isCompleted;
  final String? updatedAt;
  
  const UpdateTodoStatus({
    required this.id,
    required this.isCompleted,
    this.updatedAt,
  });
  
  @override
  List<Object?> get props => [id, isCompleted, updatedAt];
}

class SyncTodosEvent extends TodoEvent {
  const SyncTodosEvent();
}

class RefreshTodos extends TodoEvent {
  const RefreshTodos();
}

class ClearSyncPending extends TodoEvent {
  const ClearSyncPending();
}
