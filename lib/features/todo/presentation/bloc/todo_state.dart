import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}
class TodoLoading extends TodoState {}

class TodosLoaded extends TodoState {
  final List<Todo> todos;
  final bool isSyncing;
  const TodosLoaded({required this.todos, this.isSyncing = false});
  @override
  List<Object?> get props => [todos, isSyncing];
}

class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);
  @override
  List<Object?> get props => [message];
}
